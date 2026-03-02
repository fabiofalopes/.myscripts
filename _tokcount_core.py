#!/usr/bin/env python3
"""
tokcount core — streaming token count estimation for LLM context planning.

Design principles:
  - NEVER load entire files into memory
  - Stream in chunks (256KB default)
  - Fast estimate by default (chars/4), exact tokenizer optional
  - All output to stdout, all diagnostics to stderr
"""

import sys
import os
import json
import argparse

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

CHUNK_SIZE = 256 * 1024  # 256KB chunks for streaming

# Heuristic ratios (chars per token, English text)
RATIO_ENGLISH_PROSE = 4.0
RATIO_CODE = 3.0
RATIO_MIXED = 3.7  # reasonable middle ground

# Default tokenizer for accurate mode
DEFAULT_TOKENIZER = "cl100k_base"

# ---------------------------------------------------------------------------
# Model context window database (tokens)
# ---------------------------------------------------------------------------

MODEL_CONTEXTS = {
    # OpenAI
    "gpt-4o": 128_000,
    "gpt-4o-mini": 128_000,
    "gpt-4.1": 1_047_576,
    "gpt-4.1-mini": 1_047_576,
    "gpt-4.1-nano": 1_047_576,
    "gpt-4-turbo": 128_000,
    "o3": 200_000,
    "o3-mini": 200_000,
    "o4-mini": 200_000,
    "gpt-4": 8_192,
    "gpt-3.5-turbo": 16_385,
    # Anthropic
    "claude-4-opus": 200_000,
    "claude-4-sonnet": 200_000,
    "claude-3.5-sonnet": 200_000,
    "claude-3.5-haiku": 200_000,
    "claude-3-opus": 200_000,
    "claude-3-sonnet": 200_000,
    "claude-3-haiku": 200_000,
    # Meta Llama
    "llama-4-scout": 10_000_000,
    "llama-4-maverick": 1_000_000,
    "llama-3.3-70b": 128_000,
    "llama-3.1-405b": 128_000,
    "llama-3.1-70b": 128_000,
    "llama-3.1-8b": 128_000,
    # Mistral
    "mistral-large": 128_000,
    "mistral-medium": 32_000,
    "mistral-small": 32_000,
    "mistral-7b": 32_000,
    "devstral": 128_000,
    "codestral": 256_000,
    # Qwen
    "qwen-3": 128_000,
    "qwen-2.5": 128_000,
    "qwen-2.5-coder": 128_000,
    # Google
    "gemini-2.5-pro": 1_000_000,
    "gemini-2.5-flash": 1_000_000,
    "gemini-2.0-flash": 1_000_000,
    "gemini-1.5-pro": 2_000_000,
    # DeepSeek
    "deepseek-v3": 128_000,
    "deepseek-r1": 128_000,
    # Microsoft
    "phi-4": 16_384,
    "phi-4-mini": 128_000,
    # Other
    "minimax-m2.1": 1_000_000,
    "glm-4": 128_000,
    "grok-2": 128_000,
}

# Tokenizer mapping: which encoding to use for which model family
MODEL_TOKENIZER = {
    # OpenAI GPT-4o family uses o200k_base
    "gpt-4o": "o200k_base",
    "gpt-4o-mini": "o200k_base",
    "gpt-4.1": "o200k_base",
    "gpt-4.1-mini": "o200k_base",
    "gpt-4.1-nano": "o200k_base",
    "o3": "o200k_base",
    "o3-mini": "o200k_base",
    "o4-mini": "o200k_base",
    # GPT-4 / 3.5 use cl100k_base
    "gpt-4": "cl100k_base",
    "gpt-4-turbo": "cl100k_base",
    "gpt-3.5-turbo": "cl100k_base",
}


def get_tokenizer_for_model(model_name):
    """Return the tiktoken encoding name for a given model, or default."""
    return MODEL_TOKENIZER.get(model_name, DEFAULT_TOKENIZER)


# ---------------------------------------------------------------------------
# Streaming character/byte counter
# ---------------------------------------------------------------------------


