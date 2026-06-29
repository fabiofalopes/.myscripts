# BUILD SPEC: obsidian-polish

**Status**: Spec complete. Awaiting implementation.
**Estimated time**: 2-3 hours
**Model**: ytobs architecture (V4.0) + reddit-obsidian patterns

---

## What Is It?

A CLI tool that uses Fabric AI to generate titles, frontmatter, and metadata for Obsidian markdown notes. Modeled on ytobs architecture.

**Source scripts**:
- `obsidian-polish` (905 lines, bash) — full-featured: single file, batch, pipe modes, category detection
- `obsidian-polish-v3` (204 lines, bash) — rewrite prototype using Obsidian CLI (abandoned approach)

**Target**: `~/projetos/hub/obsidian-polish/` (pip-installable Python package)

**v1 features to preserve** (from 905-line bash):
- Single file mode: edit in-place, rename, save to new file
- Batch mode (`-d ./inbox/`): process all .md files in directory
- Pipe mode: stdin → stdout + clipboard
- Three modes: combined (title+frontmatter), title-only, frontmatter-only
- Category detection: tags → frontmatter → title keywords → content keywords
- Datetime handling: preserve original `created`, add `modified`
- Auto-confirm flag (`-y`/`--yes`)
- Category override (`-c dev`)

