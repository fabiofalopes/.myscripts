# .myscripts/ — Master TODO & Progress Tracker

**Purpose**: Single source of truth. Any session loads this, knows exactly what was done, what's next, and how to execute.
**Updated**: 2026-05-30
**Session command**: `Load: ~/projetos/hub/.myscripts/MASTER_TODO.md`

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ⬜ | Not started |
| 🔵 | In progress |
| ✅ | Done |
| ❌ | Blocked |
| ⏸️ | Paused / deferred |
| 🔴 | Failed — needs investigation |

---

## PHASE 0: Audit & Planning

| ID | Task | Status | Handoff File | Notes |
|----|------|--------|-------------|-------|
| P0.1 | Catalog all 77 entries in .myscripts/ | ✅ | `MYSCRIPTS_AUDIT_AND_EXTRACTION_PLAN.md` | Classified into: 6 extraction, 11 greenfield, 22 utility, 13 config, 5 cleanup |
| P0.2 | Create greenfield gap analysis | ✅ | `MYSCRIPTS_AUDIT_AND_EXTRACTION_PLAN.md` § Table 2 | Feature-by-feature comparison against ytobs reference |
| P0.3 | Create ytobs extraction handoff | ✅ | `youtube-obsidian/HANDOFF_ytobs_extraction.md` | 29-item checklist, pyproject.toml spec, bug audit, verification script |
| P0.4 | Create master index | ✅ | `HANDOFF_INDEX.md` | Maps projects → handoff files |
| P0.5 | Create master TODO (this file) | ✅ | `MASTER_TODO.md` | You're reading it |

---

## PHASE 1: Extraction — Existing Full Apps

Priority: Move proven apps out of .myscripts into hub/ as standalone repos.

### E1: ytobs (youtube-obsidian)

**Source**: `.myscripts/youtube-obsidian/` → **Target**: `hub/ytobs/`
**Handoff**: `youtube-obsidian/HANDOFF_ytobs_extraction.md`
**Estimate**: 2-3 hours

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| E1.1 | Copy files to hub/ytobs/ | ⬜ | — | cp -a everything except __pycache__, .fabric/, .opencode/, .vscode/ |
| E1.2 | Write pyproject.toml | ⬜ | E1.1 | Full spec in handoff § pyproject.toml Specification |
| E1.3 | Rename lib/ → ytobs/ | ⬜ | E1.1 | Standard package layout |
| E1.4 | Fix validator.py import bug | ⬜ | E1.3 | `from lib.exceptions` → `from .exceptions` (CRITICAL) |
| E1.5 | Add __version__ to __init__.py | ⬜ | E1.3 | `__version__ = "4.0.0"` |
| E1.6 | Create ytobs/cli.py from old yt script | ⬜ | E1.3 | Migrate main() and create_parser() |
| E1.7 | Delete old yt and yt-obsidian.py | ⬜ | E1.6 | No longer needed after cli.py exists |
| E1.8 | Update ~/.zshrc — kill ytobs() shell function | ⬜ | E1.6 | Replace with pip-installed entry point |
| E1.9 | Create venv + pip install -e . | ⬜ | E1.2, E1.6 | Test import chain |
| E1.10 | Update all documentation paths | ⬜ | E1.1 | CONTEXT.md, START_HERE.md, SETUP.md, README.md, docs/ |
| E1.11 | Rewrite requirements.txt | ⬜ | E1.1 | Remove pydantic (dead dep), loosen versions |
| E1.12 | Verify — ytobs --help | ⬜ | E1.9 | Test CLI works |
| E1.13 | Verify — ytobs --version | ⬜ | E1.9 | Should print "ytobs 4.0.0" |
| E1.14 | Verify — ytobs --list-processed | ⬜ | E1.9 | Should show 76 cached videos |
| E1.15 | Verify — config auto-creation | ⬜ | E1.9 | Delete ~/.yt-obsidian/config.yml, run ytobs --help, check it recreates |
| E1.16 | Delete source in .myscripts/ | ⬜ | E1.12-15 | Only after all verification passes |
| E1.17 | Update this TODO → mark E1 done | ⬜ | E1.16 | — |

### E2: fabric-graph-agents

**Source**: `.myscripts/fabric-graph-agents/` → **Target**: `hub/fabric-graph-agents/`
**Handoff**: Not yet written
**Estimate**: 1 hour (simpler extraction — no packaging needed, shell-based)

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| E2.1 | Write extraction handoff | ⬜ | — | Model on ytobs handoff format |
| E2.2 | Copy to hub/fabric-graph-agents/ | ⬜ | E2.1 | — |
| E2.3 | Delete backup dir in .myscripts/ | ⬜ | E2.2 | `fabric-graph-agents-backup-20251027-193604/` — superseded |
| E2.4 | Update this TODO | ⬜ | E2.3 | — |

