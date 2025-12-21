# Sprint 1: Datetime Handling Implementation

**Duration**: 1 day  
**Complexity**: LOW  
**Risk**: LOW  
**Dependencies**: None (can start immediately)

---

## Sprint Goal

Capture system datetime at script initialization and use it consistently across all operations (frontmatter, cache, rename history).

---

## Pre-Implementation Checklist

- [ ] Read master plan: `obsidian-polish-enhancement-project.md`
- [ ] Current script at: `/Users/fabiofalopes/projetos/hub/.myscripts/obsidian-polish`
- [ ] Create test file: `echo "test content" > /tmp/test-note.md`

---

## Current State Analysis

**Problem**: The script currently:
1. Has no global datetime capture
2. Lets Fabric AI patterns generate dates (inconsistent, timezone issues)
3. Uses different timestamps for different operations

**Line Numbers** (current script - 443 lines):
- Line 35: After color definitions, before helper functions
- Line 292: After frontmatter parsing (where we need to inject datetime)
- No datetime variables exist yet

---

## Implementation Steps

### Step 1: Add Global Datetime Variables (10 min)

**Location**: After line 35 (after `NC='\033[0m'`)

**Add these lines**:

```bash
# ========== DATETIME CAPTURE ==========
# Captured at script start for consistency across all operations
SCRIPT_START_TIMESTAMP=$(date +%s)
SCRIPT_START_DATE=$(date '+%Y-%m-%d')
SCRIPT_START_DATETIME=$(date '+%Y-%m-%d %H:%M:%S')
SCRIPT_START_ISO=$(date -Iseconds)
```

**Why each format**:
- `SCRIPT_START_TIMESTAMP`: Unix timestamp for calculations
- `SCRIPT_START_DATE`: YYYY-MM-DD for frontmatter `created` field
- `SCRIPT_START_DATETIME`: Human-readable for rename history
- `SCRIPT_START_ISO`: ISO 8601 for cache index

---

### Step 2: Inject Datetime into Frontmatter (30 min)

**Location**: After line 292 (after frontmatter is parsed from AI pattern)

**Current code** (lines 276-294):
```bash
# Parse the combined result
TITLE=$(echo "$RESULT" | grep "^TITLE:" | sed 's/^TITLE: //')

# Extract frontmatter (everything after "FRONTMATTER:" line...)
FRONTMATTER=$(echo "$RESULT" | awk '...')

print_success "Generated title and frontmatter"
```

**Add after line 294**:

```bash
# ========== INJECT CONSISTENT DATETIME ==========
# Force script datetime over AI-generated date for consistency
if [ -n "$FRONTMATTER" ]; then
    # Check if frontmatter has a created field
    if echo "$FRONTMATTER" | grep -q "^created:"; then
        # Replace with our captured date
        FRONTMATTER=$(echo "$FRONTMATTER" | sed "s/^created: .*/created: $SCRIPT_START_DATE/")
        print_status "Using script datetime: $SCRIPT_START_DATE"
    else
        # Add created field if missing (insert after opening ---)
        FRONTMATTER=$(echo "$FRONTMATTER" | awk -v date="$SCRIPT_START_DATE" '
            NR==1 { print; print "created: " date; next }
            { print }
        ')
        print_status "Added created field: $SCRIPT_START_DATE"
    fi
fi
```

---

### Step 3: Add Modified Field for Existing Notes (30 min)

**Location**: Same place as Step 2 (after datetime injection)

**Add this logic**:

```bash
# Add 'modified' field if note already had frontmatter
if [ "$HAS_FRONTMATTER" = true ]; then
    # This is an existing note being updated
    FRONTMATTER=$(echo "$FRONTMATTER" | awk -v date="$SCRIPT_START_DATE" '
        # Add modified field before closing ---
        /^---$/ && NR > 1 { 
            print "modified: " date
            print
            next
        }
        { print }
    ')
    print_status "Added modified field (existing note): $SCRIPT_START_DATE"
fi
```

**Logic**: If file already had frontmatter (detected at line 210), it's an existing note → add `modified` field while preserving original `created`.

---

### Step 4: Testing (1 hour)

**Test Case 1: New Note**
```bash
echo "This is a new note about testing datetime" > /tmp/new-note.md
./obsidian-polish /tmp/new-note.md

# Verify:
# 1. Frontmatter has created: YYYY-MM-DD (today's date)
# 2. No modified field (new note)
# 3. Date matches script execution time
```

