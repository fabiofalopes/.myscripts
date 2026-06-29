# .myscripts/ — Master TODO & Progress Tracker

**Purpose**: Single source of truth. Any session loads this, knows exactly what was done, what's next, and how to execute.
**Updated**: 2026-06-29
**Session command**: `Load: ~/projetos/hub/.myscripts/MASTER_TODO.md`

---

## ⚠️ CAMPAIGN STATE (read first)

The extraction + greenfield campaign (P0–P2, E1–E6, G1–G3) is **functionally complete and stabilized** — all builds are done, on disk, committed, and (for the 4 Python packages) versioned + smoke-verified. Phase 4 (S1–S5) executed 2026-06-29 against decisions D1–D5 in `HUMAN.md`. All three governance gaps are now **resolved**:

| # | Gap | Impact | Status |
|---|-----|--------|--------|
| **G-VC** | Entire campaign was **uncommitted**; `hub/` unversioned (0/9 git). | One `git checkout .` or `rm -rf hub/` = 12 days of work lost. | ✅ **Resolved** — `.myscripts/` snapshotted (`8091cce` + cleanup `273c783`); 4 Python projects versioned (S2). 5 shell/config projects remain unversioned by decision (D1) — logged in Obsidian vault. |
| **G-SRC** | Greenfield source scripts were **not deleted** (2,237 lines). | Duplicate/divergent logic. | ✅ **Resolved** — all 5 deleted in commit `273c783` (D2). Recoverable via snapshot `8091cce`. |
| **G-DRIFT** | Tracking files had drifted (reconciled 2026-06-29). | Resolved in prior pass. | ✅ **Done** |

**Remaining**: S6 (stale doc refs, C4) is **deferred** per D5 — low severity, paths still resolve. G3.7 (or-bench live test) needs an API key. G4–G6 (low-priority greenfields) work fine as scripts. See `HUMAN.md` for the decision record and `prompt_2026-06-29_0157_stabilization-ops.md` for the runbook.

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
| E1.1 | Copy files to hub/ytobs/ | ✅ | — | cp -a everything except __pycache__, .fabric/, .opencode/, .vscode/ |
| E1.2 | Write pyproject.toml | ✅ | E1.1 | Full spec in handoff § pyproject.toml Specification |
| E1.3 | Rename lib/ → ytobs/ | ✅ | E1.1 | Standard package layout |
| E1.4 | Fix validator.py import bug | ✅ | E1.3 | `from lib.exceptions` → `from .exceptions` (CRITICAL) |
| E1.5 | Add __version__ to __init__.py | ✅ | E1.3 | `__version__ = "4.0.0"` |
| E1.6 | Create ytobs/cli.py from old yt script | ✅ | E1.3 | Migrate main() and create_parser() |
| E1.7 | Delete old yt and yt-obsidian.py | ✅ | E1.6 | No longer needed after cli.py exists |
| E1.8 | Update ~/.zshrc — kill ytobs() shell function | ✅ | E1.6 | Replaced with pip-installed entry point comment |
| E1.9 | Create venv + pip install -e . | ✅ | E1.2, E1.6 | Test import chain |
| E1.10 | Update all documentation paths | ✅ | E1.1 | CONTEXT.md, START_HERE.md, SETUP.md, README.md, docs/ |
| E1.11 | Rewrite requirements.txt | ✅ | E1.1 | Remove pydantic (dead dep), loosen versions |
| E1.12 | Verify — ytobs --help | ✅ | E1.9 | Test CLI works |
| E1.13 | Verify — ytobs --version | ✅ | E1.9 | Should print "ytobs 4.0.0" |
| E1.14 | Verify — ytobs --list-processed | ✅ | E1.9 | Shows 76 cached videos |
| E1.15 | Verify — config auto-creation | ✅ | E1.9 | Delete ~/.yt-obsidian/config.yml, run ytobs vault, verify it recreates |
| E1.16 | Delete source in .myscripts/ | ✅ | E1.12-15 | Done — handoff preserved in hub/ytobs/archive/ |
| E1.17 | Update this TODO → mark E1 done | ✅ | E1.16 | — |

