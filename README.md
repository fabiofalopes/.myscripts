# .myscripts

Personal scripts and custom fabric patterns for AI-assisted workflows.

## Installation

Add to `.bashrc`:

```shell
export PATH=$PATH:/home/$USER/.myscripts
```

## Structure

- **Scripts**: Executable tools that orchestrate AI patterns (`txrefine`, `workflow-design`, etc.)
- **fabric-custom-patterns/**: Custom fabric AI patterns used by the scripts
- **docs/**: Documentation and guides
- **tmux/**: tmux configuration and setup scripts

## Utility Scripts

### Audio / Video Download
- **`yta`** - Download audio from YouTube (or any yt-dlp-supported site)
  - Thin wrapper around `yt-dlp` — extracts audio, converts to chosen format, embeds metadata
  - Quick ref: `docs/yta-quickref.md`
  ```bash
  # Single video (default: mp3)
  yta 'https://www.youtube.com/watch?v=K6ALVqwVF7k'

  # opus = smallest/fastest (stream copy, no re-encode) — best for batch archiving
  yta -f opus 'https://www.youtube.com/watch?v=K6ALVqwVF7k'

  # Batch (multiple URLs at once)
  yta -f opus -o ~/Music/podcasts url1 url2 url3

  # Whole channel or playlist
  yta -f opus -p -o ~/yt-audio/dwarkesh "https://www.youtube.com/@DwarkeshPatel/videos"
  ```

### Media Conversion
- **`flac2mp3.sh`** - Bulk convert FLAC audio files to MP3
- **`heic2jpg.sh`** - Bulk convert HEIC images to JPG (ImageMagick/heif-convert)
  - Quick ref: `docs/heic2jpg-quickref.md`

## Scratchpad

Session scratch (handoffs, resume guides, session prompts) lives in `temp/` (local-only, gitignored via `.git/info/exclude`). Agents: see `AGENTS.md` for the scratchpad rule.

## Obsidian Integration (Optional)

To edit patterns in Obsidian while keeping them tracked here:

```bash
# From your Obsidian vault
cd ~/Documents/Obsidian_Vault_01/Vault_01/
ln -s ~/.myscripts/fabric-custom-patterns fabric-custom-patterns
```

This creates a symlink FROM Obsidian TO this repo, allowing you to:
- View and edit patterns in Obsidian's comfortable interface
- Keep patterns versioned with the scripts that depend on them
- Maintain a single source of truth in this repo

## Fabric Configuration

To use these custom patterns with fabric:

```bash
# Link from fabric's patterns directory to this repo
ln -s ~/.myscripts/fabric-custom-patterns ~/.config/fabric/patterns/custom
```

See `NOTES.md` for detailed workflow documentation.
