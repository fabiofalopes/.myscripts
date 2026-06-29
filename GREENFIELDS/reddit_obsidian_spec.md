# BUILD SPEC: reddit-obsidian

**Status**: ✅ IMPLEMENTED. v0.1.0 installed and verified.
**Estimated time**: 3-5 hours (completed)
**Model**: ytobs architecture (ytobs V4.0)

> **⚠️ MAJOR PIVOT**: During implementation, Reddit's public JSON API started returning 403.
> The extractor was rewritten from JSON API → **HTML scraping of old.reddit.com** using BeautifulSoup4.
> See "Implementation Notes" below for details.

---

## What Is It?

A CLI tool to extract Reddit threads into AI-enhanced Obsidian notes. Modeled on ytobs architecture.

**Source script**: `~/projetos/hub/.myscripts/reddit_to_markdown.sh` (120 lines, bash + embedded Python)
**Target**: `~/projetos/hub/reddit-obsidian/` (pip-installable Python package)
**Actual implementation**: HTML scraping via old.reddit.com + BeautifulSoup4

**What was built**:
- 8 Python modules (1,696 lines): extractor, formatter, cache_manager, cli, config, exceptions, filesystem, fabric_client
- Full CLI with subcommands: `fetch`, `status`, `search`, `vault`
- YAML frontmatter + threaded comment markdown output
- Immutable cache with search and stats
- Optional AI analysis via fabric patterns
- Bare URL auto-insert (no need to type `fetch` subcommand)

---

## Implementation Notes (Post-Build)

### Reddit API Landscape (as of 2026-06)

| Endpoint | Status | Notes |
|----------|--------|-------|
| `.json` suffix on www.reddit.com | ❌ 403 Forbidden | Reddit killed public JSON API |
| `www.reddit.com` HTML | ❌ JS verification challenge | Requires browser automation |
| `old.reddit.com` HTML | ✅ 200 OK | Still works, has `data-*` attributes for extraction |

### Key Architecture Decisions

- **Extractor uses BeautifulSoup4** — parses HTML from `old.reddit.com` instead of JSON API
- **`data-*` attributes** on HTML elements mirror old JSON API fields (data-score, data-author, data-subreddit, etc.)
- **Score** available via `data-score` attribute, **upvote_ratio NOT available** in HTML (set to 0.0)
- **Comments** extracted recursively from `.thing.comment` → `.child` tree structure
- **Thread ID** extracted from URL segment after `/comments/` — second-to-last path segment
- **beautifulsoup4** added as core dependency (was not in original spec)
- **Cache is global** (not per --output dir) — acceptable design limitation

---

## Target Architecture

```
hub/reddit-obsidian/
├── pyproject.toml              # Package metadata + deps + entry point
├── LICENSE                     # MIT
├── README.md                   # User docs
├── CONTEXT.md                  # Project context
├── HELP.md                     # Extended command reference
│
├── reddit_obsidian/            # Package directory
│   ├── __init__.py             # __version__ = "0.1.0"
│   ├── cli.py                  # Entry point with argparse (main + create_parser)
│   ├── config.py               # Config management (~/.reddit-obsidian/config.yml)
│   ├── extractor.py            # Reddit JSON API client
│   ├── formatter.py            # YAML frontmatter + markdown generation
│   ├── cache_manager.py        # Duplicate prevention, incremental updates
│   ├── exceptions.py           # Custom exceptions
│   ├── filesystem.py           # Safe file I/O
│   └── fabric_client.py        # Fabric AI integration for content analysis
│
├── docs/                       # Documentation
├── requirements.txt            # Runtime deps
├── config.yaml                 # Default config template
└── .gitignore
```

---

## pyproject.toml Specification

```toml
[build-system]
requires = ["setuptools>=68.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "reddit-obsidian"
version = "0.1.0"
description = "Extract Reddit threads to Obsidian notes with AI analysis"
readme = "README.md"
license = {file = "LICENSE"}
requires-python = ">=3.10"
authors = [
    {name = "Fábio Lopes"}
]
keywords = ["reddit", "obsidian", "ai", "content-extraction", "knowledge-management"]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Environment :: Console",
    "Intended Audience :: End Users/Desktop",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
dependencies = [
    "requests>=2.28.0",
    "pyyaml>=6.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=9.0",
    "mypy>=1.19",
]
ai = [
    "tiktoken>=0.5.0",
    "tenacity>=8.0.0",
]

[project.scripts]
reddit-obsidian = "reddit_obsidian.cli:main"
```