### E2: fabric-graph-agents

**Source**: `.myscripts/fabric-graph-agents/` → **Target**: `hub/fabric-graph-agents/`
**Handoff**: `hub/fabric-graph-agents/archive/HANDOFF_extraction.md`
**Estimate**: 1 hour (simpler extraction — no packaging needed, shell-based)

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| E2.1 | Write extraction handoff | ✅ | — | Written, archived with project |
| E2.2 | Copy to hub/fabric-graph-agents/ | ✅ | E2.1 | 89 files, symlink to fabric-custom-patterns |
| E2.3 | Delete backup dir in .myscripts/ | ✅ | E2.2 | `fabric-graph-agents-backup-20251027-193604/` — deleted |
| E2.4 | Update this TODO | ✅ | E2.3 | — |

### E3: circuit-board-knowledge-extractor

**Source**: `.myscripts/circuit-board-knowledge-extractor/` → **Target**: `hub/circuit-extractor/`
**Handoff**: `hub/circuit-extractor/archive/HANDOFF_extraction.md`
**Estimate**: 15 min (very simple — 14 files)

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| E3.1 | Write extraction handoff | ✅ | — | Written, archived with project |
| E3.2 | Copy to hub/circuit-extractor/ | ✅ | E3.1 | 14 files copied, paths updated |
| E3.3 | Update this TODO | ✅ | E3.2 | — |

### E4: fabric-image-analysis

**Source**: `.myscripts/fabric-image-analysis/` → **Target**: `hub/fabric-image-analysis/`
**Handoff**: `hub/fabric-image-analysis/archive/HANDOFF_extraction.md`
**Estimate**: 5 min (9 files)

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| E4.1 | Write extraction handoff | ✅ | — | Written, archived with project |
| E4.2 | Copy to hub/ | ✅ | E4.1 | 9 files copied |
| E4.3 | Update this TODO | ✅ | E4.2 | — |

### E5: jumpserver-deploy

**Source**: `.myscripts/dockerfiles/jumpserver-deploy/` → **Target**: `hub/jumpserver-deploy/`
**Handoff**: `hub/jumpserver-deploy/archive/HANDOFF_extraction.md`
**Estimate**: 5 min (16 files)

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| E5.1 | Write extraction handoff | ✅ | — | Written, archived with project |
| E5.2 | Copy to hub/ | ✅ | E5.1 | docker-compose + 6 scripts + branding |
| E5.3 | Update this TODO | ✅ | E5.2 | — |

### E6: tmux

**Source**: `.myscripts/tmux/` → **Target**: `hub/portable-tmux/`
**Handoff**: `hub/portable-tmux/archive/HANDOFF_extraction.md`
**Estimate**: 5 min (21 files)

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| E6.1 | Write extraction handoff | ✅ | — | Written, archived with project |
| E6.2 | Copy to hub/ | ✅ | E6.1 | 21 files copied |
| E6.3 | Update this TODO | ✅ | E6.2 | — |

---

## PHASE 2: Greenfield — Scripts → Full Apps

Priority: Build proven scripts into full applications modeled on ytobs architecture.

### G1: reddit-obsidian

**Source**: `reddit_to_markdown.sh` (120-line bash script with embedded Python)
**Target**: `hub/reddit-obsidian/` — full pip-installable app
**Gap**: 87% missing (no lib, no config, no cache, no AI, no CLI)
**Handoff**: GREENFIELDS/reddit_obsidian_spec.md
**Estimate**: 3-5 hours

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| G1.1 | Write build spec handoff | ✅ | — | Model architecture on ytobs |
| G1.2 | Create hub/reddit-obsidian/ scaffold | ✅ | G1.1 | pyproject.toml, ytobs-style structure |
| G1.3 | Build extractor module | ✅ | G1.2 | HTML scraping of old.reddit.com (Reddit JSON API is dead — 403) |
| G1.4 | Build formatter module | ✅ | G1.2 | YAML frontmatter + threaded comments markdown |
| G1.5 | Build cache_manager module | ✅ | G1.2 | Immutable cache with CRUD, search, stats |
| G1.6 | Build CLI with argparse | ✅ | G1.3-5 | Subcommands: fetch, status, search, vault |
| G1.7 | Add AI analysis layer | ✅ | G1.6 | Fabric pattern integration (fabric_client.py) |
| G1.8 | Write docs (README, CONTEXT, HELP) | ✅ | G1.6 | README.md, CONTEXT.md, HELP.md written |
| G1.9 | Test end-to-end | ✅ | G1.8 | Real Reddit thread fetched, comments extracted, CLI all verified |
| G1.10 | Update this TODO | ✅ | G1.9 | G1 code complete and verified |

