# Sprint 5: Session Cleanup & Environment Staging

**Priority**: P0 (CRITICAL - Must Do First)
**Effort**: 30 minutes
**Status**: PENDING

## Objective

Clean up all uncommitted changes from current session. Stage environment for future development.

## Problem

Git status shows loose ends:
- Modified: `youtube-obsidian/` files (unrelated to obsidian-polish)
- Untracked: `AGENTS.md`, `view-kanban.sh`, backup files
- Meta folder: Empty (sub-agent outputs never written)

## Tasks

### 5.1 Handle youtube-obsidian changes
- [ ] Review changes to `CONTEXT.md`, `config.py`, `yt`
- [ ] Decide: commit separately or stash

### 5.2 Handle obsidian-polish backups
- [ ] Decide: keep in repo or gitignore
- [ ] Files: `obsidian-polish.backup-*`

### 5.3 Commit or gitignore view-kanban.sh
- [ ] This was a workaround for not using vibe-kanban properly
- [ ] Decide: keep as utility or remove

### 5.4 Commit AGENTS.md
- [ ] Review content
- [ ] Commit if valuable for project context

### 5.5 Populate meta/ folder
- [ ] Write methodology framework from sub-agent outputs
- [ ] This was promised but never done

## Success Criteria

- `git status` shows clean working tree
- All decisions documented
- Ready for next sprint

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
Sprint 5: Cleanup     [CRITICAL - Do First]
    ↓
Sprint 6: Vibe-Kanban [Setup tooling]
    ↓
Sprint 7: Meta Docs   [Capture methodology]
    ↓
Sprint 8: Pattern Enrichment [ON HOLD - User Review]
```

## Next Session Start

1. Read this file
2. Execute Sprint 5 (cleanup)
3. Commit this sprint guide
4. Proceed to Sprint 6