def count_chars_stream(source):
    """
    Count characters by streaming from a file path or stdin.
    Returns (char_count, byte_count).
    Never loads more than CHUNK_SIZE into memory.
    """
    char_count = 0
    byte_count = 0

    if source == "-":
        # Read from stdin in binary chunks
        buf = sys.stdin.buffer
        decoder_buffer = b""
        while True:
            chunk = buf.read(CHUNK_SIZE)
            if not chunk:
                # Handle any remaining bytes in decoder buffer
                if decoder_buffer:
                    try:
                        text = decoder_buffer.decode("utf-8", errors="replace")
                        char_count += len(text)
                    except Exception:
                        char_count += len(decoder_buffer)
                break
            byte_count += len(chunk)
            # Combine with any leftover bytes from previous chunk
            data = decoder_buffer + chunk
            # Find the last valid UTF-8 boundary
            # Try decoding; if it fails at the end, keep tail bytes
            try:
                text = data.decode("utf-8")
                decoder_buffer = b""
            except UnicodeDecodeError:
                # Keep up to 4 trailing bytes that might be incomplete UTF-8
                for i in range(1, min(5, len(data) + 1)):
                    try:
                        text = data[:-i].decode("utf-8")
                        decoder_buffer = data[-i:]
                        break
                    except UnicodeDecodeError:
                        continue
                else:
                    text = data.decode("utf-8", errors="replace")
                    decoder_buffer = b""
            char_count += len(text)
    else:
        # Read from file
        file_size = os.path.getsize(source)
        byte_count = file_size
        with open(source, "rb") as f:
            decoder_buffer = b""
            while True:
                chunk = f.read(CHUNK_SIZE)
                if not chunk:
                    if decoder_buffer:
                        try:
                            text = decoder_buffer.decode("utf-8", errors="replace")
                            char_count += len(text)
                        except Exception:
                            char_count += len(decoder_buffer)
                    break
                data = decoder_buffer + chunk
                try:
                    text = data.decode("utf-8")
                    decoder_buffer = b""
                except UnicodeDecodeError:
                    for i in range(1, min(5, len(data) + 1)):
                        try:
                            text = data[:-i].decode("utf-8")
                            decoder_buffer = data[-i:]
                            break
                        except UnicodeDecodeError:
                            continue
                    else:
                        text = data.decode("utf-8", errors="replace")
                        decoder_buffer = b""
                char_count += len(text)

    return char_count, byte_count


# ---------------------------------------------------------------------------
# Streaming accurate token counter (tiktoken)
# ---------------------------------------------------------------------------


def count_tokens_accurate_stream(source, encoding_name=DEFAULT_TOKENIZER):
    """
    Count tokens by streaming chunks through tiktoken.
    Returns (token_count, char_count, byte_count).

    Chunk boundary tokens: we accept negligible error (~1 token per chunk
    boundary = ~0.006% for a 1GB file). The alternative (overlapping buffers)
    adds complexity for zero practical benefit.
    """
    try:
        import tiktoken
    except ImportError:
        print(
            "error: tiktoken not installed. Install with: pip install tiktoken",
            file=sys.stderr,
        )
        sys.exit(2)

    enc = tiktoken.get_encoding(encoding_name)

    token_count = 0
    char_count = 0
    byte_count = 0

    def process_stream(read_func):
        nonlocal token_count, char_count, byte_count
        decoder_buffer = b""
        while True:
            chunk = read_func(CHUNK_SIZE)
            if not chunk:
                if decoder_buffer:
                    try:
                        text = decoder_buffer.decode("utf-8", errors="replace")
                        char_count += len(text)
                        token_count += len(enc.encode(text, disallowed_special=()))
                    except Exception:
                        char_count += len(decoder_buffer)
                break
            byte_count += len(chunk)
            data = decoder_buffer + chunk
            try:
                text = data.decode("utf-8")
                decoder_buffer = b""
            except UnicodeDecodeError:
                for i in range(1, min(5, len(data) + 1)):
                    try:
                        text = data[:-i].decode("utf-8")
                        decoder_buffer = data[-i:]
                        break
                    except UnicodeDecodeError:
                        continue
                else:
                    text = data.decode("utf-8", errors="replace")
                    decoder_buffer = b""
            char_count += len(text)
            token_count += len(enc.encode(text, disallowed_special=()))

    if source == "-":
        process_stream(sys.stdin.buffer.read)
    else:
        byte_count = os.path.getsize(source)
        saved_byte_count = byte_count
        byte_count = 0  # will be re-counted in stream
        with open(source, "rb") as f:
            process_stream(f.read)
        byte_count = saved_byte_count

    return token_count, char_count, byte_count