**Rationale**: Keep core deps minimal (requests, pyyaml). AI features optional via `pip install reddit-obsidian[ai]`.

---

## Module Specifications

### 1. reddit_obsidian/config.py

Model on ytobs config. User config at `~/.reddit-obsidian/config.yml`.

Default config:
```yaml
output_dir: ~/Documents/obsidian_vault/reddit
ai_analysis: false
ai_provider: groq
ai_model: kimi
open_in_editor: false
```

**Functions**:
- `load_config()` → dict with defaults merged
- `ConfigError` exception

### 2. reddit_obsidian/extractor.py

Reddit JSON API client that replaces the curl + embedded Python approach.

**Functions**:
- `fetch_thread(url: str, comments_only: bool = False) -> dict` — fetches Reddit JSON API, returns parsed data dict
- `extract_post_data(raw_data: dict) -> dict` — extracts title, author, subreddit, score, num_comments, created_utc, selftext, permalink, url
- `extract_comments(raw_data: dict) -> list` — extracts threaded comments with author, body, score, replies (nested)
- `prepare_url(url: str) -> str` — strip query params, trailing slash, append .json

**Headless** — no auth required. Reddit's public JSON API at `https://www.reddit.com/r/{subreddit}/comments/{id}.json`.
Set User-Agent header to something reasonable (not default curl).

**Error handling**: Handle 404 (thread deleted), 429 (rate limited), invalid URL, JSON decode errors.

### 3. reddit_obsidian/formatter.py

Generates Obsidian markdown with YAML frontmatter.

**Post format**:
```markdown
---
title: "The title"
source: Reddit
url: https://reddit.com/r/...
subreddit: r/AskReddit
author: /u/username
score: 1234
num_comments: 50
created_utc: 1234567890
date_created: 2026-01-15 10:30:00 UTC
scraped_date: 2026-05-30 12:00:00 UTC
tags: ["reddit", "AskReddit"]
---

# The Title

**Author:** /u/username | **Subreddit:** r/AskReddit | **Score:** 1234 | **Comments:** 50

[Post self text...]

---

## Comments

- **Author1** (*Score: 100*):
  > Comment body text
    
    - **Author2** (*Score: 50*):
      > Nested reply text
```

**Comments-only mode**:
```markdown
## Comments

- **Author1** (*Score: 100*):
  > Comment body
```

**Functions**:
- `format_post(data: dict) -> str` — full post with frontmatter + comments
- `format_comment(comment: dict, level: int = 0) -> str` — recursive threaded formatting
- `format_comments_only(comments: list) -> str` — just the comments section
- `make_slug(title: str) -> str` — slugify for filename

**Filename**: `{date}_reddit_{slug}.md` e.g. `2026-01-15_reddit_best-tips-for-python.md`

### 4. reddit_obsidian/cache_manager.py

Duplicate prevention. Model on ytobs cache_manager.py.

