"""Rate limit handling and model management for Groq API via Fabric.

This module provides:
- Retry logic with exponential backoff for 429 errors
- Request size validation to prevent 413 errors  
- Model rotation to maximize throughput across rate limits
- Thinking tag parsing for models like QWen
"""

import re
import time
import subprocess
from typing import Optional, Dict, List, Tuple
from dataclasses import dataclass, field


@dataclass
class GroqModel:
    """Groq model configuration with rate limits."""
    name: str
    tpm: int  # Tokens per minute
    rpm: int = 30  # Requests per minute
    context_window: int = 128000  # Default context
    is_thinking_model: bool = False  # QWen etc.


# Groq free tier models ranked by TPM (tokens per minute)
GROQ_MODELS: Dict[str, GroqModel] = {
    "llama-4-scout": GroqModel(
        name="meta-llama/llama-4-scout-17b-16e-instruct",
        tpm=30000,  # Best TPM!
        rpm=30
    ),
    "llama-guard": GroqModel(
        name="meta-llama/llama-guard-4-12b",
        tpm=15000,
        rpm=30
    ),
    "llama-70b": GroqModel(
        name="llama-3.3-70b-versatile",
        tpm=12000,
        rpm=30
    ),
    "kimi": GroqModel(
        name="moonshotai/kimi-k2-instruct-0905",
        tpm=10000,
        rpm=60
    ),
    "gpt-oss-120b": GroqModel(
        name="openai/gpt-oss-120b",
        tpm=8000,
        rpm=30
    ),
    "llama-8b": GroqModel(
        name="llama-3.1-8b-instant",
        tpm=6000,
        rpm=30
    ),
    "qwen3": GroqModel(
        name="qwen/qwen3-32b",
        tpm=6000,
        rpm=60,
        is_thinking_model=True  # May output <think> tags
    ),
}

# Recommended models for different use cases
RECOMMENDED_MODELS = {
    "high_throughput": "llama-4-scout",  # 30K TPM
    "quality": "llama-70b",  # Best quality, 12K TPM
    "fast": "llama-8b",  # Fastest, 6K TPM
    "default": "kimi",  # Balanced
}


def resolve_model_name(model_alias: str) -> str:
    """Resolve model alias to full model name for Fabric CLI.
    
    Args:
        model_alias: Model alias (e.g., "llama-4-scout", "kimi") or full name
        
    Returns:
        Full model name for Fabric CLI, or original input if not found
        
    Examples:
        >>> resolve_model_name("llama-4-scout")
        "meta-llama/llama-4-scout-17b-16e-instruct"
        >>> resolve_model_name("kimi")
        "moonshotai/kimi-k2-instruct-0905"
        >>> resolve_model_name("unknown-model")
        "unknown-model"
    """
    # Check if it's an alias
    if model_alias in GROQ_MODELS:
        return GROQ_MODELS[model_alias].name
    
    # Already a full name or unknown - return as-is
    return model_alias


def get_model_tpm(model_name: str) -> int:
    """Get tokens per minute limit for a model.
    
    Args:
        model_name: Full model name or alias
        
    Returns:
        TPM limit, or 6000 as safe default
    """
    # Check aliases first
    if model_name in GROQ_MODELS:
        return GROQ_MODELS[model_name].tpm
    
    # Check full names
    for alias, model in GROQ_MODELS.items():
        if model.name == model_name or model_name in model.name:
            return model.tpm
    
    # Safe default
    return 6000


def estimate_tokens(text: str) -> int:
    """Estimate token count from text.
    
    Uses rough heuristic: ~0.75 tokens per word for English.
    More accurate than character count.
    
    Args:
        text: Input text
        
    Returns:
        Estimated token count
    """
    words = len(text.split())
    # Fabric patterns add ~500-1000 tokens of system prompt
    system_overhead = 800
    return int(words * 1.3) + system_overhead


def validate_request_size(text: str, max_tokens: int = 30000) -> Tuple[bool, str]:
    """Validate request won't exceed model limits.
    
    Prevents 413 "Request Entity Too Large" errors.
    
    Args:
        text: Input text to send
        max_tokens: Maximum allowed tokens (default: 30K for scout)
        
    Returns:
        Tuple of (is_valid, error_message)
    """
    estimated = estimate_tokens(text)
    
    if estimated > max_tokens:
        return False, f"Request too large: ~{estimated} tokens (max: {max_tokens})"
    
    return True, ""


