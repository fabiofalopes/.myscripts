# Sprint 5: Session Cleanup & Environment Staging

**Priority**: P0 (CRITICAL - Must Do First)
**Effort**: 30 minutes
**Status**: COMPLETE (2025-12-21)

## Objective

Clean up all uncommitted changes from current session. Stage environment for future development.

## Problem

Git status shows loose ends:
- Modified: `youtube-obsidian/` files (unrelated to obsidian-polish)
- Untracked: `AGENTS.md`, `view-kanban.sh`, backup files
- Meta folder: Empty (sub-agent outputs never written)

## Tasks

### 5.1 Handle youtube-obsidian changes
- [x] Review changes to `CONTEXT.md`, `config.py`, `yt`
- [x] Committed as V4.0 release (status/vault commands)

### 5.2 Handle obsidian-polish backups
- [x] Added to .gitignore (*.backup-*, obsidian-polish.backup-*)

### 5.3 Commit or gitignore view-kanban.sh
- [x] Committed as utility script

### 5.4 Commit AGENTS.md
- [x] Added to .gitignore (placeholder only, not ready)

### 5.5 Populate meta/ folder
- [ ] Deferred to Sprint 7 (methodology documentation)

## Success Criteria

- [x] `git status` shows clean working tree
- [x] All decisions documented
- [x] Ready for next sprint

## Completion Notes (2025-12-21)

**Commits made:**
1. `feat(youtube-obsidian): V4.0 - status/vault commands and help docs`
2. `chore: gitignore backup files and AGENTS.md placeholder`
3. `feat: add view-kanban.sh utility for quick kanban board display`

**Files committed:**
- youtube-obsidian V4.0 (7 files, 1877 insertions)
- view-kanban.sh utility

**Files gitignored:**
- *.backup-* patterns
- AGENTS.md (placeholder)

## Dependencies

None - this sprint must happen first.

---

# Sprint 6: Vibe-Kanban Integration

**Priority**: P0 (Must Do)
**Effort**: 1-2 hours
**Status**: PENDING

## Objective

Properly integrate vibe-kanban tool into workflow. Replace `view-kanban.sh` workaround.

## Problem

- vibe-kanban is installed but not used
- Created `view-kanban.sh` as workaround
- Kanban workflow not properly established

## Tasks

### 6.1 Learn vibe-kanban
- [ ] Run `npx vibe-kanban --help`
- [ ] Understand file format requirements
- [ ] Document usage in meta/

### 6.2 Adapt kanban format
- [ ] Ensure `docs/obsidian-polish-kanban.md` is compatible
- [ ] Test rendering with vibe-kanban

### 6.3 Document workflow
- [ ] How to view kanban
- [ ] How to update tasks
- [ ] Integration with sprint workflow

## Success Criteria

- Can run vibe-kanban and see board
- `view-kanban.sh` either removed or documented as alternative
- Workflow documented in meta/

## Dependencies

Sprint 5 (clean environment)

---

# Sprint 7: Meta Methodology Documentation

**Priority**: P1 (Should Do)
**Effort**: 2-3 hours
**Status**: PENDING

## Objective

Write the methodology framework to `meta/` folder. Capture how this agentic development process works.

## Problem

- Sub-agents ran and produced analysis
- Outputs never written to files
- Methodology exists only in conversation context
- Future sessions lose this knowledge

## Tasks

### 7.1 Create meta/ structure
```
meta/
├── METHODOLOGY.md          # Core framework
├── SESSION-LIFECYCLE.md    # How sessions work
├── SPRINT-GUIDE.md         # How to write/run sprints
└── CONTEXT-MANAGEMENT.md   # How to handle context limits
```

### 7.2 Write METHODOLOGY.md
- Agentic development principles
- Sprint structure
- Session handoff protocol
- Document taxonomy

### 7.3 Write SESSION-LIFECYCLE.md
- Start of session checklist
- During session practices
- End of session requirements
- Handoff document format

### 7.4 Write SPRINT-GUIDE.md
- Sprint document template
- How to break down work
- Testing requirements
- Commit conventions

### 7.5 Write CONTEXT-MANAGEMENT.md
- Signs of context overflow
- When to end session
- How to use sub-agents
- Information compression strategies

## Success Criteria

- meta/ folder populated with actionable docs
- New session can bootstrap from these docs
- Methodology is explicit, not implicit

## Dependencies

Sprint 5 (clean environment)

---

# Sprint 8: Sprint 4 Redesign (Pattern Enrichment)

**Priority**: P2 (Nice to Have)
**Effort**: Planning only - 1 hour
**Status**: ON HOLD - User Review

## Objective

Redesign Sprint 4 based on user feedback. Simplify the approach.

## User Vision (Captured)

> "The same way we run fabric patterns for other things... run whatever part of the input through a fabric pattern and append output to frontmatter... rendered as table in Obsidian... gives rich information."

## Key Insights

1. **Simplicity**: Just run fabric patterns, append to frontmatter
2. **Existing patterns**: Use fabric's built-in patterns (e.g., `create_5_sentence_summary`)
3. **Format**: Output as table-renderable YAML in frontmatter
4. **Configuration**: Either fixed set of patterns OR dynamic selection

## Options to Explore

### Option A: Fixed Pattern Set
- Always run same 3-5 patterns
- Simple, predictable
- User knows what to expect

### Option B: Dynamic Selection
- Fetch optimal patterns based on content
- More complex
- Previously explored in past sessions

### Option C: User Flag (REJECTED)
- User specifies patterns via CLI
- Too verbose, rejected by user

## Tasks (When Resumed)

- [ ] List candidate fabric patterns
- [ ] Design frontmatter format for pattern outputs
- [ ] Prototype with one pattern
- [ ] Test Obsidian table rendering
- [ ] Decide Option A vs B

## Dependencies

- Sprint 5, 6, 7 complete
- User review and decision

---

# Sprint Order

```
Sprint 5: Cleanup     [COMPLETE - 2025-12-21]
    ↓
Sprint 6: Vibe-Kanban [Setup tooling]
    ↓
Sprint 7: Meta Docs   [Capture methodology]
    ↓
Sprint 8: Pattern Enrichment [ON HOLD - User Review]
```

## Next Session Start

1. Read this file
2. ~~Execute Sprint 5 (cleanup)~~ DONE
3. ~~Commit this sprint guide~~ DONE
4. Proceed to Sprint 6
