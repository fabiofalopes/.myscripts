# Obsidian-Polish Enhancement Project - Master Plan

**Project**: obsidian-polish script enhancements  
**Location**: `/Users/fabiofalopes/projetos/hub/.myscripts/obsidian-polish`  
**Start Date**: 2025-12-21  
**Target Completion**: 4 sprints (8 development days)  
**Status**: Planning Complete → Ready for Implementation

---

## Project Overview

Enhance the `obsidian-polish` bash script with four major feature groups:

1. **Datetime Handling** - Consistent timestamps across all operations
2. **File Management** - Cache-based backups + rename history tracking
3. **Intelligent Naming** - Category-based filename prefixes  
4. **Pattern Enrichment** - AI-powered metadata generation

---

## Quick Reference

### Current Implementation Status

- ✅ Planning and architecture complete
- ✅ Previous session work documented
- ⏸️ Awaiting implementation start

### Files to Create/Modify

**Main Script**: `obsidian-polish` (~800-1000 lines after completion)

**New Documentation**:
- This file (master plan)
- Session-specific implementation notes (created per sprint)
- Updated `docs/obsidian-polish.md`

**Test Strategy**: Create `tests/` directory with test scripts per feature

---

## Sprint Structure

Each sprint is designed to be **context-independent** - you can start fresh in any sprint with just this document and the relevant session guide.

### Sprint 1: Foundation (1 day)
**Goal**: Consistent datetime handling  
**Complexity**: LOW  
**Risk**: LOW  
**Session Doc**: ✅ `docs/sprint-1-datetime-implementation.md` (READY)

### Sprint 2: File Management (2 days)
**Goal**: Cache system + rename history  
**Complexity**: MEDIUM  
**Risk**: MEDIUM  
**Session Doc**: ✅ `docs/sprint-2-file-management-implementation.md` (READY)

### Sprint 3: Intelligent Naming (2 days)
**Goal**: Category-based filenames  
**Complexity**: MEDIUM  
**Risk**: MEDIUM  
**Session Doc**: ✅ `docs/sprint-3-intelligent-naming-implementation.md` (READY)

### Sprint 4: Pattern Enrichment (3 days, OPTIONAL)
**Goal**: AI-powered metadata  
**Complexity**: HIGH  
**Risk**: HIGH  
**Session Doc**: ✅ `docs/sprint-4-pattern-enrichment-implementation.md` (READY)

---

## Implementation Strategy

### For AI Agents / Multi-Session Development

Each sprint document will contain:

```markdown
## Sprint Context
- What was done before this sprint
- What needs to be ready to start
- Exact line numbers to modify

## Implementation Steps
- Step-by-step checklist
- Code to add/modify
- Testing procedures

## Handoff for Next Session
- What was completed
- What's still pending
- Known issues
```

### Testing Approach

Create test file per sprint:
```bash
/tmp/test-obsidian-polish.md  # Test content
./obsidian-polish /tmp/test-obsidian-polish.md [flags]
# Verify expected behavior
```

### Rollback Strategy

Git commits after each completed feature:
```bash
git add obsidian-polish
git commit -m "feat(datetime): add consistent timestamp capture"
# Can rollback any feature independently
```

---

## Technical Architecture Summary

### Enhancement 1: Datetime Handling

**Problem**: Inconsistent dates across operations  
**Solution**: Capture at script start, inject everywhere  

**Global Variables** (after line 35):
```bash
SCRIPT_START_TIMESTAMP=$(date +%s)
SCRIPT_START_DATE=$(date '+%Y-%m-%d')
SCRIPT_START_DATETIME=$(date '+%Y-%m-%d %H:%M:%S')
SCRIPT_START_ISO=$(date -Iseconds)
```

**Impact**: All operations use same timestamp

---

### Enhancement 2a: Cache System

**Problem**: .bak files clutter directories  
**Solution**: Centralized cache at `~/.cache/obsidian-polish/`