### E3: circuit-board-knowledge-extractor

**Source**: `.myscripts/circuit-board-knowledge-extractor/` → **Target**: `hub/circuit-extractor/`
**Handoff**: Not yet written
**Estimate**: 1 hour

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| E3.1 | Write extraction handoff | ⬜ | — | — |
| E3.2 | Copy to hub/circuit-extractor/ | ⬜ | E3.1 | — |
| E3.3 | Update this TODO | ⬜ | E3.2 | — |

### E4: fabric-image-analysis

**Source**: `.myscripts/fabric-image-analysis/` → **Target**: `hub/fabric-image-analysis/`
**Handoff**: Not yet written
**Estimate**: 30 min

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| E4.1 | Write extraction handoff | ⬜ | — | — |
| E4.2 | Copy to hub/ | ⬜ | E4.1 | — |
| E4.3 | Update this TODO | ⬜ | E4.2 | — |

### E5: jumpserver-deploy

**Source**: `.myscripts/dockerfiles/jumpserver-deploy/` → **Target**: `hub/jumpserver-deploy/`
**Handoff**: Not yet written
**Estimate**: 30 min

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| E5.1 | Write extraction handoff | ⬜ | — | — |
| E5.2 | Copy to hub/ | ⬜ | E5.1 | Includes docker-compose + 5 scripts |
| E5.3 | Update this TODO | ⬜ | E5.2 | — |

### E6: tmux

**Source**: `.myscripts/tmux/` → **Target**: `hub/portable-tmux/`
**Handoff**: Not yet written
**Estimate**: 30 min

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| E6.1 | Write extraction handoff | ⬜ | — | — |
| E6.2 | Copy to hub/ | ⬜ | E6.1 | — |
| E6.3 | Update this TODO | ⬜ | E6.2 | — |

---

## PHASE 2: Greenfield — Scripts → Full Apps

Priority: Build proven scripts into full applications modeled on ytobs architecture.

### G1: reddit-obsidian

**Source**: `reddit_to_markdown.sh` (120-line bash script with embedded Python)
**Target**: `hub/reddit-obsidian/` — full pip-installable app
**Gap**: 87% missing (no lib, no config, no cache, no AI, no CLI)
**Handoff**: Not yet written
**Estimate**: 3-5 hours

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| G1.1 | Write build spec handoff | ⬜ | — | Model architecture on ytobs |
| G1.2 | Create hub/reddit-obsidian/ scaffold | ⬜ | G1.1 | pyproject.toml, ytobs-style structure |
| G1.3 | Build lib/extractor.py | ⬜ | G1.2 | Reddit JSON API → structured data (praw optional) |
| G1.4 | Build lib/formatter.py | ⬜ | G1.2 | Structured data → Obsidian markdown with YAML frontmatter |
| G1.5 | Build lib/cache_manager.py | ⬜ | G1.2 | Duplicate prevention, incremental updates |
| G1.6 | Build CLI with argparse | ⬜ | G1.3-5 | Subcommands: process, status, search |
| G1.7 | Add AI analysis layer | ⬜ | G1.6 | Fabric pattern integration for content analysis |
| G1.8 | Write docs (README, CONTEXT, HELP) | ⬜ | G1.6 | — |
| G1.9 | Test end-to-end | ⬜ | G1.8 | Process real Reddit threads |
| G1.10 | Update this TODO | ⬜ | G1.9 | — |

### G2: obsidian-polish

**Source**: `obsidian-polish` (905-line bash script) + `obsidian-polish-v3` (204-line rewrite)
**Target**: `hub/obsidian-polish/` — full pip-installable app
**Gap**: 71% missing (no lib structure, no config, no argparse CLI)
**Handoff**: Not yet written
**Estimate**: 2-3 hours

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| G2.1 | Write build spec handoff | ⬜ | — | Merge v3 prototype into v1 features |
| G2.2 | Create hub/obsidian-polish/ scaffold | ⬜ | G2.1 | — |
| G2.3 | Split into lib/ modules | ⬜ | G2.2 | frontmatter.py, title_gen.py, rename.py, fabric.py |
| G2.4 | Build CLI with subcommands | ⬜ | G2.3 | polish, batch, rename-only, title-only, pipe mode |
| G2.5 | Add config file | ⬜ | G2.2 | Default patterns, vault path, naming conventions |
| G2.6 | Test all modes | ⬜ | G2.5 | In-place, pipe, batch, rename |
| G2.7 | Delete old backups from .myscripts/ | ⬜ | G2.6 | 3 backup files — superseded |
| G2.8 | Update this TODO | ⬜ | G2.7 | — |

