# Obsidian-Polish Enhancement - Kanban Board

**Last Updated**: 2025-12-21
**Status**: Core Complete (Sprints 1, 2A, 3 done)

---

## Done ✅

### [SPRINT-1] Datetime Handling Foundation ✅
**Completed**: 2025-12-21  
**Commit**: `1d8e636`
**Priority**: P0 (Must Do)

Add global datetime capture at script initialization.

**What Was Done**:
- Global datetime variables captured once at startup
- Injected into frontmatter (`created`, `modified`)
- Existing dates preserved

---

### [SPRINT-2A] Cache-Based Backup System ✅
**Completed**: 2025-12-21
**Commit**: `1fe03c7`
**Priority**: P0 (Must Do)

Replace .bak files with centralized cache at `~/.cache/obsidian-polish/`.

**What Was Done**:
- Backups in `~/.cache/obsidian-polish/backups/`
- `index.txt` tracks all operations
- Auto-cleanup (30 days, 10 per file)
- No .bak files in user directories

---

### [SPRINT-3] Category-Based Intelligent Naming ✅
**Completed**: 2025-12-21
**Commit**: `f5d803b`
**Priority**: P1 (Should Do)

Add category prefix to filenames: `{category}-{title}.md`.

**What Was Done**:
- 5-tier detection: tags → frontmatter → title → content → default
- 8 categories: dev, meeting, idea, task, doc, research, personal, note
- `-c, --category CAT` flag for manual override
- Category injected into frontmatter
- Bash 3.x compatible (macOS)

**Examples**:
- `dev-api-integration.md`
- `meeting-weekly-standup.md`
- `note-random-thoughts.md`

---

### [DOC] Project Planning Complete ✅
**Completed**: 2025-12-21

Created comprehensive analysis and implementation plan.

---

## Backlog

### [SPRINT-2B] Rename History Comment Block
**Priority**: P0 (Must Do) - DEFERRED
**Risk**: LOW

Add HTML comment showing rename history in processed files.

**Status**: Decided to skip for now (cache index.txt provides enough history)

---

### [SPRINT-4] Fabric AI Pattern Enrichment
**Priority**: P2 (Nice to Have) - OPTIONAL
**Effort**: 3 days
**Risk**: HIGH

Run additional AI patterns to enrich frontmatter metadata.

**Adds**:
- `--enrich` flag
- summary, key_points, action_items, related_topics fields
- 2-5 min processing per note

**Decision Required**: Proceed / Skip / Defer

---

## To Do

_No tasks currently queued_

---

## In Progress

_No tasks in progress_

---

## Project Summary

### Git Commits
| Sprint | Commit | Description |
|--------|--------|-------------|
| Sprint 1 | `1d8e636` | Datetime handling |
| Sprint 2A | `1fe03c7` | Cache backup system |
| Sprint 3 | `f5d803b` | Category naming |

### Script Evolution
| Version | Lines | Features |
|---------|-------|----------|
| Pre-Sprint | ~450 | Basic polish + rename |
| Sprint 1 | ~500 | + datetime |
| Sprint 2A | ~673 | + cache backup |
| Sprint 3 | ~856 | + category naming |

### Usage
```bash
# Basic polish (no rename)
obsidian-polish note.md

# Polish with AI rename
obsidian-polish -r note.md

# Force category
obsidian-polish -r -c dev note.md

# Dry run
obsidian-polish -r -d note.md
```

---

## Archive

Completed sprint documentation moved to:
`docs/archive/obsidian-polish-2025/`

Contents:
- Sprint implementation guides
- Session handoff documents
- Phase 0 planning guide