**Structure**:
```
~/.cache/obsidian-polish/
├── backups/
│   ├── 2025-12-19_143022_5a8f9b_note-md.md
│   └── ...
├── index.txt  (rename tracking)
└── .last_cleanup  (cleanup marker)
```

**Cleanup Policy**:
- Delete files >30 days old
- Keep last 10 backups per source file
- Runs automatically when >100 files or >24h since last cleanup

---

### Enhancement 2b: Rename History Comment

**Problem**: Users can't see file rename history  
**Solution**: HTML comment block in file (user-deletable)

**Format**:
```html
<!-- OBSIDIAN-POLISH-HISTORY-V1
Created: 2025-12-19 14:30:22
2025-12-19 14:30:22 | draft.md | meeting-notes.md
2025-12-19 15:45:10 | meeting-notes.md | dev-q1-planning.md
END-HISTORY -->
```

**Position**: After frontmatter, before title H1  
**Limit**: Last 10 renames

---

### Enhancement 3: Category-Based Naming

**Problem**: Need semantic filenames with category prefixes  
**Solution**: Extract category from tags/title, format as `{category}-{title}.md`

**Algorithm**:
1. Extract first tag from generated frontmatter
2. Filter generic tags (untagged, general, note, misc)
3. If generic, try title pattern matching
4. Fallback to "note" if still generic
5. Sanitize and limit to 15 chars

**Examples**:
- Tags: [dev, tools] + Title: "Obsidian Polish Updates" → `dev-obsidian-polish-updates.md`
- Tags: [meetings] + Title: "Q1 Planning" → `meetings-q1-planning.md`
- Tags: [untagged] + Title: "Random thoughts" → `note-random-thoughts.md`

---

### Enhancement 4: Pattern Enrichment

**Problem**: Want richer metadata from AI analysis  
**Solution**: Run additional Fabric patterns, add to frontmatter

**New Flags**:
```bash
--enrich            # Enable all enrichment
--wisdom            # Add extract_wisdom
--summary           # Add summarize
--patterns          # Add extract_patterns
--rating            # Add rate_content
```

**Enhanced Frontmatter Structure**:
```yaml
---
# Standard fields
title: ...
tags: [...]
created: 2025-12-19
type: meeting
status: active
summary: Brief one-liner

# Enrichment fields (optional)
wisdom: |
  - Key insight 1
  - Key insight 2
content_patterns: |
  - Pattern 1
  - Pattern 2
detailed_summary: |
  Multi-paragraph analysis
content_rating:
  quality: 7/10
  actionability: 8/10
---
```

**Performance**: Each pattern = 1 API call (~2-5 seconds)

---

## Dependency Graph

```
Sprint 1 (Datetime)
├──> Sprint 2a (Cache - needs timestamps)
├──> Sprint 2b (Rename History - needs timestamps)
└──> Sprint 4 (Enrichment - needs consistent dates)

Sprint 2 (File Management)
├──> Sprint 3 (Category Naming - uses rename history)
└──> Independent of enrichment

Sprint 3 (Category Naming)
├──> Needs: Frontmatter generation (existing)
└──> Independent of enrichment

Sprint 4 (Pattern Enrichment)
└──> Needs: All core features stable
```

**Recommendation**: Implement in order (Sprint 1 → 2 → 3 → 4)

---

## Risk Management

### Sprint 1 Risks (LOW)
- Timezone changes mid-script → Capture once at start ✓
- Date format incompatibility → Use Obsidian standard YYYY-MM-DD ✓

### Sprint 2 Risks (MEDIUM)
- Concurrent index.txt writes → Use flock for atomic writes
- Disk space exhaustion → Aggressive cleanup (30 days, 10/file)
- Cache corruption → Validate format, rebuild if needed

### Sprint 3 Risks (MEDIUM)
- Category extraction fails → Multi-tier fallback (tags → title → "note")
- Invalid filename chars → Sanitize to [a-z0-9-]
- Category too long → Limit to 15 chars

### Sprint 4 Risks (HIGH)
- API failures → Graceful skip, continue without enrichment
- Performance impact → Opt-in only, show progress
- Cost concerns → Warn user about 4x API cost

