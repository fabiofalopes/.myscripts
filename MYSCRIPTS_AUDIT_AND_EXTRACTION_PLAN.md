# .myscripts/ — Full Audit & Extraction Plan

**Generated**: 2026-05-30
**Status**: Assessment complete. Awaiting execution order.
**Total entries**: 77 → 42 meaningful (excluding dotfiles, git, cache, backups)

---

## Table 1: EXTRACTION CANDIDATES (Full Apps → Move to hub/)

Projects with modular structure (lib/, config, docs, workflows) that deserve standalone repos.

### Tier A — Production-Ready, Extract NOW

| # | Project | Lines/Scope | lib/ | reqs | Tests | What It Does | Destination |
|---|---------|-------------|------|------|-------|-------------|-------------|
| 1 | **youtube-obsidian** | 18 modules, ~3K Python, 1022-line CLI | ✅ | ✅ | ❌ | YouTube → Obsidian AI notes. V4.0. Smart cache, incremental updates, pattern routing, 76 cached videos. | `hub/ytobs/` |

### Tier B — Substantial, Extract After ytobs

| # | Project | Scope | lib/ | reqs | Tests | What It Does | Destination |
|---|---------|-------|------|------|-------|-------------|-------------|
| 2 | **fabric-graph-agents** | 45+ files, 4 agents, 9 lib scripts, full docs | ✅ shell | ❌ | ❌ | Dimensional extraction + intelligent routing for Fabric AI patterns. Session management, graph-based workflows. | `hub/fabric-graph-agents/` |
| 3 | **circuit-board-knowledge-extractor** | 13 files, 3 workflows, test images | ✅ (2) | ❌ | ✅ | Multi-pass consensus OCR for circuit board photos. Aggregates readings across multiple images, builds AI consensus. | `hub/circuit-extractor/` |
| 4 | **fabric-image-analysis** | 10 files, workflows, 5 docs, test images | ❌ | ❌ | ❌ | AI image metadata extraction pipeline. Vision model integration with structured output. | `hub/fabric-image-analysis/` |
| 5 | **jumpserver-deploy** (in dockerfiles/) | 16 files, compose+5 scripts | ❌ | ❌ | ❌ | Complete JumpServer bastion host deployment with custom branding. | `hub/jumpserver-deploy/` |

### Tier C — Config-Like but Well-Structured

| # | Project | Scope | What It Does | Destination |
|---|---------|-------|-------------|-------------|
| 6 | **tmux** | 21 files, 6 scripts, 3 configs | Cross-platform portable tmux config. Session persistence, clean styling, macOS+Linux. | `hub/portable-tmux/` |

---

## Table 2: GREENFIELD CANDIDATES (Scripts → Build into Full Apps)

Scripts that work but haven't been built into full applications yet. Each has a proven core idea and could follow youtube-obsidian's architecture pattern.

### Greenfield Gap Analysis — Feature-by-Feature Comparison

Reference model: **youtube-obsidian** (V4.0). For each greenfield candidate, what's missing vs what exists.

| Capability | ytobs (reference) | reddit_to_markdown.sh | obsidian-polish (905l) | or-bench (598+410) | _tokcount (569+184) | slugfile (573) | mfab (509) |
|-----------|-------------------|----------------------|----------------------|--------------------|--------------------|----------------|------------|
| **Python entry point** | ✅ `yt` (1022l) | ❌ embedded heredoc | ❌ bash only | ✅ 2 .py files | ✅ 1 .py + 1 .sh | ❌ bash only | ❌ bash only |
| **lib/ modules** | ✅ 18 modules | ❌ 0 | ❌ 0 | ❌ 0 | ❌ 0 | ❌ 0 | ❌ 0 |
| **Config file** | ✅ `config.yaml` | ❌ none | ❌ hardcoded vars | ❌ none | ❌ none | ❌ none | ❌ env file |
| **CLI (argparse)** | ✅ subcommands | ❌ 1 positional arg | ❌ 1 positional arg | ❌ 1 positional arg | ❌ 2 flags | ❌ 8 flags | ❌ none (REPL) |
| **requirements.txt** | ✅ 28 deps | ❌ 0 (stdlib only) | ❌ 0 (shell) | ❌ 0 | ✅ tiktoken | ❌ 0 | ❌ 0 |
| **Cache system** | ✅ per-video JSON | ❌ none | ❌ none | ✅ JSON cache | ❌ none | ❌ none | ❌ none |
| **AI integration** | ✅ Fabric patterns | ❌ none | ✅ Fabric | ❌ none | ❌ none | ❌ none | ✅ Fabric (man pages) |
| **Obsidian output** | ✅ YAML frontmatter + .md | ✅ YAML frontmatter (stdout) | ✅ via CLI | ❌ none | ❌ none | ❌ file rename only | ❌ none |
| **Subcommands** | ✅ status, vault, channel | ❌ 0 | ❌ 0 | ❌ 0 | ❌ 0 | ❌ 0 | ❌ 0 |
| **Error handling** | ✅ try/except | ❌ none | ❌ `set -e` | ❌ minimal | ❌ minimal | ❌ minimal | ❌ minimal |
| **Tests** | ❌ none | ❌ none | ❌ none | ❌ none | ❌ none | ✅ test script | ❌ none |
| **Docs** | ✅ 8+ docs | ❌ none | ❌ none | ❌ none | ❌ none | ✅ quickref | ❌ none |
| **LICENSE** | ✅ MIT | ❌ none | ❌ none | ❌ none | ❌ none | ❌ none | ❌ none |
| **Package** | pip-installable | ❌ none | ❌ none | ❌ none | ❌ none | ❌ none | ❌ none |
| **Lines of code** | ~3,000 | 120 | 905 | 1,008 | 753 | 573 | 509 |