def parse_thinking_tags(text: str) -> str:
    """Remove thinking tags from model output.
    
    Models like QWen may output <think>...</think> blocks.
    This removes them to get clean output.
    
    Args:
        text: Raw model output
        
    Returns:
        Cleaned output without thinking tags
    """
    # Remove <think>...</think> blocks (including multiline)
    text = re.sub(r'<think>.*?</think>', '', text, flags=re.DOTALL)
    
    # Remove <thinking>...</thinking> blocks
    text = re.sub(r'<thinking>.*?</thinking>', '', text, flags=re.DOTALL)
    
    # Clean up extra whitespace
    text = re.sub(r'\n{3,}', '\n\n', text)
    
    return text.strip()


@dataclass
class RetryConfig:
    """Configuration for retry behavior."""
    max_retries: int = 3
    base_delay: float = 2.0  # seconds
    max_delay: float = 60.0  # seconds
    exponential_base: float = 2.0


@dataclass 
class FabricResult:
    """Result from a Fabric pattern call."""
    success: bool
    output: str = ""
    error: str = ""
    retries: int = 0
    model_used: Optional[str] = None


class RateLimitHandler:
    """Handles rate limits and retries for Fabric calls."""
    
    def __init__(
        self,
        fabric_command: str = "fabric-ai",
        retry_config: Optional[RetryConfig] = None,
        fallback_models: Optional[List[str]] = None
    ):
        """Initialize rate limit handler.
        
        Args:
            fabric_command: Command to run Fabric
            retry_config: Retry configuration
            fallback_models: List of fallback model names to try on rate limit
        """
        self.fabric_command = fabric_command
        self.retry_config = retry_config or RetryConfig()
        self.fallback_models = fallback_models or []
        
        # Track rate limit hits per model
        self._rate_limit_hits: Dict[str, int] = {}
        self._last_request_time: Dict[str, float] = {}
    
    def run_pattern(
        self,
        pattern: str,
        input_text: str,
        timeout: int = 120,
        model: Optional[str] = None
    ) -> FabricResult:
        """Run Fabric pattern with retry and rate limit handling.
        
        Args:
            pattern: Fabric pattern name
            input_text: Input text to process
            timeout: Timeout in seconds
            model: Optional model override
            
        Returns:
            FabricResult with output or error
        """
        # Validate request size first
        is_valid, error = validate_request_size(input_text)
        if not is_valid:
            return FabricResult(success=False, error=error)
        
        # Build models to try (primary + fallbacks)
        models_to_try: List[Optional[str]] = [model] if model else [None]  # None = use default
        for fallback in self.fallback_models:
            models_to_try.append(fallback)
        
        last_error = ""
        total_retries = 0
        
        for current_model in models_to_try:
            result = self._try_with_retries(
                pattern=pattern,
                input_text=input_text,
                timeout=timeout,
                model=current_model
            )
            
            total_retries += result.retries
            
            if result.success:
                result.retries = total_retries
                return result
            
            last_error = result.error
            
            # If not a rate limit error, don't try other models
            if "429" not in result.error and "rate limit" not in result.error.lower():
                break
            
            # If we're going to try another model, log it
            if current_model and len(models_to_try) > 1:
                next_model_index = models_to_try.index(current_model) + 1
                if next_model_index < len(models_to_try):
                    next_model = models_to_try[next_model_index]
                    if next_model:
                        # Extract short name for display
                        model_alias = next_model.split('/')[-1] if '/' in next_model else next_model
                        print(f"      🔄 Model quota exhausted, trying fallback: {model_alias}")
        
        return FabricResult(
            success=False,
            error=last_error,
            retries=total_retries
        )
    
    def _try_with_retries(
        self,
        pattern: str,
        input_text: str,
        timeout: int,
        model: Optional[str]
    ) -> FabricResult:
        """Try running pattern with exponential backoff on rate limits.
        
        Args:
            pattern: Pattern name
            input_text: Input text
            timeout: Timeout
            model: Model to use
            
        Returns:
            FabricResult
        """
        retries = 0
        delay = self.retry_config.base_delay
        last_result: Optional[FabricResult] = None
        
        while retries <= self.retry_config.max_retries:
            result = self._run_fabric(pattern, input_text, timeout, model)
            last_result = result
            
            if result.success:
                return result
            
            # Check if rate limited (429) or other retriable error
            is_rate_limited = "429" in result.error or "rate limit" in result.error.lower()
            is_server_error = any(code in result.error for code in ["500", "502", "503"])
            
            if not (is_rate_limited or is_server_error):
                # Non-retriable error
                return result
            
            retries += 1
            
            if retries > self.retry_config.max_retries:
                break
            
            # Exponential backoff
            print(f"      ⏳ Rate limited, waiting {delay:.1f}s (retry {retries}/{self.retry_config.max_retries})")
            time.sleep(delay)
            delay = min(delay * self.retry_config.exponential_base, self.retry_config.max_delay)
        
        error_msg = last_result.error if last_result else "Unknown error"
        return FabricResult(
            success=False,
            error=f"Max retries exceeded: {error_msg}",
            retries=retries,
            model_used=model
        )
    
    def _run_fabric(
        self,
        pattern: str,
        input_text: str,
        timeout: int,
        model: Optional[str]
    ) -> FabricResult:
        """Execute single Fabric call.
        
        Args:
            pattern: Pattern name
            input_text: Input text
            timeout: Timeout
            model: Model to use
            
        Returns:
            FabricResult
        """
        cmd = [self.fabric_command, "-p", pattern]
        
        if model:
            cmd.extend(["-m", model])
        
        try:
            result = subprocess.run(
                cmd,
                input=input_text,
                capture_output=True,
                text=True,
                timeout=timeout,
                check=False
            )
            
            if result.returncode != 0:
                error_text = result.stderr or f"Exit code {result.returncode}"
                
                # Parse specific error codes
                if "429" in error_text:
                    return FabricResult(
                        success=False,
                        error="429 Rate limit exceeded",
                        model_used=model
                    )
                elif "413" in error_text:
                    return FabricResult(
                        success=False,
                        error="413 Request too large",
                        model_used=model
                    )
                
                return FabricResult(
                    success=False,
                    error=error_text[:200],
                    model_used=model
                )
            
            output = result.stdout.strip()
            
            # Parse thinking tags if present
            output = parse_thinking_tags(output)
            
            return FabricResult(
                success=True,
                output=output,
                model_used=model
            )
        
        except subprocess.TimeoutExpired:
            return FabricResult(
                success=False,
                error=f"Timeout after {timeout}s",
                model_used=model
            )
        
        except Exception as e:
            return FabricResult(
                success=False,
                error=str(e),
                model_used=model
            )