### G2: obsidian-polish

**Source**: `obsidian-polish` (905-line bash script) + `obsidian-polish-v3` (204-line rewrite)
**Target**: `hub/obsidian-polish/` — full pip-installable app
**Gap**: 71% missing (no lib structure, no config, no argparse CLI)
**Handoff**: Not yet written
**Estimate**: 2-3 hours

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| G2.1 | Write build spec handoff | ✅ | — | Spec at GREENFIELDS/obsidian_polish_spec.md |
| G2.2 | Create hub/obsidian-polish/ scaffold | ✅ | G2.1 | pyproject.toml, .gitignore, LICENSE, package dir |
| G2.3 | Split into lib/ modules | ✅ | G2.2 | 9 modules: cli, polisher, frontmatter, categorizer, fabric_client, filesystem, config, exceptions, __init__ |
| G2.4 | Build CLI with subcommands | ✅ | G2.3 | polish, batch, pipe, rename-only, title-only, frontmatter-only |
| G2.5 | Add config file | ✅ | G2.2 | ~/.obsidian-polish/config.yml with defaults |
| G2.6 | Test all modes | ✅ | G2.5 | Pipe, batch, single file — all verified |
| G2.7 | Delete old backups from .myscripts/ | ✅ | G2.6 | 3 backup dirs deleted |
| G2.8 | Update this TODO | ✅ | G2.7 | — |

### G3: or-bench

**Source**: `or-bench` (598-line Python) + `or-model-select` (410-line Python)
**Target**: `hub/or-bench/` — pip-installable benchmark tool
**Gap**: 64% missing (has Python + cache, needs lib/ + CLI + packaging)
**Handoff**: Not yet written
**Estimate**: 2-3 hours

| ID | Step | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| G3.1 | Write build spec handoff | ✅ | — | Spec at GREENFIELDS/or_bench_spec.md |
| G3.2 | Create hub/or-bench/ scaffold | ✅ | G3.1 | pyproject.toml, .gitignore, LICENSE, package dir |
| G3.3 | Split into lib/ modules | ✅ | G3.2 | 9 modules: cli, benchmark, selector, cache, display, models, config, exceptions, __init__ |
| G3.4 | Build CLI with subcommands | ✅ | G3.3 | bench, list, select, history, last, stats |
| G3.5 | Add terminal UI for live results | ✅ | G3.4 | Colored output with speed tiers (green ≥60, cyan ≥25, yellow ≥10, red <10) |
| G3.6 | Package with pyproject.toml | ✅ | G3.5 | Zero external deps, stdlib only |
| G3.7 | Test with real OpenRouter models | ⬜ | G3.6 | Need API key — skip for now (original script already proven) |
| G3.8 | Update this TODO | ✅ | G3.7 | — |

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
| C1 | Delete `meta/` (empty dir) | ✅ | — | Done 2026-06-05 |
| C2 | Delete backup dirs | ✅ | — | All 5 backup dirs deleted (fabric-graph-agents-backup deleted during E2, slugfile + 3 obsidian-polish backups deleted 2026-06-05) |
| C3 | Deprecate voice_note.sh | ✅ | — | Done 2026-06-05 — added deprecation notice |
| C4 | Review docs/ cross-references | ⬜ | — | **31 files** contain stale `~/.myscripts/` refs (recounted 2026-06-29; paths still resolve, just point to old pre-extraction locations). Bulk find/replace when ready. |

---

## PHASE 4: Stabilization & Hardening