# ---------------------------------------------------------------------------
# Directory walking
# ---------------------------------------------------------------------------


def walk_files(path, recursive=False):
    """Yield file paths under a directory. Non-recursive by default."""
    if os.path.isfile(path):
        yield path
        return
    if not os.path.isdir(path):
        return
    if recursive:
        for root, _dirs, files in os.walk(path):
            for f in sorted(files):
                fp = os.path.join(root, f)
                if os.path.isfile(fp):
                    yield fp
    else:
        for entry in sorted(os.listdir(path)):
            fp = os.path.join(path, entry)
            if os.path.isfile(fp):
                yield fp


# ---------------------------------------------------------------------------
# Formatting helpers
# ---------------------------------------------------------------------------


def fmt_size(nbytes):
    """Human-readable byte size."""
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if abs(nbytes) < 1024.0:
            if unit == "B":
                return f"{nbytes} {unit}"
            return f"{nbytes:.1f} {unit}"
        nbytes /= 1024.0
    return f"{nbytes:.1f} PB"


def fmt_num(n):
    """Format number with thousand separators."""
    return f"{n:,}"


def fmt_tokens_short(n):
    """Format token count in K/M notation."""
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.1f}K"
    return str(n)


def check_model_fit(token_count, models=None):
    """
    Check if token count fits in specified models' context windows.
    Returns list of (model, context_size, fits, overflow).
    If models is None, check a representative set.
    """
    if models:
        check_list = []
        for m in models:
            m_lower = m.lower().strip()
            # Try exact match first, then fuzzy
            if m_lower in MODEL_CONTEXTS:
                check_list.append((m_lower, MODEL_CONTEXTS[m_lower]))
            else:
                # Try partial match
                matches = [
                    (k, v)
                    for k, v in MODEL_CONTEXTS.items()
                    if m_lower in k or k in m_lower
                ]
                if matches:
                    check_list.extend(matches)
                else:
                    print(f"warning: unknown model '{m}', skipping", file=sys.stderr)
    else:
        # Default representative set
        representative = [
            "gpt-4o",
            "gpt-4.1",
            "claude-3.5-sonnet",
            "llama-3.1-8b",
            "gemini-2.5-pro",
            "mistral-7b",
        ]
        check_list = [
            (m, MODEL_CONTEXTS[m]) for m in representative if m in MODEL_CONTEXTS
        ]

    results = []
    for model, ctx_size in check_list:
        fits = token_count <= ctx_size
        overflow = token_count - ctx_size if not fits else 0
        results.append((model, ctx_size, fits, overflow))
    return results


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main():
    parser = argparse.ArgumentParser(
        prog="tokcount",
        description="Estimate token counts for LLM context planning.",
        add_help=False,  # We handle -h in bash wrapper
    )
    parser.add_argument(
        "files", nargs="*", default=[], help="Files to count (use - or omit for stdin)"
    )
    parser.add_argument(
        "-a", "--accurate", action="store_true", help="Use tiktoken for accurate count"
    )
    parser.add_argument(
        "-m",
        "--model",
        action="append",
        default=None,
        help="Check fit against model context window",
    )
    parser.add_argument(
        "-q", "--quiet", action="store_true", help="Output only the token number"
    )
    parser.add_argument(
        "-r", "--recursive", action="store_true", help="Recurse into directories"
    )
    parser.add_argument("--json", action="store_true", help="JSON output")
    parser.add_argument(
        "-t",
        "--tokenizer",
        default=None,
        help="Tokenizer encoding (cl100k_base, o200k_base)",
    )
    parser.add_argument("-h", "--help", action="store_true", help="Show help")
    parser.add_argument(
        "--list-models", action="store_true", help="List known models and context sizes"
    )

    args = parser.parse_args()

    if args.help:
        parser.print_help()
        sys.exit(0)

    if args.list_models:
        # Sort by context size descending
        for model, ctx in sorted(MODEL_CONTEXTS.items(), key=lambda x: (-x[1], x[0])):
            print(f"  {model:25s} {fmt_tokens_short(ctx):>8s} ({fmt_num(ctx)} tokens)")
        sys.exit(0)

    # Determine tokenizer
    encoding_name = args.tokenizer or DEFAULT_TOKENIZER
    if args.model and not args.tokenizer:
        # Use the tokenizer appropriate for the first specified model
        encoding_name = get_tokenizer_for_model(args.model[0])

    # Determine sources
    sources = []
    if not args.files or args.files == ["-"]:
        sources = ["-"]
    else:
        for f in args.files:
            if os.path.isdir(f):
                sources.extend(walk_files(f, recursive=args.recursive))
            elif os.path.isfile(f):
                sources.append(f)
            else:
                print(f"warning: '{f}' not found, skipping", file=sys.stderr)

    if not sources:
        print("error: no input files found", file=sys.stderr)
        sys.exit(1)

    all_results = []
    total_tokens_est = 0
    total_tokens_acc = 0
    total_chars = 0
    total_bytes = 0

    for source in sources:
        result = {"source": source if source != "-" else "<stdin>"}

        if args.accurate:
            tokens_acc, chars, nbytes = count_tokens_accurate_stream(
                source, encoding_name
            )
            tokens_est = max(1, round(chars / RATIO_ENGLISH_PROSE))
            result["bytes"] = nbytes
            result["chars"] = chars
            result["tokens_estimated"] = tokens_est
            result["tokens_accurate"] = tokens_acc
            result["tokenizer"] = encoding_name
            total_tokens_acc += tokens_acc
            total_tokens_est += tokens_est
        else:
            chars, nbytes = count_chars_stream(source)
            tokens_est = max(1, round(chars / RATIO_ENGLISH_PROSE))
            result["bytes"] = nbytes
            result["chars"] = chars
            result["tokens_estimated"] = tokens_est
            total_tokens_est += tokens_est

        total_chars += result["chars"]
        total_bytes += result["bytes"]
        all_results.append(result)

    # Determine the "primary" token count for model checks
    primary_tokens = total_tokens_acc if args.accurate else total_tokens_est

    # Model fit checks
    model_checks = []
    if args.model:
        model_checks = check_model_fit(primary_tokens, args.model)
    elif not args.quiet and not args.json:
        # Show default representative set if not quiet
        model_checks = check_model_fit(primary_tokens)

    # -----------------------------------------------------------------------
    # Output
    # -----------------------------------------------------------------------

    if args.quiet:
        # Just the number
        print(primary_tokens)
        sys.exit(0)

    if args.json:
        output = {
            "files": all_results,
            "total": {
                "bytes": total_bytes,
                "chars": total_chars,
                "tokens_estimated": total_tokens_est,
            },
        }
        if args.accurate:
            output["total"]["tokens_accurate"] = total_tokens_acc
            output["total"]["tokenizer"] = encoding_name
        if model_checks:
            output["model_checks"] = [
                {
                    "model": m,
                    "context_window": ctx,
                    "fits": fits,
                    "overflow": overflow,
                }
                for m, ctx, fits, overflow in model_checks
            ]
        json.dump(output, sys.stdout, indent=2)
        print()  # trailing newline
        sys.exit(0)

    # --- Human-readable output ---
    multi = len(all_results) > 1

    for r in all_results:
        src = r["source"]
        if src != "<stdin>":
            print(f"file:         {src}")
        print(f"size:         {fmt_size(r['bytes'])}")
        print(f"chars:        {fmt_num(r['chars'])}")
        print(f"tokens (est): ~{fmt_num(r['tokens_estimated'])}")
        if args.accurate:
            print(f"tokens ({encoding_name}): {fmt_num(r['tokens_accurate'])}")
        if multi:
            print()

    if multi:
        print(f"--- total ---")
        print(f"files:        {len(all_results)}")
        print(f"size:         {fmt_size(total_bytes)}")
        print(f"chars:        {fmt_num(total_chars)}")
        print(f"tokens (est): ~{fmt_num(total_tokens_est)}")
        if args.accurate:
            print(f"tokens ({encoding_name}): {fmt_num(total_tokens_acc)}")

    # Model fit
    if model_checks:
        print()
        for model, ctx, fits, overflow in model_checks:
            ctx_short = fmt_tokens_short(ctx)
            if fits:
                print(f"CTX_FIT:{model}:{ctx_short}:OK")
            else:
                over_short = fmt_tokens_short(overflow)
                print(f"CTX_FIT:{model}:{ctx_short}:OVER:{over_short}")


if __name__ == "__main__":
    main()
