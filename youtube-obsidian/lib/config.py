"""
Configuration management for yt (YouTube to Obsidian).

Handles loading, creating, and managing user configuration from ~/.yt-obsidian/config.yml
"""

import os
import yaml
from pathlib import Path
from typing import Dict, Any, Optional
from dataclasses import dataclass, field


@dataclass
class Config:
    """User configuration for yt command."""
    
    # Analysis behavior
    analysis_mode: str = "auto"  # auto, quick, deep, expert
    model: str = "best"  # best (auto-pick), fast, quality, or specific model name
    
    # Output settings
    output_dir: Optional[str] = None  # Default: $OBSVAULT/youtube
    open_in_editor: bool = False
    keep_temp_files: bool = False
    verbose: bool = False
    
    # Always-run patterns (run on every video first)
    always_run_patterns: list = field(default_factory=list)
    
    # Auto-analyze settings (used when analysis_mode=auto)
    auto_min_priority: str = "high"  # essential, high, medium, optional
    auto_max_patterns: int = 15
    auto_show_recommendations: bool = False
    
    # Quick mode settings
    quick_patterns: list = field(default_factory=lambda: [
        "extract_wisdom",
        "youtube_summary",
        "extract_insights",
        "extract_patterns",
        "extract_main_idea"
    ])
    
    # Deep mode settings
    deep_min_priority: str = "optional"  # Include everything
    deep_max_patterns: int = 25
    
    # Expert mode settings
    fabric_command: str = "fabric-ai"
    timeout_per_pattern: int = 120
    chunk_size: int = 8000
    

DEFAULT_CONFIG_CONTENT = """# yt - YouTube to Obsidian Configuration
# Location: ~/.yt-obsidian/config.yml
# Edit this file to customize default behavior

# ============================================================================
# ANALYSIS MODE
# ============================================================================
# Determines how videos are analyzed by default
# Options: auto, quick, deep, expert
#
# - auto:   Smart analysis using pattern_optimizer (recommended)
#           Analyzes content and selects 10-15 optimal patterns
#           Time: ~50 seconds
#
# - quick:  Fast analysis with 5 essential patterns only
#           Time: ~25 seconds
#           Patterns: wisdom, summary, insights, patterns, main idea
#
# - deep:   Complete analysis with all recommended patterns
#           Time: ~70 seconds
#
# - expert: Full manual control over all settings
#
analysis_mode: auto

# ============================================================================
# MODEL SELECTION
# ============================================================================
# LLM model to use for Fabric AI analysis
# Options: best, fast, quality, or specific model name
#
# - best:    Auto-selects fastest model (llama-4-scout, 30K TPM)
# - fast:    Prioritizes speed (llama-8b, 6K TPM)
# - quality: Prioritizes quality (llama-70b, 12K TPM)
# - Specific: e.g., "llama-4-scout", "kimi", "llama-70b"
#
model: best

# ============================================================================
# OUTPUT SETTINGS
# ============================================================================
# Where to save the generated notes
# Use $OBSVAULT to reference your Obsidian vault environment variable
# Default: $OBSVAULT/youtube
output_dir: null

# Open note in editor after creation?
open_in_editor: false

# Keep temporary files in .fabric/ directory for debugging?
keep_temp_files: false

# Show detailed output during processing?
verbose: false

# ============================================================================
# ALWAYS-RUN PATTERNS
# ============================================================================
# Patterns that run on EVERY video before mode-specific patterns.
# Useful for baseline analysis you always want. Leave empty for none.
# Example: ["extract_main_idea", "youtube_summary"]
always_run_patterns: []

# ============================================================================
# AUTO MODE SETTINGS (used when analysis_mode=auto)
# ============================================================================
auto:
  # Minimum pattern priority to include
  # Options: essential, high, medium, optional
  min_priority: high
  
  # Maximum number of patterns to run
  max_patterns: 15
  
  # Show pattern recommendations before running?
  show_recommendations: false

# ============================================================================
# QUICK MODE SETTINGS
# ============================================================================
# Patterns to run in quick mode (can customize this list)
quick:
  patterns:
    - extract_wisdom
    - youtube_summary
    - extract_insights
    - extract_patterns
    - extract_main_idea

# ============================================================================
# DEEP MODE SETTINGS
# ============================================================================
deep:
  # Include all priorities (even optional patterns)
  min_priority: optional
  
  # Higher limit for comprehensive analysis
  max_patterns: 25

# ============================================================================
# EXPERT MODE SETTINGS
# ============================================================================
expert:
  # Fabric CLI command (override if using different installation)
  fabric_command: fabric-ai
  
  # Timeout per pattern execution (seconds)
  timeout_per_pattern: 120
  
  # Chunk size for large transcripts (tokens)
  chunk_size: 8000
"""