def get_optimal_chunk_size(model_name: str) -> int:
    """Get optimal chunk size for a model based on its TPM.
    
    For rate limit management, we want chunks that:
    1. Fit within context window
    2. Don't exhaust TPM too quickly
    3. Allow for system prompt overhead
    
    Args:
        model_name: Model name or alias
        
    Returns:
        Recommended max tokens per chunk
    """
    tpm = get_model_tpm(model_name)
    
    # Target: process 2-3 chunks per minute without hitting limits
    # Reserve 30% for system prompt and output
    chunk_size = int(tpm * 0.35)
    
    # Clamp to reasonable range
    return max(3000, min(chunk_size, 12000))


def suggest_model_for_task(
    estimated_tokens: int,
    priority: str = "balanced"
) -> str:
    """Suggest best model for a task based on token count.
    
    Args:
        estimated_tokens: Estimated total tokens to process
        priority: "throughput", "quality", or "balanced"
        
    Returns:
        Recommended model name
    """
    if priority == "throughput":
        # llama-4-scout has 30K TPM
        return GROQ_MODELS["llama-4-scout"].name
    elif priority == "quality":
        # llama-70b for best quality
        return GROQ_MODELS["llama-70b"].name
    else:
        # Balanced: use kimi for moderate loads, switch to scout for heavy
        if estimated_tokens > 50000:
            return GROQ_MODELS["llama-4-scout"].name
        return GROQ_MODELS["kimi"].name
