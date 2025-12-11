#!/usr/bin/env python3
"""
YouTube to Obsidian Metadata Extractor

Extracts YouTube video metadata and generates Obsidian-compatible markdown notes.

Usage:
    yt-obsidian <youtube_url>
    yt-obsidian --help

Example:
    yt-obsidian "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    yt-obsidian --cookies firefox "https://youtu.be/age_restricted_video"
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Optional

import yaml

from lib.exceptions import (
    AgeRestrictedError,
    CommandNotFoundError,
    FileSystemError,
    NetworkError,
    RateLimitError,
    ValidationError,
    VideoUnavailableError,
    YTObsidianError,
)
from lib.extractor import extract_metadata
from lib.filesystem import save_markdown
from lib.formatter import generate_frontmatter, generate_markdown
from lib.validator import validate_url
from lib.fabric_orchestrator import orchestrate_fabric_analysis


def main() -> int:
    """Main entry point for yt-obsidian CLI."""
    parser = create_parser()
    args = parser.parse_args()

    try:
        # Load configuration
        config = load_config()
        
        # Validate URL
        is_valid, normalized_url, video_id = validate_url(args.url)
        if not is_valid:
            print("Error: Invalid YouTube URL", file=sys.stderr)
            return 1

        print(f"Extracting metadata for video ID: {video_id}")

        # Extract metadata and transcript
        result = extract_metadata(
            normalized_url, 
            args.cookies,
            extract_transcript=not args.no_transcript,
            transcript_lang=args.transcript_lang
        )
        
        metadata = result['metadata']
        transcript = result.get('transcript')
        transcript_info = result.get('transcript_info', {})
        
        # Merge transcript info into metadata for front matter
        metadata.update(transcript_info)
        
        # Report transcript status
        if not args.no_transcript:
            if transcript:
                word_count = transcript_info.get('transcript_word_count', 0)
                trans_type = transcript_info.get('transcript_type', 'unknown')
                print(f"✓ Extracted transcript: {word_count} words ({trans_type})")
            else:
                print("⚠ Transcript not available for this video")
        
        # Phase 1C: Fabric Analysis (optional)
        ai_analysis = None
        if should_run_fabric(args, config, transcript) and video_id:
            print()
            # Type guards ensure transcript and video_id are not None here
            assert transcript is not None
            ai_analysis = run_fabric_analysis(
                transcript=transcript,
                video_title=metadata.get("title", "Untitled"),
                video_id=video_id,
                video_duration=int(metadata.get("duration", 0)),
                patterns=getattr(args, 'fabric_patterns', None),
                config=config,
                debug=getattr(args, 'debug', False),
                stream=getattr(args, 'stream', False),
                model=getattr(args, 'model', None)
            )

        # Generate markdown
        frontmatter = generate_frontmatter(metadata)
        markdown = generate_markdown(
            frontmatter, 
            metadata, 
            transcript,
            ai_analysis=ai_analysis
        )

        # Save to file
        output_path = save_markdown(
            markdown,
            metadata.get("title", "Untitled"),
            metadata.get("upload_date", "19700101"),
            args.output,
        )

        print(f"\n✓ Created: {output_path}")
        return 0

    except ValidationError as e:
        print(f"Error: Invalid YouTube URL - {e}", file=sys.stderr)
        return 1

    except CommandNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        print("Install yt-dlp: pip install yt-dlp", file=sys.stderr)
        return 1

    except AgeRestrictedError as e:
        print(f"Error: {e}", file=sys.stderr)
        print("Retry with: yt-obsidian --cookies firefox <url>", file=sys.stderr)
        return 1

    except VideoUnavailableError as e:
        print(f"Error: {e}", file=sys.stderr)
        print("The video may be private, deleted, or geo-blocked.", file=sys.stderr)
        return 1

    except RateLimitError as e:
        print(f"Error: {e}", file=sys.stderr)
        print("YouTube is rate limiting requests. Wait a few minutes and retry.", file=sys.stderr)
        return 1

    except NetworkError as e:
        print(f"Error: {e}", file=sys.stderr)
        print("Check your internet connection and retry.", file=sys.stderr)
        return 1

    except FileSystemError as e:
        print(f"Error: {e}", file=sys.stderr)
        if "OBSVAULT" in str(e):
            print("Set OBSVAULT: export OBSVAULT=/path/to/obsidian/vault", file=sys.stderr)
        return 1

    except YTObsidianError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1

    except KeyboardInterrupt:
        print("\nInterrupted by user", file=sys.stderr)
        return 130

    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        if args.verbose:
            raise
        return 1


def load_config() -> dict:
    """Load configuration from config.yaml."""
    config_path = Path(__file__).parent / "config.yaml"
    
    # Default configuration
    default_config = {
        "fabric": {
            "command": "fabric-ai",
            "patterns": ["youtube_summary"],
            "timeout": 120,
            "enabled": True
        },
        "chunking": {
            "max_chunk_tokens": 8000,
            "overlap_tokens": 200,
            "save_chunks": True
        },
        "output": {
            "use_slug_filenames": True,
            "include_ai_analysis": True,
            "keep_temp_dir": True
        }
    }
    
    # Load user configuration if exists
    if config_path.exists():
        try:
            with open(config_path) as f:
                user_config = yaml.safe_load(f)
                if user_config:
                    # Merge with defaults
                    default_config.update(user_config)
        except Exception:
            # Use defaults if config file is malformed
            pass
    
    return default_config


def should_run_fabric(args, config: dict, transcript: Optional[str]) -> bool:
    """Determine if Fabric analysis should run.
    
    Args:
        args: Parsed command-line arguments
        config: Configuration dict
        transcript: Transcript text (None if not available)
    
    Returns:
        bool: True if Fabric should run
    """
    # Skip if --no-fabric flag set
    if args.no_fabric:
        return False
    
    # Skip if no transcript available
    if not transcript:
        return False
    
    # Skip if disabled in config and no explicit patterns provided
    if not config["fabric"]["enabled"] and not args.fabric_patterns:
        return False
    
    return True


def run_fabric_analysis(
    transcript: str,
    video_title: str,
    video_id: str,
    video_duration: int,
    patterns: Optional[list[str]],
    config: dict,
    debug: bool = False,
    stream: bool = False,
    model: Optional[str] = None
) -> Optional[dict[str, str]]:
    """Run Fabric analysis and return combined outputs.
    
    Args:
        transcript: Full transcript text
        video_title: Video title
        video_id: YouTube video ID
        video_duration: Video duration in seconds
        patterns: Optional list of pattern names (overrides config)
        config: Configuration dict
        debug: Enable debug mode
        stream: Enable streaming mode
        model: Optional LLM model override (e.g., "llama-4-scout")
    
    Returns:
        Dict of pattern_name -> combined_output, or None if failed
    """
    # Determine patterns to run
    if patterns:
        patterns_to_run = patterns
    else:
        patterns_to_run = config["fabric"]["patterns"]
    
    # Get join pattern from config (can be None/empty to skip join phase)
    join_pattern = config["fabric"].get("join_pattern")
    if not join_pattern:
        join_pattern = None  # Normalize empty string to None
    
    # Setup .fabric/ directory
    fabric_dir = Path.cwd() / ".fabric" / video_id
    
    # Show model info if specified
    if model and debug:
        print(f"   Using model: {model}")
    
    try:
        # Run orchestration
        result = orchestrate_fabric_analysis(
            transcript=transcript,
            video_title=video_title,
            video_duration_seconds=video_duration,
            patterns=patterns_to_run,
            join_pattern=join_pattern,
            fabric_command=config["fabric"]["command"],
            max_chunk_tokens=config["chunking"]["max_chunk_tokens"],
            save_dir=fabric_dir if config["chunking"]["save_chunks"] else None,
            debug=debug,
            stream=stream,
            model=model
        )
        
        # Extract combined outputs
        if result.success:
            ai_analysis = {}
            for pattern_name, pattern_result in result.pattern_results.items():
                if pattern_result.success:
                    ai_analysis[pattern_name] = pattern_result.combined_output
            
            return ai_analysis if ai_analysis else None
        else:
            print(f"⚠️  Fabric analysis completed with errors:", file=sys.stderr)
            for error in result.errors:
                print(f"   - {error}", file=sys.stderr)
            return None
    
    except Exception as e:
        print(f"⚠️  Fabric analysis failed: {e}", file=sys.stderr)
        return None


def create_parser() -> argparse.ArgumentParser:
    """Create argument parser for CLI."""
    parser = argparse.ArgumentParser(
        prog="yt-obsidian",
        description="Extract YouTube metadata, transcript, and AI analysis for Obsidian notes",
        epilog="Phase 1C: Complete pipeline with Fabric AI analysis. Use --no-fabric to skip AI processing.",
    )

    parser.add_argument(
        "url",
        help="YouTube video URL (e.g., https://youtube.com/watch?v=...)",
    )

    parser.add_argument(
        "--cookies",
        choices=["firefox", "chrome", "safari", "edge"],
        metavar="BROWSER",
        help="Browser for cookie extraction (for age-restricted videos)",
    )

    parser.add_argument(
        "--output",
        "-o",
        type=Path,
        metavar="DIR",
        help="Output directory (default: $OBSVAULT/youtube)",
    )

    parser.add_argument(
        "--no-transcript",
        action="store_true",
        help="Skip transcript extraction (faster, metadata only)",
    )
    
    parser.add_argument(
        "--transcript-lang",
        default="en",
        metavar="LANG",
        help="Preferred transcript language code (default: en)",
    )
    
    # Phase 1C: Fabric arguments
    parser.add_argument(
        "--no-fabric",
        action="store_true",
        help="Skip Fabric AI analysis (faster, no AI insights)",
    )
    
    parser.add_argument(
        "--fabric-patterns",
        nargs="+",
        metavar="PATTERN",
        help="Fabric patterns to run (overrides config.yaml)",
    )
    
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Enable debug mode: show timing, token counts, metadata details",
    )
    
    parser.add_argument(
        "--stream",
        action="store_true",
        help="Enable streaming mode: see Fabric output in real-time as it generates",
    )
    
    parser.add_argument(
        "--model",
        "-m",
        metavar="MODEL",
        help="LLM model for Fabric (e.g., llama-4-scout, llama-70b, kimi). See 'fabric-ai -L' for list.",
    )

    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Show detailed error information",
    )

    parser.add_argument(
        "--version",
        action="version",
        version="%(prog)s 1.0.0 (Phase 1C - With AI Analysis)",
    )

    return parser


if __name__ == "__main__":
    sys.exit(main())