### G3: or-bench

**Source**: `or-bench` (598-line Python) + `or-model-select` (410-line Python)
**Target**: `hub/or-bench/` — pip-installable benchmark tool
**Gap**: 64% missing (has Python + cache, needs lib/ + CLI + packaging)
**Handoff**: Not yet written
**Estimate**: 2-3 hours

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| G3.1 | Write build spec handoff | ⬜ | — | Merge two scripts into one package |
| G3.2 | Create hub/or-bench/ scaffold | ⬜ | G3.1 | — |
| G3.3 | Split into lib/ modules | ⬜ | G3.2 | benchmark.py, cache.py, selector.py, display.py |
| G3.4 | Build CLI with subcommands | ⬜ | G3.3 | bench, select, stats, list |
| G3.5 | Add terminal UI for live results | ⬜ | G3.4 | Rich library or simple progress bars |
| G3.6 | Package with pyproject.toml | ⬜ | G3.5 | — |
| G3.7 | Test with real OpenRouter models | ⬜ | G3.6 | — |
| G3.8 | Update this TODO | ⬜ | G3.7 | — |

### G4-G6: Lower Priority Greenfields

| ID | Project | Status | Notes |
|----|---------|--------|-------|
| G4 | _tokcount → hub/tokcount/ | ⬜ | Package as Python lib. Lower priority — works fine as script. |
| G5 | slugfile → hub/slugfile/ | ⬜ | Modularize. Lower priority — works fine as script. |
| G6 | mfab → hub/mfab/ | ⬜ | Python rewrite. Lower priority — works fine as script. |

---

## PHASE 3: Cleanup

| ID | Task | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| C1 | Delete `meta/` (empty dir) | ⬜ | — | Zero content. Just rm -rf. |
| C2 | Delete backup dirs | ⬜ | E2.2 | fabric-graph-agents-backup + obsidian-polish backups + slugfile backup — 5 items total. Only delete AFTER verifying the extracted versions work. |
| C3 | Deprecate voice_note.sh | ⬜ | — | Already has full app at hub/voice_note/. Add deprecation notice to script. |
| C4 | Review docs/ cross-references | ⬜ | — | 24 docs that reference projects by old .myscripts paths. Update as projects are extracted. |

---

## Progress Summary

| Phase | Total Tasks | Done | In Progress | Remaining |
|-------|------------|------|-------------|-----------|
| P0: Audit & Planning | 5 | 5 | 0 | 0 |
| E1: ytobs extraction | 17 | 0 | 0 | 17 |
| E2-6: Other extractions | 12 | 0 | 0 | 12 |
| G1-3: Priority greenfields | 26 | 0 | 0 | 26 |
| G4-6: Lower greenfields | 3 | 0 | 0 | 3 |
| C: Cleanup | 4 | 0 | 0 | 4 |
| **TOTAL** | **67** | **5** | **0** | **62** |

**Overall**: 7% complete. Phase 0 (planning) is done. Ready to start Phase 1 (E1: ytobs extraction).

---

## Quick Start for Any Session

```
1. Load this file: ~/projetos/hub/.myscripts/MASTER_TODO.md
2. Find the first ⬜ item in Phase 1
3. Load its handoff file from the "Handoff File" column
4. Execute the checklist from start to finish
5. Mark each subtask ✅ as you complete it
6. Update this file when the phase is done
```

Example — to start ytobs extraction:

```
1. Find: E1.1 is first ⬜
2. Load: youtube-obsidian/HANDOFF_ytobs_extraction.md
3. Execute: Phase 1 items 1-5, then Phase 2 items 6-10, etc.
4. Mark: E1.1 ✅, E1.2 ✅, ... in this file as each completes
5. When E1.17 is ✅, mark E1 row green
```

---

## File Map (All Handoff & Reference Files)

| File | Purpose |
|------|---------|
| `MASTER_TODO.md` *(this file)* | Progress tracker — always up to date |
| `HANDOFF_INDEX.md` | Which file to load for which project |
| `MYSCRIPTS_AUDIT_AND_EXTRACTION_PLAN.md` | Full audit — 5 tables, gap analysis |
| `youtube-obsidian/HANDOFF_ytobs_extraction.md` | ytobs execution spec (29 items) |

---

## Session Log

| Date | What Happened |
|------|--------------|
| 2026-05-30 | Phase 0 complete. Full audit of all 77 entries. Created audit doc, ytobs handoff, index, and this TODO. Ready for Phase 1 execution. |
