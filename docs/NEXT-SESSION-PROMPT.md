# NEXT SESSION PROMPT - Obsidian-Polish Enhancement Implementation

---

## CONTEXT

You're continuing the obsidian-polish enhancement project. Previous session completed comprehensive planning - all sprint guides are ready, including full vibe-kanban Phase 0 documentation.

**Project Location**: `/Users/fabiofalopes/projetos/hub/.myscripts/`  
**Script**: `obsidian-polish` (443 lines, bash)  
**Goal**: Implement 4 enhancement sprints (datetime, cache, categories, enrichment)

**Documentation Created** (11 files, ~140 KB):
- Master plan: `docs/obsidian-polish-enhancement-project.md`
- Kanban: `docs/obsidian-polish-kanban.md`
- Quick start: `docs/obsidian-polish-quick-start.md`
- **Phase 0 vibe-kanban guide**: `docs/phase-0-vibe-kanban-complete-guide.md` (31 KB, complete)
- Sprint guides: `docs/sprint-{1,2,3,4}-*-implementation.md` (all ready)
- Session summary: `docs/obsidian-polish-session-complete-2025-12-21.md`

---

## APPROACH: TEST VIBE-KANBAN, THEN PROCEED WITH IMPLEMENTATION

### Primary Objective
Implement Sprint 1 (datetime handling) manually following the sprint guide. This is the MAIN FOCUS.

### Secondary Objective
Test vibe-kanban installation and UI to evaluate if it's useful for future sprints or documentation updates.

### Strategy
1. **Install and explore vibe-kanban** (15-30 min) - gather learnings
2. **Implement Sprint 1 manually** (2-3 hours) - primary work
3. **Update documentation** based on both experiences
4. **Decide approach** for remaining sprints based on learnings

---

## PHASE 1: VIBE-KANBAN EXPLORATION (Interactive Testing)

### Step 1: Installation

```bash
npm install -g vibe-kanban
```

**Check and report**:
- Installation location: `which vibe-kanban`
- Package info: `npm list -g vibe-kanban`
- File locations: `ls -la $(npm config get prefix)/lib/node_modules/vibe-kanban/`

### Step 2: First Launch

```bash
cd /Users/fabiofalopes/projetos/hub/.myscripts
npx vibe-kanban
```

**Observe and report**:
- What port does it bind to?
- Does browser auto-open?
- What does terminal output show?
- Does initial setup wizard appear?

### Step 3: Initial Setup (If First Time)

**If setup wizard appears**:
- Which coding agents are detected/available?
- What options are presented?
- Can we skip/configure later?

**Report the UX**: What's the actual experience? Does it match Phase 0 documentation?

### Step 4: Project Discovery

**Check**:
- Does it auto-discover the obsidian-polish repo?
- Are there other projects shown?
- How many projects auto-discovered?

### Step 5: Create Project

**Try creating the obsidian-polish project**:
- Method: "From existing git repository"
- Select: `/Users/fabiofalopes/projetos/hub/.myscripts/`
- Does it work as documented?

### Step 6: Explore UI

