# YouTube to Obsidian - Setup Guide

## What This Tool Does

Extracts YouTube videos to AI-enhanced Obsidian notes with ONE command.

```bash
./yt "https://youtube.com/watch?v=VIDEO_ID"
```

Result: Markdown note with metadata, transcript, and AI analysis in your Obsidian vault.

---

## Quick Setup

### 1. Set Obsidian Vault Location
```bash
# Add to ~/.zshrc or ~/.bashrc
export OBSVAULT="/path/to/your/obsidian/vault"

# Reload shell
source ~/.zshrc
```

### 2. Test It Works
```bash
cd ~/projetos/rascunhos/yt-dlp-tests
./yt --help
```

### 3. Run Your First Video
```bash
./yt --quick "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

Check `$OBSVAULT/youtube/` for the generated note.

---

## Usage Modes

### Quick Mode (~25s)
5 essential patterns for fast insights:
```bash
./yt --quick "URL"
```

### Auto Mode (~50s) - Default
Smart pattern selection based on content:
```bash
./yt "URL"
```

### Deep Mode (~70s)
Comprehensive analysis with all patterns:
```bash
./yt --deep "URL"
```

### Preview Mode (instant)
See what patterns would run without executing:
```bash
./yt --preview "URL"
```

---

## Configuration

First run creates `~/.yt-obsidian/config.yml`:

```yaml
mode: auto                # auto, quick, deep
model: kimi              # kimi, llama-4-scout, llama-70b
output_dir: ~/Documents/obsidian_vault/youtube
timeout_per_pattern: 60
chunk_size: 10000
open_in_editor: false
```

Edit to customize your defaults.

---

## What You Get

Every note includes:

1. **YAML Frontmatter**
   - Title, channel, duration, views, likes
   - Upload date, tags, categories
   - Video ID and direct link

2. **Video Description**
   - Full description with links
   - Channel information

3. **Transcript**
   - Complete transcript with timestamps
   - Formatted for readability

4. **AI Analysis** (varies by mode)
   - Wisdom extraction
   - Key insights and patterns
   - Summary and main ideas
   - Quotes and facts
   - Actionable recommendations

---

## Project Structure

```
yt-dlp-tests/
├── yt                 # ⭐ Main command (use this)
├── lib/              # Python modules
├── venv/             # Virtual environment
├── config.yaml       # Default configuration
├── requirements.txt  # Dependencies
├── README.md         # Full documentation
├── CONTEXT.md        # Project state/decisions
├── docs/             # Architecture docs
└── reference/        # Reference materials
```

Hidden directories:
- `_deprecated/` - Old tools (backup only)
- `.fabric/` - Fabric working directory

---

## Troubleshooting

**"OBSVAULT not set"**
```bash
export OBSVAULT="/path/to/vault"
echo $OBSVAULT  # Verify it's set
```

**"Age-restricted video"**
Tool will show clear error. Most videos work without authentication.

**"Slow analysis"**
Use `--quick` mode or faster model:
```bash
./yt --quick "URL"
./yt --model llama-4-scout "URL"
```

---

## Advanced Options

```bash
# Use specific model
./yt --model llama-4-scout "URL"

# Run specific patterns only
./yt --patterns extract_wisdom summary "URL"

# Skip AI analysis (metadata + transcript only)
./yt --no-analysis "URL"

# Custom output directory
./yt --output /custom/path "URL"

# Debug mode
./yt --debug "URL"
```

---

## Available Models

- **kimi** (default) - 10K TPM, balanced quality/speed
- **llama-4-scout** - 30K TPM, fastest
- **llama-70b** - 12K TPM, highest quality

---

## Making It Global

To use `yt` from anywhere:

```bash
# Create symlink
ln -s ~/projetos/rascunhos/yt-dlp-tests/yt ~/.local/bin/yt

# Test it works
yt --version
```

---

## What's in _deprecated/

Old tools kept as backup:
- `yt-obsidian.py` - Original tool (use only if yt breaks)
- `auto-analyze.py` - Pattern selector (now integrated)
- Session docs - Development history

**Don't use these** - they're superseded by `yt`.

---

**Need help?** Check `README.md` for full documentation.
