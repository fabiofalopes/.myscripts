"""
Metadata and transcript extraction via yt-dlp library mode.

Uses yt-dlp Python API for unified extraction with error handling and retry logic.
"""

from __future__ import annotations

import json
import subprocess
from typing import Any, Dict, List, Optional, Sequence

import yt_dlp  # type: ignore[import]

from tenacity import (
    retry,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)  # type: ignore[import]

from .exceptions import (
    AgeRestrictedError,
    CommandNotFoundError,
    ExtractionError,
    NetworkError,
    RateLimitError,
    VideoUnavailableError,
    YTObsidianError,
)
from .transcript import extract_transcript_from_info, get_transcript_metadata

YT_DLP_TIMEOUT_SECONDS = 30

# Error pattern matching for stderr parsing
_RATE_LIMIT_PATTERNS = ("http error 429", "too many requests", "429")
_AGE_RESTRICTED_PATTERNS = (
    "sign in to confirm your age",
    "sign in to view this video",
    "age-restricted",
    "age restricted",
)
_VIDEO_UNAVAILABLE_PATTERNS = (
    "video unavailable",
    "this video is unavailable",
    "private video",
    "uploader has not made this video available",
)
_NETWORK_PATTERNS = (
    "unable to download webpage",
    "failed to resolve",
    "temporarily unavailable",
    "ssl:",
    "timed out",
    "connection reset",
    "network is unreachable",
)


@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10),
    retry=retry_if_exception_type((NetworkError, RateLimitError)),
    reraise=True,
)
def extract_metadata(
    url: str, 
    cookies_browser: Optional[str] = None,
    extract_transcript: bool = True,
    transcript_lang: str = 'en'
) -> Dict[str, Any]:
    """
    Extract video metadata and transcript using yt-dlp library mode.

    Args:
        url: YouTube video URL (must be normalized)
        cookies_browser: Optional browser to extract cookies from
                        (e.g., "firefox", "chrome") for age-restricted videos
        extract_transcript: Whether to extract transcript (default: True)
        transcript_lang: Preferred transcript language (default: 'en')

    Returns:
        Dictionary containing:
            - 'metadata': All video metadata fields
            - 'transcript': Transcript text or None
            - 'transcript_info': Transcript metadata dict

    Raises:
        CommandNotFoundError: yt-dlp not found
        VideoUnavailableError: Video is deleted, private, or geo-blocked
        AgeRestrictedError: Video requires age verification
        RateLimitError: YouTube rate limiting detected (triggers retry)
        NetworkError: Network connection issue (triggers retry)
        ExtractionError: Other yt-dlp failures

    Example:
        >>> result = extract_metadata("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        >>> print(result['metadata']["title"])
        "Rick Astley - Never Gonna Give You Up"
        >>> print(result['transcript'][:100] if result['transcript'] else "No transcript")
    """
    # Build yt-dlp options
    ydl_opts: Dict[str, Any] = {
        'quiet': True,
        'no_warnings': True,
        'skip_download': True,
    }
    
    # Add subtitle extraction if requested
    if extract_transcript:
        ydl_opts['writesubtitles'] = True
        ydl_opts['writeautomaticsub'] = True
    
    # Add cookies if specified
    if cookies_browser:
        ydl_opts['cookiesfrombrowser'] = (cookies_browser, None)
    
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:  # type: ignore[arg-type]
            info = ydl.extract_info(url, download=False)
        
        if not info:
            raise ExtractionError("yt-dlp returned empty metadata.")
        
        # Extract transcript if requested
        transcript = None
        transcript_info: Dict[str, Any] = {'transcript_available': False}
        
        if extract_transcript:
            try:
                transcript = extract_transcript_from_info(info, lang=transcript_lang)
                transcript_info = get_transcript_metadata(info, transcript, lang=transcript_lang)
            except Exception as e:
                # Graceful degradation: continue even if transcript fails
                pass
        
        return {
            'metadata': info,
            'transcript': transcript,
            'transcript_info': transcript_info
        }
        
    except Exception as e:
        error_msg = str(e).lower()
        
        # Map common yt-dlp errors to our exception types
        if any(p in error_msg for p in ['age', 'sign in', 'restricted']):
            raise AgeRestrictedError(
                "Video is age restricted. Retry with --cookies-from-browser to provide cookies."
            )
        elif any(p in error_msg for p in ['unavailable', 'private', 'deleted']):
            raise VideoUnavailableError("Video is unavailable, private, or geo-blocked.")
        elif any(p in error_msg for p in ['429', 'rate limit', 'too many requests']):
            raise RateLimitError("YouTube rate limit detected. Please retry later.")
        elif any(p in error_msg for p in ['network', 'connection', 'timeout', 'ssl']):
            raise NetworkError("Network error while contacting YouTube.")
        else:
            raise ExtractionError(f"Failed to extract metadata: {e}")


def _build_command(url: str, cookies_browser: Optional[str]) -> List[str]:
    """
    Build yt-dlp command with safe argument handling.

    Args:
        url: YouTube video URL
        cookies_browser: Optional browser name for cookie extraction

    Returns:
        Command list suitable for subprocess.run() with shell=False
    """
    command: List[str] = [
        "yt-dlp",
        "--dump-json",
        "--skip-download",
        "--no-warnings",
    ]

    if cookies_browser:
        command.extend(["--cookies-from-browser", cookies_browser])

    command.append(url)
    return command


def _run_yt_dlp(command: Sequence[str]) -> subprocess.CompletedProcess[str]:
    """
    Execute yt-dlp subprocess with timeout and error handling.

    Args:
        command: Command list to execute

    Returns:
        CompletedProcess with stdout/stderr captured as strings

    Raises:
        CommandNotFoundError: yt-dlp executable not found
        NetworkError: Subprocess timeout (likely network issue)
    """
    try:
        return subprocess.run(
            command,
            capture_output=True,
            check=False,
            text=True,
            timeout=YT_DLP_TIMEOUT_SECONDS,
            shell=False,  # Security: prevent shell injection
        )
    except FileNotFoundError as exc:
        raise CommandNotFoundError(
            "yt-dlp command not found. Install yt-dlp before running this tool."
        ) from exc
    except subprocess.TimeoutExpired as exc:
        raise NetworkError("yt-dlp timed out while contacting YouTube.") from exc


def _map_error(stderr: str) -> YTObsidianError:
    """
    Parse yt-dlp stderr and raise appropriate exception.

    Args:
        stderr: Error output from yt-dlp

    Returns:
        Appropriate YTObsidianError subclass based on error message
    """
    message = stderr.strip() or "Unknown error"
    lowered = message.lower()

    if any(pattern in lowered for pattern in _AGE_RESTRICTED_PATTERNS):
        return AgeRestrictedError(
            "Video is age restricted. Retry with --cookies-from-browser to provide cookies."
        )

    if any(pattern in lowered for pattern in _VIDEO_UNAVAILABLE_PATTERNS):
        return VideoUnavailableError("Video is unavailable, private, or geo-blocked.")

    if any(pattern in lowered for pattern in _RATE_LIMIT_PATTERNS):
        return RateLimitError("YouTube rate limit detected. Please retry later.")

    if any(pattern in lowered for pattern in _NETWORK_PATTERNS):
        return NetworkError("Network error while contacting YouTube.")

    return ExtractionError(f"Failed to extract metadata: {message}")