### Gap Summary — What Each Greenfield Needs to Become an App

| Project | Missing % | Biggest Gaps |
|---------|-----------|-------------|
| **reddit_to_markdown.sh** | **87% missing** | Everything. No lib, no config, no cache, no AI, no CLI. Greenfield from near-zero. |
| **obsidian-polish** | **71% missing** | No lib structure, no config, no argparse CLI, no packaging. But has AI integration (Fabric) and Obsidian output. |
| **or-bench** | **64% missing** | Has good data model (JSON cache), but no lib/, no CLI subcommands, no packaging. |
| **_tokcount** | **71% missing** | Has Python lib core but wrapped in bash. No config, no packaging. |
| **slugfile** | **78% missing** | Bash-only, no lib structure. But has tests and quickref docs. |
| **mfab** | **71% missing** | Bash REPL, no Python structure. But has AI integration via Fabric. |

### Tier A — High Potential (Complex, Proven, Worth Building)

| # | Script | Lines | What It Does | Current Form | What It Needs To Become An App | Suggested Name |
|---|--------|-------|-------------|-------------|-------------------------------|----------------|
| G1 | **obsidian-polish** | 905 | AI polish & frontmatter generation for Obsidian notes. Multiple modes: in-place, pipe, batch, rename, title-only. | Single bash script | Split into lib/ modules (frontmatter.py, title_gen.py, rename.py, fabric.py). Proper CLI with subcommands. Config file. | `hub/obsidian-polish/` |
| G2 | **or-bench + or-model-select** | 598+410 | OpenRouter free model benchmarking. Parallel workers, JSON output, cache with staleness, filters. Model selection from benchmark cache. | 2 Python scripts | Merge into single CLI. Add lib/ (benchmark.py, cache.py, selector.py). pyproject.toml packaging. Terminal UI for live results. | `hub/or-bench/` |
| G3 | **reddit_to_markdown.sh** | 120 | Reddit thread → Markdown with YAML frontmatter, threaded comments. Hits Reddit JSON API directly (no auth needed). | Single bash script with embedded Python | Full rebuild modeled on ytobs: lib/extractor.py (praw API), lib/formatter.py, lib/cache_manager.py, config system, CLI with subcommands, AI analysis layer (fabric patterns), incremental caching. | `hub/reddit-obsidian/` |

### Tier B — Medium Potential (Useful, Narrower Scope)

| # | Script | Lines | What It Does | Current Form | What It Needs | Suggested Name |
|---|--------|-------|-------------|-------------|---------------|----------------|
| G4 | **_tokcount_core.py + tokcount** | 569+184 | Streaming token counting library. tiktoken integration, JSON output, model context checking. | 2 files (py lib + sh wrapper) | Package as proper Python library. pyproject.toml. CLI with stdin/file modes. Publish to PyPI? | `hub/tokcount/` |
| G5 | **slugfile** | 573 | File renaming with slugification, date/tag/polish modes. 8 flags. Has test suite. | Single bash script + test | Modularize: lib/slug.py, lib/rename.py, lib/frontmatter.py. CLI with subcommands. Unify with obsidian-polish? | `hub/slugfile/` |
| G6 | **mfab** | 509 | Man-page-aware Fabric REPL wrapper. Local vendor fallback, interactive mode. | Single bash script | Python rewrite. lib/repl.py, lib/provider.py, lib/man_page.py. Would benefit from proper package. | `hub/mfab/` |

### Tier C — Lower Priority (Niche but Useful)

