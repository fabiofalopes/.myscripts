# .myscripts/ — Master Handoff Index

**For**: Any future agent session. Load this file first, then jump to the relevant project handoff.
**Updated**: 2026-05-30

---

## Quick Reference — Which File to Load

| If You Want To... | Load This File |
|-------------------|---------------|
| Extract ytobs from .myscripts to hub/ | `youtube-obsidian/HANDOFF_ytobs_extraction.md` |
| See full audit of ALL projects | `MYSCRIPTS_AUDIT_AND_EXTRACTION_PLAN.md` |
| Extract fabric-graph-agents | (not yet written — run audit doc first) |
| Extract circuit-board-knowledge-extractor | (not yet written) |
| Build reddit-obsidian from scratch (greenfield) | (not yet written — see Table 2 in audit doc) |
| Build obsidian-polish into full app (greenfield) | (not yet written) |
| Build or-bench into full app | (not yet written) |

---

## Handoff Files Created So Far

| File | Project | Status |
|------|---------|--------|
| `MYSCRIPTS_AUDIT_AND_EXTRACTION_PLAN.md` | All of .myscripts | ✅ Complete |
| `youtube-obsidian/HANDOFF_ytobs_extraction.md` | ytobs extraction (29 items) | ✅ Complete |

---

## Projects Still Needing Handoff Files

Based on the extraction plan, these are the next files to create:

### Extraction Projects (existing full apps moving to hub/)

1. **`fabric-graph-agents/HANDOFF_extraction.md`** — migration spec for the 45+ file fabric orchestration system
2. **`circuit-board-knowledge-extractor/HANDOFF_extraction.md`** — migration spec for the OCR system
3. **`fabric-image-analysis/HANDOFF_extraction.md`** — migration spec for image metadata pipeline
4. **`dockerfiles/jumpserver-deploy/HANDOFF_extraction.md`** — migration spec for JumpServer deployment

### Greenfield Projects (scripts → full apps)

5. **`GREENFIELD_reddit_obsidian_spec.md`** — build spec for the reddit extractor app
6. **`GREENFIELD_obsidian_polish_spec.md`** — build spec for modularizing obsidian-polish
7. **`GREENFIELD_or_bench_spec.md`** — build spec for packaging or-bench

---

## Session Commands

To start work on any project, tell the agent:

```
Load the handoff at: ~/projetos/hub/.myscripts/<path>/HANDOFF_*.md
Execute the checklist from Phase 1 through completion.
```

Example for ytobs:

```
Load the handoff at: ~/projetos/hub/.myscripts/youtube-obsidian/HANDOFF_ytobs_extraction.md
Execute the checklist from Phase 1 through Phase 6. Do not skip items.
```

---

## Post-Completion

After each project is extracted/built:

1. Mark it ✅ in `MYSCRIPTS_AUDIT_AND_EXTRACTION_PLAN.md`
2. Move the handoff file to the new project's `archive/` directory
3. Update this index
