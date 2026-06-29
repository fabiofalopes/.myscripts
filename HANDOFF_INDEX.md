# .myscripts/ — Master Handoff Index

**For**: Any future agent session. Load this for project → handoff-file mapping.
**Updated**: 2026-06-29
**Counts**: DEFER to `MASTER_TODO.md` — it is the single source of truth. This file intentionally carries no task counts to avoid drift.

---

## Where to look

| If you want to... | Load this file |
|-------------------|---------------|
| See real progress + campaign state | `MASTER_TODO.md` (read the "⚠️ CAMPAIGN STATE" header) |
| See open human decisions before acting | `HUMAN.md` |
| See the full audit of ALL projects | `MYSCRIPTS_AUDIT_AND_EXTRACTION_PLAN.md` |
| Work on a specific hub/ project | its handoff in `archive/` (table below) |

---

## Project → Handoff Mapping

### ✅ Completed Extractions (Phase 1 — ALL DONE)

| Project | Extracted To | Handoff Location |
|---------|-------------|-----------------|
| ytobs (youtube-obsidian) | `hub/ytobs/` | `hub/ytobs/archive/HANDOFF_extraction.md` |
| fabric-graph-agents | `hub/fabric-graph-agents/` | `hub/fabric-graph-agents/archive/HANDOFF_extraction.md` |
| circuit-board-extractor | `hub/circuit-extractor/` | `hub/circuit-extractor/archive/HANDOFF_extraction.md` |
| fabric-image-analysis | `hub/fabric-image-analysis/` | `hub/fabric-image-analysis/archive/HANDOFF_extraction.md` |
| jumpserver-deploy | `hub/jumpserver-deploy/` | `hub/jumpserver-deploy/archive/HANDOFF_extraction.md` |
| portable-tmux | `hub/portable-tmux/` | `hub/portable-tmux/archive/HANDOFF_extraction.md` |

### ✅ Completed Greenfields (Phase 2 — ALL DONE)

| Project | Location | Spec / Context |
|---------|----------|----------------|
| reddit-obsidian (G1) | `hub/reddit-obsidian/` | `GREENFIELDS/reddit_obsidian_spec.md` + `hub/reddit-obsidian/CONTEXT.md` |
| obsidian-polish (G2) | `hub/obsidian-polish/` | `GREENFIELDS/obsidian_polish_spec.md` + `hub/obsidian-polish/CONTEXT.md` |
| or-bench (G3) | `hub/or-bench/` | `GREENFIELDS/or_bench_spec.md` |

### ⬜ Deferred (low priority)

| Project | Notes |
|---------|-------|
| tokcount (G4) | Works fine as script |
| slugfile (G5) | Works fine as script |
| mfab (G6) | Works fine as script |

### ⬜ Phase 4: Stabilization (deferred to human)

See `HUMAN.md` and `MASTER_TODO.md` § Phase 4 (S1–S6). Not started.

---

## Session Commands

To start any work, tell the agent:

```
Load: ~/projetos/hub/.myscripts/MASTER_TODO.md
```

For stabilization decisions:
```
Load: ~/projetos/hub/.myscripts/HUMAN.md
```

---

## Post-Completion

After each project is extracted/built:
1. Mark it ✅ in `MASTER_TODO.md` (the source of truth)
2. Archive the handoff in the new project's `archive/` directory
3. Do NOT duplicate counts in this file