> Deferred to the human. Full context + decision options in `HUMAN.md`.
> Scope deliberately **narrowed**: `.myscripts/` is the focused repo going forward. `hub/` projects are extracted/external.

| ID | Task | Status | Depends On | Notes |
|----|------|--------|-----------|-------|
| S1 | Commit `.myscripts/` working tree | ✅ | — | Snapshot `8091cce` (251 files). Follow-up cleanup commit `273c783` (S3 deletions). Working tree clean. |
| S2 | Version `hub/` projects | ✅ (partial) | S1 | **D1 = Python only (4).** Versioned: ytobs `33da0eb`, reddit-obsidian `3a420d0`, obsidian-polish `fe2a41e`, or-bench `bde22d0` (all `main`, no build artifacts tracked). The 5 shell/config projects remain unversioned — logged in Obsidian vault (`projects/hub-unversioned-shell-projects.md`) for future attention. |
| S3 | Decide greenfield source scripts | ✅ | S1 (comm `273c783`) | **D2 = delete all 5.** Removed `obsidian-polish`, `obsidian-polish-v3`, `or-bench`, `or-model-select`, `reddit_to_markdown.sh` (2,237 lines). Recoverable via snapshot `8091cce`. |
| S4 | Remove junk dirs | ✅ | — | **D3 = delete all 3.** Removed `hub/.mysscripts/`, `hub/temp-sorry-…/` (verbatim mlx-examples clone, recoverable upstream), `.myscripts/dockerfiles/` (empty). |
| S5 | Smoke-verify all packages | ✅ | S2 | All 4 Python packages PASS: ytobs (4.0.0), reddit-obsidian (0.1.0), obsidian-polish (0.1.0), or-bench (0.1.0) — import + `--help` + `--version` all green. |
| S6 | Fix C4 stale doc refs | ⏸️ deferred | — | **D5 = defer** (low severity, paths still resolve on disk). Revisit when docs touched naturally. |

---

## Progress Summary

| Phase | Total Tasks | Done | In Progress | Remaining |
|-------|------------|------|-------------|-----------|
| P0: Audit & Planning | 5 | 5 | 0 | 0 |
| E1: ytobs extraction | 17 | 17 | 0 | 0 |
| E2: fabric-graph-agents | 4 | 4 | 0 | 0 |
| E3: circuit-extractor | 3 | 3 | 0 | 0 |
| E4: fabric-image-analysis | 3 | 3 | 0 | 0 |
| E5: jumpserver-deploy | 3 | 3 | 0 | 0 |
| E6: portable-tmux | 3 | 3 | 0 | 0 |
| G1: reddit-obsidian | 10 | 10 | 0 | 0 |
| G2: obsidian-polish | 8 | 8 | 0 | 0 |
| G3: or-bench | 8 | 7 | 0 | 1 |
| G4-6: Lower greenfields | 3 | 0 | 0 | 3 |
| C: Cleanup | 4 | 3 | 0 | 1 |
| **P1–P3 subtotal** | **71** | **66** | **0** | **5** |
| S: Stabilization (Phase 4) | 6 | 5 | 0 | 1 (S6 deferred per D5) |
| **TOTAL (incl. Phase 4)** | **77** | **71** | **0** | **6** |

**Build status**: 93% of P1–P3 complete on disk (66/71); Phase 4 stabilization executed — 5/6 S-tasks done. 4 Python packages committed, versioned, and smoke-verified (import + `--help` + `--version` all green).