**Cache location**: `$OBSVAULT/reddit/.cache/` (or config's output_dir/.cache/)
**Cache by**: Reddit thread ID (extracted from URL)
**Cache entry**: `{thread_id}.json` with url, title, subreddit, fetched_at, filepath

**Functions**:
- `CacheEntry` dataclass
- `CacheManager(cache_dir: Path)` class
- `get(thread_id: str) -> Optional[CacheEntry]` — lookup
- `put(entry: CacheEntry)` — save
- `list_all() -> list[CacheEntry]` — all cached threads
- `exists(thread_id: str) -> bool` — check

### 5. reddit_obsidian/exceptions.py

```python
class RedditObsidianError(Exception): ...
class ConfigError(RedditObsidianError): ...
class FetchError(RedditObsidianError): ...
class ParseError(RedditObsidianError): ...
class CacheError(RedditObsidianError): ...
```

### 6. reddit_obsidian/filesystem.py

Safe file I/O. Model on ytobs filesystem.py.

**Functions**:
- `safe_write(path: Path, content: str)` — atomic write to prevent corruption
- `ensure_dir(path: Path)` — mkdir -p
- `make_unique_filename(path: Path) -> Path` — add (2), (3) suffix if exists
- `read_file(path: Path) -> str`

### 7. reddit_obsidian/fabric_client.py

Optional AI analysis via fabric patterns.

**Functions**:
- `analyze_content(text: str, patterns: list[str]) -> str` — run fabric patterns on thread
- `AVAILABLE_PATTERNS` — list of relevant patterns: extract_wisdom, summary, analyze_claims, etc.

**Config integration**: Only runs if `ai_analysis: true` in config. Uses `fabric-ai` CLI command.

### 8. reddit_obsidian/cli.py

Main entry point with argparse. Model on ytobs cli.py.

**Commands**:
```
reddit-obsidian URL                          # Process a Reddit thread
reddit-obsidian URL --comments-only          # Comments only
reddit-obsidian URL --ai                     # With AI analysis
reddit-obsidian status THREAD_ID             # Show cached status
reddit-obsidian search QUERY                 # Search cached threads
reddit-obsidian vault                        # Vault statistics
reddit-obsidian --list-processed             # List all cached
reddit-obsidian --version                    # Show version
reddit-obsidian --help                       # Full help
```

**Arguments**:
- `url` — positional, Reddit thread URL
- `--comments-only, -c` — comments only mode
- `--ai` — enable AI analysis
- `--patterns P1 P2` — specific fabric patterns
- `--output DIR` — override output directory
- `--force` — re-fetch even if cached

**Subcommands** (subparsers):
- `status THREAD_ID` — show cache status
- `search QUERY` — search cached threads
- `vault` — show statistics

---

## CLI Flow

```
URL → prepare_url() → fetch_thread() → extract_post_data()
    → check cache (exists? skip/force)
    → format_post() / format_comments_only()
    → save to output_dir/{date}_reddit_{slug}.md
    → cache entry saved
    → (optional) fabric_client.analyze_content()
    → print output path
```

---

## Discussion: Cache system

Since Reddit threads don't change (unlike YouTube videos which can have new comments), caching is simpler:
- No incremental append needed (thread is immutable after creation)
- Cache just prevents duplicate API calls
- `--force` to re-fetch (e.g. if thread was updated with edits)

---

## Implementation Order (10 items) — ALL COMPLETE ✅

```
PHASE 1: Scaffold
[✅] 1. Create ~/projetos/hub/reddit-obsidian/ with pyproject.toml, .gitignore, LICENSE
[✅] 2. Create reddit_obsidian/ package dir with __init__.py

PHASE 2: Core Modules
[✅] 3. Implement exceptions.py, config.py, filesystem.py
[✅] 4. Implement extractor.py (HTML scraping via old.reddit.com — JSON API is dead)
[✅] 5. Implement formatter.py (YAML frontmatter + threaded comments)
[✅] 6. Implement cache_manager.py

PHASE 3: CLI & Integration
[✅] 7. Implement cli.py with all subcommands
[✅] 8. Implement fabric_client.py (optional AI analysis)

PHASE 4: Packaging & Docs
[✅] 9. Write requirements.txt, README.md, CONTEXT.md, HELP.md
[✅] 10. pip install -e . + verify all commands work (E2E test with real AskReddit thread)
```

---

## What NOT To Do

- ~~Don't add praw/pushshift dependencies — use Reddit's free JSON API~~ → **JSON API is dead. Using HTML scraping.**
- Don't implement OAuth — not needed for public threads
- Don't build incremental update (threads are immutable)
- Don't build playlists/collections (out of scope)
- Don't use pydantic — use dataclasses (ytobs convention)
- ~~Don't use selenium/browser automation — JSON API is sufficient~~ → **old.reddit.com works without browser.**

---

## References

- Source script: `~/projetos/hub/.myscripts/reddit_to_markdown.sh`
- Model package: `~/projetos/hub/ytobs/` (ytobs V4.0 architecture)
- Reddit JSON API: `https://www.reddit.com/r/{subreddit}/comments/{id}.json`
- Audit: `~/projetos/hub/.myscripts/MYSCRIPTS_AUDIT_AND_EXTRACTION_PLAN.md` § Table 2
