# YTA Quick Reference

**Script**: `yta`
**Status**: 🟢 Working
**Wraps**: `yt-dlp` (with `ffmpeg` for re-encoding)
**Purpose**: Download audio from YouTube or any yt-dlp-supported site — extract audio, convert to a chosen format, embed metadata, clean filenames.

---

## Quick Commands

```bash
# Single video (default format: mp3, default output: ~/yt-audio)
yta 'https://www.youtube.com/watch?v=K6ALVqwVF7k'

# opus — smallest + fastest (stream copy, no re-encode)
yta -f opus 'https://www.youtube.com/watch?v=K6ALVqwVF7k'

# Custom output directory
yta -f opus -o ~/Music/podcasts 'https://youtu.be/abc123'

# Batch — multiple URLs at once
yta -f opus url1 url2 url3

# Whole channel or playlist (use -p)
yta -f opus -p -o ~/yt-audio/dwarkesh "https://www.youtube.com/@DwarkeshPatel/videos"

# Age-gated / member-only (needs cookies file)
yta -c cookies.txt 'https://www.youtube.com/watch?v=xyz'

# Built-in help
yta -h
```

---

## Choosing a Format

| Format | Re-encode? | Size | Use Case |
|--------|-----------|------|----------|
| **`opus`** | No (stream copy) | **Smallest** | Batch archiving, podcasts, raw tests — **recommended default for efficiency** |
| **`best`** | No (stream copy) | Smallest | Same as opus on YouTube (its native codec is opus) |
| `mp3` | Yes | Larger | Max compatibility (older players, some editors) |
| `m4a` | Yes | Larger | Apple ecosystem |
| `aac` | Yes | Larger | Same |
| `wav` | Yes | Largest | Lossless editing |
| `flac` | Yes | Large | Lossless archival |

**Key insight**: YouTube serves audio as `opus` (webm) natively. `-f opus` does a **stream copy** —
yt-dlp grabs the opus stream and remuxes to an `.opus` (ogg) file. No re-encoding = no quality
loss, smallest files, fastest downloads. mp3/m4a force ffmpeg re-encoding (bigger + slower).

**Measured efficiency** (validated 2026-07-30, Dwarkesh Patel podcast batch):
- ~50–55 MB per hour of audio at opus
- A 1h43m podcast = ~83 MB
- A full channel (~200 videos, ~150–200h) ≈ 8–11 GB

---

## Channel / Playlist Workflow

The standard pattern: **list first** (see what you're getting), **then download**.

### Step 1 — List all videos from a channel

`yta` downloads but doesn't list. Use `yt-dlp` directly for a flat listing (no download):

```bash
# Print video ID | duration | title for every video on the channel
yt-dlp --flat-playlist \
  --remote-components ejs:github \
  --print "%(id)s | %(duration_string)s | %(title)s" \
  "https://www.youtube.com/@DwarkeshPatel/videos"
```

### Step 2 — Download everything (opus)

```bash
yta -f opus -p -o ~/yt-audio/dwarkesh "https://www.youtube.com/@DwarkeshPatel/videos"
```

The `-p` flag adds `--yes-playlist`, so a channel/playlist URL downloads all uploads.

### Step 3 — Download a curated batch

Feed a subset of URLs directly (one per line in a file, or inline):

```bash
# From a file
yta -f opus -o ~/yt-audio/dwarkesh $(cat my_urls.txt)

# Inline
yta -f opus -o ~/yt-audio/dwarkesh \
  https://www.youtube.com/watch?v=ID1 \
  https://www.youtube.com/watch?v=ID2
```

---

## Options Reference

| Flag | Description | Default |
|------|-------------|---------|
| `-f FMT` | Audio format: `mp3 opus m4a aac wav flac best` | `mp3` |
| `-o DIR` | Output directory | `~/yt-audio` |
| `-c FILE` | Cookies file (for restricted content) | none |
| `-p` | Allow playlist/channel download | off (single video) |
| `-h` | Show help | — |

---

## File Locations

| File | Path | Purpose |
|------|------|---------|
| **Script** | `~/.myscripts/yta` | Main executable |
| **Quick Ref** | `~/.myscripts/docs/yta-quickref.md` | This file |
| **Default output** | `~/yt-audio/` | Downloaded audio |
| **Fabric env** | `~/.config/fabric/.env` | Provider API keys (managed by `fabric-ai --setup`) |

---

## Dependencies

### Installation

**macOS**:
```bash
brew install yt-dlp ffmpeg deno
```

**Debian/Ubuntu**:
```bash
sudo apt install yt-dlp ffmpeg deno
```

### Verification
```bash
yt-dlp --version    # keep this recent — YouTube changes weekly
ffmpeg -version
deno --version      # JS runtime: YouTube needs it to descramble media URLs
```

> yt-dlp is the only hard dependency. ffmpeg is needed for re-encoding
> formats (mp3/m4a/aac/wav/flac) but **not** for `opus`/`best`. A JS
> runtime (deno/node/bun) is required for YouTube — without one,
> downloads fail with HTTP 403.

---

## Troubleshooting

### Downloads fail with HTTP 403
YouTube changed something. Update first:
```bash
pip3 install -U --break-system-packages yt-dlp   # or: yt-dlp -U
```

### "no JavaScript runtime found"
YouTube needs deno/node/bun to descramble media URLs:
```bash
brew install deno
```

### Finished but saved no audio (⚠ warning)
Bad URL, region-blocked, or empty/private video. Check the URL is public.
For region-locked or age-gated content, supply a cookies file (`-c`).

### Cookies / member-only videos
Export cookies from your browser (e.g. via a "cookies.txt" extension) and pass with `-c`:
```bash
yta -c cookies.txt 'https://www.youtube.com/watch?v=xyz'
```

---

## Tips

- **`-f opus` is almost always the right choice** — smallest files, no quality loss, no re-encode.
- For a long batch run, `yta` has no `--download-archive` support, so an interrupted
  run will re-download finished files. For very large batches, consider running `yt-dlp`
  directly with `--download-archive archive.txt` for resume + skip-existing.
- The script enables yt-dlp's EJS challenge solver (`--remote-components ejs:github`),
  which pulls a small script from the official yt-dlp/ejs repo on first use (then cached).
- Output filenames use the video title: `<title>.<ext>`. Metadata (title/artist/date) is embedded.

---

**Created**: 2026-07-30
**Last Updated**: 2026-07-30
