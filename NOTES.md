# .myscripts Notes

## Development Philosophy

This workspace is an **incubator** for CLI tools and Fabric AI patterns. Mature projects get extracted to `~/projetos/hub/` as standalone repos.

### The Workflow:
1. **Prototype** scripts and patterns here in .myscripts/
2. **Extract** mature tools to `~/projetos/hub/<project>/` with proper packaging (pyproject.toml, CLI, tests)
3. **Track** all work in `MASTER_TODO.md` — the single source of truth (66/71 tasks done, 93%; Phase 4 stabilization deferred to human, see `HUMAN.md`)

### What Lives Here vs. hub/

| Location | What |
|----------|------|
| `.myscripts/` | Incubator: mfab, fabric patterns, standalone scripts, docs, build specs |
| `hub/ytobs/` | YouTube → Obsidian (extracted E1) |
| `hub/fabric-graph-agents/` | Fabric orchestration (extracted E2) |
| `hub/circuit-extractor/` | OCR/knowledge extraction (extracted E3) |
| `hub/fabric-image-analysis/` | Image metadata pipeline (extracted E4) |
| `hub/jumpserver-deploy/` | JumpServer deployment (extracted E5) |
| `hub/portable-tmux/` | Portable tmux config (extracted E6) |
| `hub/reddit-obsidian/` | Reddit → Obsidian (greenfield G1, HTML scraping) |
| `hub/obsidian-polish/` | Obsidian note polish (greenfield G2, 9 modules) |
| `hub/or-bench/` | OpenRouter benchmark (greenfield G3, merged or-bench + or-model-select) |

### Key Tracking Files

| File | Purpose |
|------|---------|
| `MASTER_TODO.md` | Single source of truth — 66/71 done (93%); defers to `HUMAN.md` for open decisions |
| `HUMAN.md` | Open human decisions (hub/ git, source cleanup) — read before Phase 4 |
| `HANDOFF_INDEX.md` | Thin pointer to per-project handoffs (no counts, defers to MASTER_TODO) |
| `MYSCRIPTS_AUDIT_AND_EXTRACTION_PLAN.md` | Full audit of all 77 entries |
| `GREENFIELDS/` | Build specs for greenfield projects |

## Repository Structure

### fabric-custom-patterns/
**The source of truth for custom fabric patterns used by scripts in this repo.**

- **Location**: `~/projetos/hub/.myscripts/fabric-custom-patterns/`
- **Purpose**: Contains the actual pattern definitions that scripts depend on
- **Tracked in Git**: ✅ YES - patterns are versioned with the scripts that use them
- **Why tracked**: Scripts like `mfab` depend on specific patterns. Without the patterns, the scripts are useless.

### The Obsidian Connection (Optional Setup)

For comfortable editing of patterns in Obsidian:

```bash
# From your Obsidian vault, create a symlink TO this repo
cd ~/Documents/Obsidian_Vault_01/Vault_01/
ln -s ~/projetos/hub/.myscripts/fabric-custom-patterns fabric-custom-patterns
```

**Important**: The symlink goes FROM Obsidian TO this repo, not the other way around.

### Fabric Configuration

```bash
# Link from fabric's custom patterns directory
ln -s ~/projetos/hub/.myscripts/fabric-custom-patterns ~/.config/fabric/patterns/custom
```

## mfab — Main Project

See `AGENTS.md` § "mfab — Man-Page Fabric REPL" for full architecture and runtime details.

Key patterns: man-router, man-expert, man-titler, session-to-note

## Current Scripts

### txrefine
**Purpose**: Refine voice transcriptions using AI analysis

**Patterns Used**: 
- `transcript-analyzer` - Analyzes transcription for errors
- `transcript-refiner` - Applies corrections

**Usage**: `voicenote | txrefine` or `cat transcript.txt | txrefine`

## Development Tools

### workflow-architect pattern
When designing new workflows: `echo "I want to create a workflow that..." | fabric -p workflow-architect`

**Location**: `fabric-custom-patterns/workflow-architect/`

## Obsidian symlinks + hot reload

- `docs/obsidian-symlinks-cheatsheet.md`
- `docs/obsidian-symlinks-and-hot-reload.md`
- `docs/obsidian-symlinks-session-handoff-2025-12-19.md`

## ⚠️ Known Stale Content

The `docs/` directory has **31 files** carrying stale `~/.myscripts/` references that now point to extracted projects in `~/projetos/hub/`. See MASTER_TODO task C4 / Phase 4 S6 for tracking. The stale paths still resolve on disk — this is cleanup, not breakage.

Files with most stale refs:
- `docs/Fabric-Vision-Index.md` — 15 refs
- `docs/CROSS-REPO-CONFIG-LINKAGES.md` — 13 refs  
- `docs/DOCUMENTATION-INDEX.md` — 10 refs
- `docs/Fabric-Vision-Investigation-Summary.md` — 10 refs