| # | Script | Lines | What It Does | Current Form | What It Needs |
|---|--------|-------|-------------|-------------|---------------|
| G7 | **vault-recon** | 210 | Obsidian vault analysis toolkit. File counts, tag stats, orphan detection. | Single bash script | Python rewrite. Obsidian REST API integration. Rich terminal output. |
| G8 | **txrefine** | 205 | Transcription refinement via fabric. Reads raw transcripts, applies polish patterns. | Single bash script | Proper CLI with file/stdin modes. Multiple refinement passes. Output formatting options. |
| G9 | **to_note** | 109 | Pipe terminal output → Obsidian note. Auto-frontmatter, date-stamped. | Single bash script | Obsidian REST API integration (instead of filesystem). Templating system. Tag support. |
| G10 | **voice_note.sh** | 114 | Voice note full lifecycle: record → transcribe → save to Obsidian. | Single bash script | **Already has a full app**: `hub/voice_note/`. This script is just a thin wrapper. Deprecate. |
| G11 | **obsidian-polish-v3** | 204 | New architecture rewrite of obsidian-polish (via Obsidian CLI). | Single bash script | Merge into the obsidian-polish app (G1). This is the v3 prototype that should become part of the package. |

---

## Table 3: UTILITIES (Stay in .myscripts)

Single-purpose tools that work fine as standalone scripts. No extraction needed.

| Script | Lines | What It Does |
|--------|-------|-------------|
| `fab` | 107 | Fabric wrapper with auto-fallback (fabric-ai → fabric → mfab) |
| `heic2jpg.sh` | 320 | Bulk HEIC → JPG converter |
| `flac2mp3.sh` | 32 | FLAC → MP3 converter |
| `wav-to-mp3` | 66 | WAV → MP3 converter |
| `clip.sh` | 52 | File → clipboard |
| `to_clip` | 30 | Pipe → clipboard |
| `concat-any` | 100 | File concatenation by extension |
| `concat-dart.sh` | 71 | Dart file concatenation |
| `concat-py.sh` | 68 | Python file concatenation |
| `concat.sh` | 68 | Generic file concatenation |
| `drives.sh` | 99 | Rclone drive mount/unmount manager |
| `gen_unique_strings.sh` | 138 | Unique string generator with persistence |
| `log_temps.sh` | 11 | Temperature logger |
| `ocr-ing.sh` | 41 | Single-file OCR via ocrmypdf |
| `ocr-quick-start.sh` | 197 | OCR patterns quick start guide |
| `droid-emulator.sh` | 4 | Android emulator launcher |
| `sync_keypass_vault.sh` | 30 | KeePass sync to Proton Drive |
| `workflow-design` | 24 | Workflow architect helper |
| `view-kanban.sh` | 77 | Visual kanban for obsidian-polish |
| `deploy-searxng.sh` | 61 | SearXNG Docker deploy |
| `preview-reorganization.sh` | 142 | Preview fabric reorganization plan |
| `reorganize-fabric.sh` | 385 | Fabric directory reorganization |
| `check-docs.sh` | 275 | Documentation quality checklist |

---

## Table 4: CONFIG / DEPLOY (Stay in .myscripts)

| Entry | What It Is |
|-------|-----------|
| `fabric-custom-patterns/` | ~40 custom Fabric AI patterns (pattern library, not app) |
| `fabric-completion/` | Fabric shell completions installer |
| `shell-enhancement/` | Zsh autosuggestions/syntax highlighting setup |
| `searxng/` | SearXNG deployment for OpenCode MCP (docker-compose + settings) |
| `dockerfiles/` | Container configs (currently just jumpserver — that should be extracted though) |
| `mlx-ecosystem/` | Apple MLX examples mirror (reference copy) |
| `fabric-vision-examples/` | 3 example scripts for fabric vision features |
| `fabric-setup-modelos` | LiteLLM endpoint config for Lusofona Modelos |
| `git-credential-setup/` | Git credential helper guide (documentation) |
| `skills/` | 2 agent session resumption guides |
| `docs/` | 24 cross-project documentation files |
| `meta/` | Empty directory → **DELETE** |
| `mfab.env` | Environment config for mfab |

---

## Table 5: BACKUPS & ARCHIVES (Clean Up)

| Entry | Action |
|-------|--------|
| `fabric-graph-agents-backup-20251027-193604/` | **Delete** after extracting fabric-graph-agents. Superseded. |
| `obsidian-polish.backup-20251221-082114` | **Delete** after extracting obsidian-polish. Superseded. |
| `obsidian-polish.backup-sprint2a` | **Delete**. |
| `obsidian-polish.backup-sprint3` | **Delete**. |
| `slugfile.backup-20260422-072448` | **Delete**. |

---

## Extraction Checklist: youtube-obsidian → hub/ytobs

### Phase 1: Copy & Structure
- [ ] Copy project to `~/projetos/hub/ytobs/`
- [ ] Create `pyproject.toml` with: name="ytobs", dependencies, `[project.scripts]` entry point
- [ ] Decide package structure: rename `lib/` → `ytobs/` (recommended) or keep flat
- [ ] Remove non-essential dirs: `__pycache__/`, `.fabric/`, `.opencode/`, `.vscode/`, `node_modules/`