**What to discard from v3**: Obsidian CLI dependency (too coupled, v1's direct file I/O is universal)

---

## Target Architecture

```
hub/obsidian-polish/
├── pyproject.toml              # Package metadata + deps + entry point
├── LICENSE                     # MIT
├── README.md                   # User docs
├── CONTEXT.md                  # Project context
├── HELP.md                     # Extended command reference
│
├── obsidian_polish/            # Package directory
│   ├── __init__.py             # __version__ = "0.1.0"
│   ├── cli.py                  # Entry point with argparse subcommands
│   ├── config.py               # Config management (~/.obsidian-polish/config.yml)
│   ├── polisher.py             # Core orchestration: run fabric, parse output, build note
│   ├── frontmatter.py          # YAML frontmatter parsing, injection, datetime handling
│   ├── categorizer.py          # Category detection from tags/frontmatter/keywords
│   ├── filesystem.py           # Safe file I/O, slugify, rename
│   ├── fabric_client.py        # Fabric AI integration (shared pattern with reddit-obsidian)
│   └── exceptions.py           # Custom exceptions
│
├── docs/                       # Documentation
├── requirements.txt            # Runtime deps
└── .gitignore
```

---

## pyproject.toml Specification

```toml
[build-system]
requires = ["setuptools>=68.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "obsidian-polish"
version = "0.1.0"
description = "AI-powered Obsidian note polisher — generates titles, frontmatter, and metadata"
readme = "README.md"
license = {file = "LICENSE"}
requires-python = ">=3.10"
authors = [
    {name = "Fábio Lopes"}
]
keywords = ["obsidian", "ai", "notes", "fabric", "frontmatter"]
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
    "pyyaml>=6.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=9.0",
    "mypy>=1.19",
]

[project.scripts]
obsidian-polish = "obsidian_polish.cli:main"
```

**Rationale**: Minimal core deps (just `pyyaml` for frontmatter). AI features use `fabric-ai` CLI (already installed).

---

## Module Specifications

### 1. obsidian_polish/config.py

User config at `~/.obsidian-polish/config.yml`.

Default config:
```yaml
vault_path: ~/Documents/obsidian_vault
default_mode: combined
auto_yes: false
category: note
```

**Functions**:
- `load_config()` → dict with defaults merged
- `ConfigError` exception

### 2. obsidian_polish/exceptions.py

```python
class ObsidianPolishError(Exception): ...
class ConfigError(ObsidianPolishError): ...
class FabricError(ObsidianPolishError): ...
class FileError(ObsidianPolishError): ...
class ParseError(ObsidianPolishError): ...
```

### 3. obsidian_polish/frontmatter.py

YAML frontmatter parsing and injection.

**Functions**:
- `has_frontmatter(content: str) -> bool` — check if content starts with `---`
- `parse_frontmatter(content: str) -> tuple[str | None, str]` — returns (frontmatter_str, body_without_fm)
- `extract_field(frontmatter: str, field: str) -> str | None` — extract specific YAML field value
- `inject_field(frontmatter: str, field: str, value: str) -> str` — add or replace a YAML field
- `build_frontmatter(data: dict) -> str` — build frontmatter string from dict
- `get_original_created(frontmatter: str) -> str | None` — extract original `created` date

**Datetime handling** (preserve from bash v1):
- If existing `created` field found → preserve it, add `modified: today`
- If no `created` → set `created: today`

### 4. obsidian_polish/categorizer.py

Category detection with 4-priority system.

**Valid categories**: `dev`, `meeting`, `idea`, `task`, `doc`, `research`, `personal`, `note`

**Priority order**:
1. Obsidian tags in frontmatter → map tag to category (case-insensitive): `development|coding|programming|dev` → `dev`, `meeting|call|discussion|standup` → `meeting`, etc.
2. Frontmatter `category:` field → validate against valid categories
3. Title keyword matching → regex patterns for each category
4. Content keyword matching (first 50 lines) → same patterns

**Functions**:
- `detect_category(title: str, frontmatter: str | None, content: str) -> str`
- `get_category_from_tag(tag: str) -> str | None`
- `matches_category_keywords(category: str, text: str) -> bool`

### 5. obsidian_polish/filesystem.py

Safe file I/O. Model on ytobs filesystem.py.

**Functions**:
- `safe_write(path: Path, content: str)` — atomic write (write to temp, rename)
- `ensure_dir(path: Path)` — mkdir -p
- `slugify(text: str) -> str` — ASCII transliteration, lowercase, hyphens
- `make_unique_filename(path: Path) -> Path` — add timestamp suffix if collision
- `read_file(path: Path) -> str`

**Slug rules** (from bash v1):
- Convert to ASCII via transliteration
- Replace non-alphanumeric with hyphens
- Lowercase, trim hyphens
- Max 100 chars
- If empty/malformed → `note-<timestamp>`

**Rename pattern**: `{category}-{slug}.md` (e.g., `dev-fix-auth-bug.md`, `meeting-standup-notes.md`)

### 6. obsidian_polish/fabric_client.py

Fabric AI integration. Model on reddit-obsidian fabric_client.py.

**Functions**:
- `get_fabric_command() -> str` — auto-detect `fabric-ai` vs `fabric` vs `mfab`
- `run_title(content: str) -> str` — run `obsidian_note_title` pattern
- `run_frontmatter(content: str) -> str` — run `obsidian_frontmatter_gen` pattern
- `run_polish(content: str) -> tuple[str, str]` — run `obsidian_note_polish` pattern, returns (title, frontmatter)

**Pattern output parsing** (from bash v1):
- `obsidian_note_title` → plain text title
- `obsidian_frontmatter_gen` → YAML frontmatter block
- `obsidian_note_polish` → `TITLE: <title>\nFRONTMATTER:\n<yaml>` format

### 7. obsidian_polish/polisher.py

Core orchestration. Wires together frontmatter, categorizer, fabric_client, filesystem.

**Functions**:
- `polish_file(file: Path, mode: str, rename: bool, category_override: str | None) -> dict` → returns {title, frontmatter, category, path}
- `polish_pipe(content: str, mode: str) -> str` → returns enhanced content
- `build_enhanced_note(title: str, frontmatter: str, body: str) -> str` → assemble final markdown

**Processing flow**:
1. Read file content
2. Detect existing frontmatter
3. Preserve original `created` date if exists
4. Run fabric pattern (combined/title-only/frontmatter-only)
5. Detect category (if rename requested)
6. Inject datetime into frontmatter
7. Inject category into frontmatter
8. Build enhanced note: frontmatter + `# Title` + body (stripping old frontmatter, replacing old H1)
9. Write back to file
10. Rename file if requested: `{category}-{slug}.md`

### 8. obsidian_polish/cli.py

Main entry point with argparse. Model on ytobs cli.py.

**Commands**:
```
obsidian-polish note.md                  # Edit in-place (combined mode)
obsidian-polish note.md -r               # Edit + rename
obsidian-polish note.md -o out.md        # Save to new file
obsidian-polish note.md -t               # Title only
obsidian-polish note.md -f               # Frontmatter only
obsidian-polish -d ./inbox/              # Batch: polish + rename all .md files
obsidian-polish -d ./inbox/ -t           # Batch: title-only
obsidian-polish -d ./inbox/ -c dev       # Batch: force category
cat note.md | obsidian-polish            # Pipe mode (stdout + clipboard)
obsidian-polish --version                # Show version
obsidian-polish --help                   # Full help
```

**Arguments**:
- `file` — positional (optional), markdown file to process
- `-o, --output FILE` — save to different file
- `-r, --rename-file` — rename file based on generated title
- `-d, --dir DIR` — batch mode: process all .md files in directory
- `-c, --category CAT` — override category
- `-t, --title-only` — generate only title
- `-f, --frontmatter-only` — generate only frontmatter
- `-y, --yes` — skip confirmation prompts (auto-yes in batch mode)

**Batch mode behavior**: Auto-yes, auto-rename, non-recursive. Shows progress counter `[1/15]`, summary table.

**Pipe mode**: Auto-detected when stdin is not a tty and no file argument given. Outputs to stdout + copies to clipboard (pbpaste/xclip).

---

## Implementation Order (10 items)

```
PHASE 1: Scaffold
[ ] 1. Create ~/projetos/hub/obsidian-polish/ with pyproject.toml, .gitignore, LICENSE
[ ] 2. Create obsidian_polish/ package dir with __init__.py

PHASE 2: Core Modules
[ ] 3. Implement exceptions.py, config.py, filesystem.py
[ ] 4. Implement frontmatter.py (parse, inject, datetime handling)
[ ] 5. Implement categorizer.py (4-priority detection)
[ ] 6. Implement fabric_client.py (auto-detect fabric binary, parse pattern output)
[ ] 7. Implement polisher.py (orchestration: all modes)

PHASE 3: CLI & Integration
[ ] 8. Implement cli.py with all subcommands and pipe mode

PHASE 4: Packaging & Docs
[ ] 9. Write README.md, CONTEXT.md, HELP.md
[ ] 10. pip install -e . + verify all commands work + add alias to ~/.zshrc
```

---

## What NOT To Do

- Don't depend on Obsidian CLI — use direct file I/O (universal, no app dependency)
- Don't use pydantic — use dataclasses (ytobs convention)
- Don't build incremental update (notes are rewritten in-place)
- Don't implement vault management (out of scope — Obsidian handles that)
- Don't use recursive directory scanning (batch is flat, like v1)

---

## References

- Source scripts: `~/projetos/hub/.myscripts/obsidian-polish` (905 lines) + `obsidian-polish-v3` (204 lines)
- Model package: `~/projetos/hub/ytobs/` (V4.0 architecture)
- Fabric patterns used: `obsidian_note_title`, `obsidian_frontmatter_gen`, `obsidian_note_polish`
- Similar greenfield: `~/projetos/hub/reddit-obsidian/` (same architecture, completed G1)