**Campaign health**: ✅ **stabilized**. `.myscripts/` committed (`8091cce` snapshot + `273c783` cleanup); 4 Python hub projects versioned as standalone repos; superseded sources removed; junk dirs cleared; all packages verified. Only S6 (cosmetic doc refs) deferred per D5, plus the pre-existing low-priority items (G3.7 live test, G4–G6).

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
| 2026-05-30 | E1 (ytobs) extracted to hub/ytobs/. 29 item checklist complete. CLI verified. |
| 2026-05-30 | E2 (fabric-graph-agents) extracted to hub/fabric-graph-agents/. 10 item checklist complete. |
| 2026-05-30 | E4 (fabric-image-analysis) 9 files → hub/fabric-image-analysis/ |
| 2026-05-30 | E5 (jumpserver-deploy) 16 files → hub/jumpserver-deploy/ |
| 2026-05-30 | E6 (tmux) 21 files → hub/portable-tmux/ |
| 2026-05-30 | Phase 1 (all extractions) complete. 38/67 tasks (57%). |
| 2026-05-30 | **E1 COMPLETE**. ytobs extracted from .myscripts to hub/ytobs/. All 29 handoff items executed. pip-installable CLI working. |
| 2026-06-02 | **G1 (reddit-obsidian) code complete**. 8 Python modules written (1,696 lines). CLI verified: --version, --help, vault, status, search, --list-processed, bare URL auto-insert all working. Docs + real-thread test pending. 45/67 tasks (67%). |
| 2026-06-02 | **G1 fully complete**. Extractor rewritten from JSON API → HTML scraping of old.reddit.com (Reddit now blocks .json + www.reddit.com). Full E2E test with real AskReddit thread: fetch, cache, status, search, vault, --force, --comments-only all verified. beautifulsoup4 added as dependency. 48/67 tasks (72%). |
| 2026-06-05 | **Organizational review**. Updated AGENTS.md (full project overview), HANDOFF_INDEX.md (complete rewrite with all project statuses), GREENFIELDS/reddit_obsidian_spec.md (marked implemented, noted HTML scraping pivot), NOTES.md (modernized), MASTER_TODO.md (fixed G1.3 note, expanded C4 with stale ref counts). Still 48/67 (72%). |
| 2026-06-05 | **Aliases & PATH fixes**. Added `ytobs`, `reddit-obsidian`, `ro` aliases. Fixed stale fabric-graph-agents PATH entries in ~/.zshrc and ~/.bashrc. |
| 2026-06-05 | **Quick wins (C1, C2a, C3)**. Deleted `meta/` dir, `slugfile.backup`, deprecated `voice_note.sh`. 51/67 (76%). |
| 2026-06-05 | **G2 (obsidian-polish) built**. Full pip-installable app: 9 Python modules, CLI with all subcommands, pipe/batch/single modes, category detection, config management. Spec at GREENFIELDS/obsidian_polish_spec.md. Alias added. C2b backups deleted. 59/67 (88%). |
| 2026-06-05 | **G3 (or-bench) built**. Merged or-bench (598 lines) + or-model-select (410 lines) into pip-installable package. 9 Python modules, 6 subcommands (bench, list, select, history, last, stats). Zero external deps. Alias added. 66/71 (93%). |
| 2026-06-11 | Packages (obsidian-polish, or-bench) further tweaked — files modified on disk. Not reflected in tracker until next update. |
| 2026-06-29 | **Stabilization review (this pass)**. Consultant-level audit of session `ses_185473a13ffe02gDMwSS6rpoda`. Identified 3 governance gaps: (1) entire campaign UNCOMMITTED, hub/ unversioned 0/9 git; (2) greenfield source scripts not deleted (2,237 lines); (3) tracker drift. Reconciled all tracking files to single source of truth (this file). Added Phase 4 (S1–S6 Stabilization, deferred to human). Created `HUMAN.md`. |
| 2026-06-29 | **Phase 4 executed (S1–S5)** against human decisions D1–D5. S1: snapshot commit `8091cce` (251 files) + cleanup commit `273c783` (S3, 2,237 lines deleted). S2: versioned 4 Python projects (ytobs `33da0eb`, reddit-obsidian `3a420d0`, obsidian-polish `fe2a41e`, or-bench `bde22d0`); 5 shell/config projects left unversioned by D1, logged to Obsidian vault. S3: removed 5 superseded greenfield sources. S4: removed 3 junk dirs (`hub/.mysscripts/`, `hub/temp-sorry-…/` mlx-examples clone, `.myscripts/dockerfiles/`). S5: all 4 Python packages smoke-verified PASS. S6 deferred per D5. Campaign now in a done/stabilized state. |