### Phase 2: Code Fixes
- [ ] **CRITICAL**: Fix `lib/validator.py:9` — `from lib.exceptions` → `from .exceptions`
- [ ] Review all imports under new package namespace
- [ ] Add `__version__ = "4.0.0"` to `lib/__init__.py`
- [ ] Create `ytobs/cli.py` (migrate `main()` from yt script)

### Phase 3: Config & Integration
- [ ] Update `~/.zshrc:129` — replace `ytobs()` shell function with pip-installed command
- [ ] Remove `.myscripts/` PATH extension from `~/.zshrc` if not needed
- [ ] Update `SETUP.md` symlink instructions → pip install

### Phase 4: Documentation
- [ ] Update `CONTEXT.md` — location header + all `.myscripts/youtube-obsidian` refs
- [ ] Update `START_HERE.md` — location header
- [ ] Update `SETUP.md` — remove old `rascunhos/` paths
- [ ] Update `README.md` — add pip install section
- [ ] Scan all `docs/` for `.myscripts` strings → update

### Phase 5: Cleanup & Test
- [ ] Create fresh `requirements.txt` with loosened version ranges
- [ ] Remove `pydantic` (dead dep — nothing imports it) and dev-only deps from runtime
- [ ] Create venv + `pip install -e .`
- [ ] Test `ytobs --help`
- [ ] Test: process YouTube video end-to-end
- [ ] Verify `$OBSVAULT` env var still works
- [ ] Verify `~/.yt-obsidian/config.yml` auto-creation still works

---

## Recommended Execution Order

```
Priority 1 — EXTRACT NOW (proven, high-impact)
  ├── youtube-obsidian → hub/ytobs          (2-3h, 26-item checklist)
  └── fabric-graph-agents → hub/fabric-graph-agents  (1h, simpler extraction)

Priority 2 — BUILD GREENFIELD (scripts → apps)
  ├── reddit_to_markdown.sh → hub/reddit-obsidian   (3-5h, full build)
  ├── obsidian-polish → hub/obsidian-polish         (2-3h, modularize)
  └── or-bench → hub/or-bench                       (2-3h, package)

Priority 3 — EXTRACT MORE (lower urgency)
  ├── circuit-board-knowledge-extractor → hub/
  ├── fabric-image-analysis → hub/
  ├── jumpserver-deploy → hub/
  └── tmux → hub/portable-tmux

Priority 4 — CLEANUP
  ├── Delete backup dirs (5 items)
  ├── Delete empty meta/ dir
  └── Deprecate voice_note.sh (already has hub/voice_note/)
```

---

## Post-Extraction .myscripts/ State

After extracting all Tier A+B candidates and cleaning up backups:

```
.myscripts/                          (~28 items, down from 42)
├── fab                              # Fabric wrapper
├── heic2jpg.sh                      # HEIC converter
├── flac2mp3.sh / wav-to-mp3         # Audio converters
├── clip.sh / to_clip                # Clipboard tools
├── concat-*                         # File concatenation (4 scripts)
├── drives.sh                        # Rclone manager
├── slugfile                         # File renaming
├── _tokcount_core.py / tokcount     # Token counter
├── mfab                              # Fabric REPL
├── to_note / vault-recon / txrefine # Obsidian utilities
├── deploy-searxng.sh                # SearXNG deploy
├── fabric-completion/               # Shell completions
├── fabric-custom-patterns/          # Pattern library
├── fabric-vision-examples/          # Vision examples
├── shell-enhancement/               # Shell config
├── searxng/                         # SearXNG config
├── dockerfiles/                     # Docker configs
├── mlx-ecosystem/                   # MLX reference
├── git-credential-setup/            # Git guide
├── skills/                          # Resume guides
├── docs/                            # Cross-project docs
├── .gitignore / .git/               # Git metadata
└── MYSCRIPTS_AUDIT_AND_EXTRACTION_PLAN.md  # ← THIS FILE
```

---

## Notes

- **voice_note.sh** (114 lines) → already has a full production app at `hub/voice_note/`. Deprecate this wrapper script.
- **obsidian-polish-v3** (204 lines) → rewrite of obsidian-polish using Obsidian CLI. Should be merged into the full obsidian-polish app (G1), not extracted separately.
- **fabric-custom-patterns/** → these are Fabric's config files, not an app. They stay in `.myscripts/` or could move to a dedicated patterns repo if they grow.
- **docs/** → 24 cross-project docs. As projects are extracted, their docs should move with them. Eventually `docs/` should shrink or be eliminated.
- The old `yt-dlp-tests` project in `~/projetos/rascunhos/` is confirmed deleted. Migration to `.myscripts/youtube-obsidian/` was complete in Dec 2025.