**Test Case 2: Existing Note with Frontmatter**
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
# 1. created: still 2024-01-01 (preserved)
# 2. modified: YYYY-MM-DD (today's date added)
```

**Wait, issue!** - The current script REPLACES frontmatter entirely (lines 210-222). We need to handle this carefully.

**Fix for Step 3** (revised):

```bash
# Detect original created date if frontmatter exists
ORIGINAL_CREATED=""
if [ "$HAS_FRONTMATTER" = true ]; then
    # Extract original created date before AI regeneration
    ORIGINAL_CREATED=$(echo "$NOTE_CONTENT" | awk '
        /^---$/ { if (++dashes == 2) exit }
        dashes == 1 && /^created:/ { print $2; exit }
    ')
    print_status "Preserved original created date: $ORIGINAL_CREATED"
fi

# ... (AI pattern runs, generates new frontmatter) ...

# After frontmatter injection (Step 2 code):
if [ "$HAS_FRONTMATTER" = true ] && [ -n "$ORIGINAL_CREATED" ]; then
    # Replace created with original, add modified
    FRONTMATTER=$(echo "$FRONTMATTER" | sed "s/^created: .*/created: $ORIGINAL_CREATED/")
    FRONTMATTER=$(echo "$FRONTMATTER" | awk -v date="$SCRIPT_START_DATE" '
        /^---$/ && NR > 1 { 
            print "modified: " date
            print
            next
        }
        { print }
    ')
    print_status "Preserved created: $ORIGINAL_CREATED, added modified: $SCRIPT_START_DATE"
else
    # New note, just use script date for created
    FRONTMATTER=$(echo "$FRONTMATTER" | sed "s/^created: .*/created: $SCRIPT_START_DATE/")
    print_status "New note, created: $SCRIPT_START_DATE"
fi
```

**Test again with revised code**.

---

### Step 5: Update Help Text (15 min)

**Location**: Lines 65-100 (help function)

**No changes needed** for Sprint 1 - datetime is automatic, no new flags.

---

## Sprint Completion Checklist

- [ ] Global datetime variables added (after line 35)
- [ ] Frontmatter injection works (after line 294)
- [ ] New notes get `created: <script-date>`
- [ ] Existing notes preserve `created`, add `modified`
- [ ] Test Case 1 passes (new note)
- [ ] Test Case 2 passes (existing note)
- [ ] No errors when running script
- [ ] Git commit created

---

## Commit Message

```bash
git add obsidian-polish
git commit -m "feat(datetime): add consistent timestamp capture and injection

- Capture datetime at script start (4 formats for different uses)
- Inject script datetime into frontmatter created field
- Preserve original created date for existing notes
- Add modified field when updating existing notes
- Ensures all operations use consistent timestamps

Closes Sprint 1 of obsidian-polish enhancement project"
```

---

## Handoff to Next Sprint

**What was completed**:
✅ Datetime capture at script initialization  
✅ Consistent dates in frontmatter  
✅ Original date preservation for existing notes  
✅ Modified field tracking for updates  

**What's available for next sprints**:
- `$SCRIPT_START_TIMESTAMP` - Unix timestamp
- `$SCRIPT_START_DATE` - YYYY-MM-DD (for frontmatter)
- `$SCRIPT_START_DATETIME` - YYYY-MM-DD HH:MM:SS (for history)
- `$SCRIPT_START_ISO` - ISO 8601 (for cache index)

**Ready for**: Sprint 2 (Cache System + Rename History)

---

## Troubleshooting

**Issue**: `sed: -e expression #1, char X: unknown option to 's'`  
**Fix**: Dates contain slashes, escape them or use different delimiter: `sed "s|^created: .*|created: $SCRIPT_START_DATE|"`

**Issue**: AWK not inserting field correctly  
**Fix**: Test AWK command separately:
```bash
echo "$FRONTMATTER" | awk -v date="2025-12-21" '...'
```

**Issue**: Modified field appears multiple times  
**Fix**: The AWK script should only trigger on the closing `---` (second occurrence, `NR > 1`)

---

## Next Session Quick Start

1. Read this doc
2. Verify Sprint 1 was completed (check for datetime variables after line 35)
3. Run test cases to confirm functionality
4. Proceed to Sprint 2: `sprint-2-file-management-implementation.md`