**Navigate and report**:
- Can you open project settings?
- What does the kanban board look like (empty)?
- Try creating ONE test task (don't start it, just create):
  - Title: "Test Task - Sprint 1 Preview"
  - Description: Brief summary from `docs/sprint-1-datetime-implementation.md`
- Does it appear in "To Do" column?
- Can you edit/delete it?

### Step 7: Evaluate and Report

**Answer these questions**:
1. Was installation/setup easy or problematic?
2. Does the UI match the Phase 0 documentation?
3. Would manually creating all 4 sprint tasks be tedious?
4. Does the visual board add value vs `./view-kanban.sh`?
5. Is it worth using for AI agent automation?
6. Any surprises or issues?

**Then STOP vibe-kanban testing** - don't go further, don't start AI agents.

**Decision point**: Based on exploration, should we:
- Use vibe-kanban for remaining sprints? (create tasks, let AI work)
- Stick with manual implementation? (follow sprint guides ourselves)
- Hybrid? (manual Sprint 1-2, vibe-kanban for Sprint 3-4)

**Recommendation expected**: Tell me what you think based on actual experience.

---

## PHASE 2: SPRINT 1 IMPLEMENTATION (Main Work)

### Pre-Implementation

**Read sprint guide**:
```bash
cat docs/sprint-1-datetime-implementation.md
```

**Create backup**:
```bash
cp obsidian-polish obsidian-polish.backup-$(date +%Y%m%d-%H%M%S)
```

**Create test file**:
```bash
echo "Test content for Sprint 1" > /tmp/test-sprint1.md
```

### Implementation Steps

**Follow the sprint guide EXACTLY**:

1. **Step 1: Add Global Datetime Variables** (10 min)
   - Location: After line 35
   - Code provided in guide
   - Test: Verify variables set correctly

2. **Step 2: Inject Datetime into Frontmatter** (30 min)
   - Location: After line 294
   - Code provided in guide
   - Logic: Replace AI-generated dates with script dates

3. **Step 3: Add Modified Field for Existing Notes** (30 min)
   - Location: Same as Step 2
   - Handle existing vs new notes
   - Preserve original `created` dates

4. **Step 4: Testing** (1 hour)
   - Test Case 1: New note
   - Test Case 2: Existing note with frontmatter
   - Verify all success criteria

5. **Step 5: Update Help Text** (15 min)
   - Check if changes needed (guide says no changes for Sprint 1)

### Testing Procedure

**Test Case 1: New Note**
```bash
echo "This is a new note about testing datetime" > /tmp/new-note.md
./obsidian-polish /tmp/new-note.md

# Verify:
cat /tmp/new-note.md
# Should have:
# - created: YYYY-MM-DD (today)
# - No modified field
```

**Test Case 2: Existing Note**
```bash
cat > /tmp/existing-note.md << 'EOF'
---
title: Old Note
created: 2024-01-01
---
# Old Note

Content here
EOF

./obsidian-polish /tmp/existing-note.md

# Verify:
cat /tmp/existing-note.md
# Should have:
# - created: 2024-01-01 (PRESERVED)
# - modified: YYYY-MM-DD (today, ADDED)
```

### Completion

**When Sprint 1 complete**:
```bash
# Commit
git add obsidian-polish
git commit -m "feat(datetime): implement Sprint 1 - consistent timestamp capture

- Capture datetime at script start (4 formats for different uses)
- Inject script datetime into frontmatter created field
- Preserve original created date for existing notes
- Add modified field when updating existing notes
- Ensures all operations use consistent timestamps

Sprint 1 complete - ready for Sprint 2"

# Verify
git log --oneline -1
```

---

## PHASE 3: DOCUMENTATION UPDATES

### Based on Vibe-Kanban Testing

**Update Phase 0 guide if needed**:
- Any inaccuracies found?
- Anything missing?
- Better recommendations?

**Location**: `docs/phase-0-vibe-kanban-complete-guide.md`

### Based on Sprint 1 Implementation

**Update session summary**:
- Sprint 1 status: COMPLETE
- Actual time taken: X hours
- Issues encountered: (if any)
- Learnings: (anything not in guide)

**Create**: `docs/obsidian-polish-session-handoff-2025-12-21-implementation.md`

**Update kanban**:
```bash
# Edit: docs/obsidian-polish-kanban.md
# Move Sprint 1 from Backlog → Done
```

---

## PHASE 4: DECISION AND NEXT STEPS

### Evaluate Approach for Remaining Sprints

**Consider**:
1. Sprint 1 implementation experience:
   - Was guide sufficient?
   - Were instructions clear?
   - Any roadblocks?

2. Vibe-kanban evaluation:
   - Is it worth the overhead?
   - Could AI agents handle Sprint 2-4?
   - Manual vs automated trade-offs?

3. Time and effort:
   - Manual: Full control, follow guides step-by-step
   - Vibe-kanban + AI: Faster but needs review/testing

### Recommended Next Session Approaches

**Option A: Continue Manual**
```
Next session prompt:
"Continue obsidian-polish implementation. Sprint 1 complete.
Read: docs/sprint-2-file-management-implementation.md
Implement Sprint 2 following the guide step-by-step."
```

**Option B: Switch to Vibe-Kanban**
```
Next session prompt:
"Continue obsidian-polish implementation. Sprint 1 complete (manual).
Set up vibe-kanban for Sprint 2-4:
- Create Sprint 2A, 2B, 3, 4 tasks in vibe-kanban
- Configure AI agent profile
- Start Sprint 2A with AI agent
- Monitor and review results"
```

**Option C: Hybrid**
```
Next session prompt:
"Continue obsidian-polish implementation. Sprint 1 complete (manual).
Implement Sprint 2 manually (cache system is critical).
Evaluate vibe-kanban for Sprint 3-4 (less critical features)."
```

### What to Report

**Provide**:
1. Vibe-kanban experience summary (2-3 paragraphs)
2. Sprint 1 completion status (done/issues/blockers)
3. Recommended approach for Sprint 2-4 (A/B/C above, with reasoning)
4. Documentation updates needed (if any)
5. Estimated time to complete remaining sprints

---

## IMPORTANT GUIDELINES

### Interaction Expected

**This is an INTERACTIVE session**:
- Report what you see in vibe-kanban (I'll confirm/guide)
- Ask if unclear about sprint guide instructions
- Show me test results (I'll verify correct behavior)
- Discuss decisions (vibe-kanban vs manual)

**Don't assume**:
- If vibe-kanban behaves differently than Phase 0 docs, report it
- If sprint guide has issues, flag them
- If test case fails, show output and ask

### Testing Philosophy

**For vibe-kanban**:
- Explore, don't implement
- Goal: Understand if it's useful
- 15-30 min max

**For Sprint 1**:
- Follow guide rigorously
- Test each step
- Verify success criteria
- This is the main work

### Documentation Updates

**Be thorough**:
- If Phase 0 guide is wrong, fix it
- If sprint guide missing details, add them
- If new learnings, document them
- Update session handoff for next person/session

---

## SUCCESS CRITERIA

**By end of session**:
- ✅ Vibe-kanban tested and evaluated
- ✅ Sprint 1 implemented and working
- ✅ All test cases pass
- ✅ Git commit created
- ✅ Documentation updated
- ✅ Recommendation for next steps clear

**Time estimate**: 3-4 hours total
- Vibe-kanban: 30 min
- Sprint 1: 2-3 hours
- Documentation: 30 min
- Decision/summary: 30 min

---

## QUICK REFERENCE

**Vibe-kanban docs**: `cat docs/phase-0-vibe-kanban-complete-guide.md`  
**Sprint 1 guide**: `cat docs/sprint-1-datetime-implementation.md`  
**Quick start**: `cat docs/obsidian-polish-quick-start.md`  
**Master plan**: `cat docs/obsidian-polish-enhancement-project.md`  
**Visual kanban**: `./view-kanban.sh`

**Project location**: `/Users/fabiofalopes/projetos/hub/.myscripts/`  
**Script**: `obsidian-polish`  
**Test files**: `/tmp/test-*.md`  
**Backup before edits**: `cp obsidian-polish obsidian-polish.backup-$(date +%Y%m%d-%H%M%S)`

---

## START HERE

Begin with:

```bash
cd /Users/fabiofalopes/projetos/hub/.myscripts

# Phase 1: Test vibe-kanban
npm install -g vibe-kanban
npx vibe-kanban
# (Explore UI, report findings)

# Phase 2: Implement Sprint 1
cat docs/sprint-1-datetime-implementation.md
cp obsidian-polish obsidian-polish.backup-$(date +%Y%m%d-%H%M%S)
vim obsidian-polish
# (Follow sprint guide step-by-step)

# Phase 3: Test
echo "Test" > /tmp/test.md
./obsidian-polish /tmp/test.md
cat /tmp/test.md
# (Verify frontmatter has created date)

# Phase 4: Commit
git add obsidian-polish
git commit -m "feat(datetime): implement Sprint 1"

# Phase 5: Report and recommend next steps
```

---

**Ready to start. Let's test, implement, learn, and decide the best path forward based on actual experience.**