def get_config_path() -> Path:
    """Get path to user config file."""
    config_dir = Path.home() / ".yt-obsidian"
    return config_dir / "config.yml"


def ensure_config_dir() -> Path:
    """Ensure config directory exists."""
    config_dir = Path.home() / ".yt-obsidian"
    config_dir.mkdir(parents=True, exist_ok=True)
    return config_dir


def create_default_config() -> Path:
    """Create default config file."""
    ensure_config_dir()
    config_path = get_config_path()
    
    if not config_path.exists():
        with open(config_path, 'w') as f:
            f.write(DEFAULT_CONFIG_CONTENT)
    
    return config_path


def load_config() -> Config:
    """Load user configuration from file.
    
    Creates default config if it doesn't exist.
    Falls back to built-in defaults if file is malformed.
    
    Returns:
        Config object with user settings
    """
    config_path = get_config_path()
    
    # Create default config if doesn't exist
    if not config_path.exists():
        create_default_config()
        return Config()  # Return defaults for first run
    
    # Try to load existing config
    try:
        with open(config_path, 'r') as f:
            user_config = yaml.safe_load(f)
        
        if not user_config:
            return Config()
        
        # Parse config with defaults
        config = Config()
        
        # Top-level settings
        config.analysis_mode = user_config.get('analysis_mode', config.analysis_mode)
        config.model = user_config.get('model', config.model)
        config.output_dir = user_config.get('output_dir', config.output_dir)
        config.open_in_editor = user_config.get('open_in_editor', config.open_in_editor)
        config.keep_temp_files = user_config.get('keep_temp_files', config.keep_temp_files)
        config.verbose = user_config.get('verbose', config.verbose)
        
        # Always-run patterns
        config.always_run_patterns = user_config.get('always_run_patterns', config.always_run_patterns)
        
        # Auto mode settings
        if 'auto' in user_config:
            auto = user_config['auto']
            config.auto_min_priority = auto.get('min_priority', config.auto_min_priority)
            config.auto_max_patterns = auto.get('max_patterns', config.auto_max_patterns)
            config.auto_show_recommendations = auto.get('show_recommendations', config.auto_show_recommendations)
        
        # Quick mode settings
        if 'quick' in user_config and 'patterns' in user_config['quick']:
            config.quick_patterns = user_config['quick']['patterns']
        
        # Deep mode settings
        if 'deep' in user_config:
            deep = user_config['deep']
            config.deep_min_priority = deep.get('min_priority', config.deep_min_priority)
            config.deep_max_patterns = deep.get('max_patterns', config.deep_max_patterns)
        
        # Expert mode settings
        if 'expert' in user_config:
            expert = user_config['expert']
            config.fabric_command = expert.get('fabric_command', config.fabric_command)
            config.timeout_per_pattern = expert.get('timeout_per_pattern', config.timeout_per_pattern)
            config.chunk_size = expert.get('chunk_size', config.chunk_size)
        
        return config
        
    except Exception as e:
        # If config is malformed, fall back to defaults
        print(f"⚠️  Warning: Could not load config from {config_path}: {e}")
        print(f"⚠️  Using built-in defaults")
        return Config()


def resolve_model(model_setting: str) -> str:
    """Resolve model setting to actual model name.
    
    Args:
        model_setting: User setting (best, fast, quality, or specific name)
        
    Returns:
        Actual model name to use
    """
    model_map = {
        "best": "llama-4-scout",     # 30K TPM - best throughput
        "fast": "llama-8b",           # 6K TPM - fastest single pattern
        "quality": "llama-70b",       # 12K TPM - best quality
    }
    
    return model_map.get(model_setting, model_setting)


def resolve_output_dir(config: Config) -> Path:
    """Resolve output directory from config.
    
    Args:
        config: User configuration
        
    Returns:
        Path to output directory
        
    Raises:
        ValueError: If OBSVAULT not set and no output_dir specified
    """
    if config.output_dir:
        # Expand $OBSVAULT if present
        output_dir = config.output_dir
        if "$OBSVAULT" in output_dir:
            obsvault = os.getenv("OBSVAULT")
            if not obsvault:
                raise ValueError("OBSVAULT environment variable not set")
            output_dir = output_dir.replace("$OBSVAULT", obsvault)
        return Path(output_dir)
    
    # Default: $OBSVAULT/youtube
    obsvault = os.getenv("OBSVAULT")
    if not obsvault:
        raise ValueError(
            "OBSVAULT environment variable not set. "
            "Set it with: export OBSVAULT=/path/to/vault"
        )
    
    return Path(obsvault) / "youtube"