---

## Testing Checklist

### Per-Sprint Testing

**Sprint 1**:
```bash
# Test datetime consistency
./obsidian-polish test.md
# Verify all timestamps match
```

**Sprint 2**:
```bash
# Test cache creation
./obsidian-polish test.md -r
# Verify ~/.cache/obsidian-polish/ exists
# Verify no .bak file in same directory
# Verify rename history in file
```

**Sprint 3**:
```bash
# Test category extraction
echo "Dev meeting notes" > test.md
./obsidian-polish test.md -r
# Verify filename has category prefix
```

**Sprint 4**:
```bash
# Test enrichment
./obsidian-polish test.md --enrich
# Verify additional frontmatter fields
```

### Integration Testing

```bash
# Full workflow
echo "Draft content" > draft.md
./obsidian-polish draft.md -r --enrich

# Verify:
# 1. Frontmatter has consistent created date
# 2. File renamed to {category}-{title}.md
# 3. Rename history comment present
# 4. Backup in cache (not .bak)
# 5. Enriched frontmatter fields present
```

---

## Success Criteria

### Sprint 1 Complete When:
- [ ] Global datetime variables exist
- [ ] Frontmatter uses SCRIPT_START_DATE
- [ ] All operations use same timestamp
- [ ] Modified field added for existing notes

### Sprint 2 Complete When:
- [ ] `~/.cache/obsidian-polish/` directory structure exists
- [ ] Backups go to cache (no .bak in same dir)
- [ ] Rename history appears in files
- [ ] Cleanup runs automatically

### Sprint 3 Complete When:
- [ ] Files renamed with `{category}-{title}.md` format
- [ ] Category extraction works from tags
- [ ] Fallback handles edge cases
- [ ] Generic inputs get "note" prefix

### Sprint 4 Complete When:
- [ ] Enrichment flags work (--wisdom, etc.)
- [ ] Additional frontmatter fields populated
- [ ] Graceful failure if patterns error
- [ ] User warned about API costs

---

## Documentation Requirements

### Update After Implementation

1. **`docs/obsidian-polish.md`** - User-facing documentation
   - New flags and options
   - Cache system explanation
   - Rename history feature
   - Category naming examples
   - Enrichment patterns guide

2. **`docs/obsidian-polish-session-handoff-2025-12-19.md`**
   - Mark as superseded
   - Link to this master plan
   - Note what was implemented

3. **Script help text** (lines 65-100)
   - Add new flags
   - Update examples
   - Note about costs for enrichment

---

## Next Steps

### To Start Implementation

1. **Choose a sprint** (recommend starting with Sprint 1)
2. **Read the sprint-specific doc**: `docs/sprint-N-*.md`
3. **Create a test file**: `echo "test" > /tmp/test-note.md`
4. **Follow the implementation steps** in the sprint doc
5. **Test after each change**
6. **Commit when sprint complete**

### For Multi-Session Development

Each sprint doc is designed to be **context-complete**:
- No need to read entire codebase
- Exact line numbers provided
- Copy-paste code snippets ready
- Clear success criteria

You can start fresh in any session with just:
1. This master plan
2. The relevant sprint doc
3. The current `obsidian-polish` script

---

## Project Contacts & Resources

**Script Location**: `/Users/fabiofalopes/projetos/hub/.myscripts/obsidian-polish`  
**Documentation**: `/Users/fabiofalopes/projetos/hub/.myscripts/docs/`  
**Fabric Patterns**: `~/.config/fabric/patterns/obsidian_*`  
**Cache Location**: `~/.cache/obsidian-polish/` (created in Sprint 2)

**Previous Work**:
- Session handoff doc: `docs/obsidian-polish-session-handoff-2025-12-19.md`
- Existing documentation: `docs/obsidian-polish.md`

---

## Changelog

**2025-12-21**: Project planning complete, master plan created  
**2025-12-19**: Previous session - rename fixes and cache design  

---

**Ready to implement?** Start with Sprint 1: `docs/sprint-1-datetime-implementation.md`
