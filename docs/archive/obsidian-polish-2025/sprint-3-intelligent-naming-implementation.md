# Sprint 3: Intelligent Naming Implementation

**Duration**: 2 days  
**Complexity**: MEDIUM-HIGH  
**Risk**: LOW  
**Dependencies**: Sprint 1 (datetime), Sprint 2 (cache system)

---

## Sprint Goal

Implement semantic filename generation using category prefixes derived from Obsidian tags, frontmatter, or AI-analyzed content.

---

## Pre-Implementation Checklist

- [ ] Sprint 1 completed (datetime handling)
- [ ] Sprint 2 completed (cache + rename history)
- [ ] Read master plan: `obsidian-polish-enhancement-project.md`
- [ ] Backup script: `cp obsidian-polish obsidian-polish.backup-sprint3`
- [ ] Current script at: `/Users/fabiofalopes/projetos/hub/.myscripts/obsidian-polish`

---

## Current State Analysis

**Current behavior** (lines 351-391):
- Generates filename from slugified title only
- Format: `{slugified-title}.md`
- No semantic categorization
- Example: `docker-kubernetes-deployment.md`

**Target behavior**:
- Detect category from tags/content
- Format: `{category}-{slugified-title}.md`
- Example: `dev-docker-kubernetes-deployment.md`

**Categories to support**:
- `dev` - Development, coding, programming
- `meeting` - Meetings, discussions, calls
- `idea` - Ideas, brainstorming, concepts
- `task` - Tasks, todos, action items
- `note` - General notes (default fallback)
- `doc` - Documentation, reference materials
- `research` - Research, analysis, investigations
- `personal` - Personal notes, journaling

---

## Architecture Overview

### Category Detection Pipeline

```
1. Check Obsidian tags (highest priority)
   ↓
2. Check frontmatter `category` field
   ↓
3. Analyze title keywords
   ↓
4. Analyze content keywords
   ↓
5. Default to "note"
```

### Category Mapping Rules

**Tag-based detection** (exact match):
```yaml
#development, #coding, #programming, #dev → dev
#meeting, #call, #discussion, #standup → meeting
#idea, #brainstorm, #concept → idea
#task, #todo, #action → task
#documentation, #docs, #reference → doc
#research, #analysis, #investigation → research
#personal, #journal, #diary → personal
```

**Keyword-based detection** (fuzzy match in title/content):
```yaml
dev: ["code", "function", "class", "bug", "debug", "api", "git", "commit"]
meeting: ["meeting", "discussed", "agenda", "attendees", "minutes"]
idea: ["idea", "brainstorm", "concept", "thought", "maybe"]
task: ["todo", "action item", "task", "deadline", "complete"]
doc: ["documentation", "reference", "guide", "tutorial", "how-to"]
research: ["research", "analysis", "findings", "study", "investigate"]
personal: ["journal", "today", "felt", "reflection", "personal"]
```

### Filename Examples

| Original Title | Detected Category | Final Filename |
|---------------|-------------------|----------------|
| "Docker Kubernetes Guide" | dev (keyword: "guide") | `dev-docker-kubernetes-guide.md` |
| "Q1 Planning Meeting Notes" | meeting (keyword) | `meeting-q1-planning-notes.md` |
| "App Redesign Concept" | idea (keyword) | `idea-app-redesign-concept.md` |
| "Fix Login Bug by Friday" | task (keyword) | `task-fix-login-bug-friday.md` |
| "Random Thoughts" | note (default) | `note-random-thoughts.md` |

---

## Implementation Steps

### Step 1: Add Category Configuration (15 min)

**Location**: After cache configuration (after line 40, with Sprint 2 additions)

**Add these lines**:

```bash
# ========== CATEGORY CONFIGURATION ==========
# Categories for intelligent filename prefixes

# Tag-to-category mapping (Obsidian tags)
declare -A TAG_CATEGORIES=(
    ["development"]="dev"
    ["coding"]="dev"
    ["programming"]="dev"
    ["dev"]="dev"
    ["meeting"]="meeting"
    ["call"]="meeting"
    ["discussion"]="meeting"
    ["standup"]="meeting"
    ["idea"]="idea"
    ["brainstorm"]="idea"
    ["concept"]="idea"
    ["task"]="task"
    ["todo"]="task"
    ["action"]="task"
    ["documentation"]="doc"
    ["docs"]="doc"
    ["reference"]="doc"
    ["research"]="research"
    ["analysis"]="research"
    ["investigation"]="research"
    ["personal"]="personal"
    ["journal"]="personal"
    ["diary"]="personal"
)

# Keyword-to-category mapping (fuzzy matching)
declare -A KEYWORD_CATEGORIES=(
    ["dev"]="code|function|class|bug|debug|api|git|commit|script|deploy"
    ["meeting"]="meeting|discussed|agenda|attendees|minutes|call|sync"
    ["idea"]="idea|brainstorm|concept|thought|maybe|vision|dream"
    ["task"]="todo|action item|task|deadline|complete|finish|assign"
    ["doc"]="documentation|reference|guide|tutorial|how-to|manual"
    ["research"]="research|analysis|findings|study|investigate|explore"
    ["personal"]="journal|today|felt|reflection|personal|mood|diary"
)

# Default category when no match found
DEFAULT_CATEGORY="note"
```

---

### Step 2: Implement Category Detection Function (1 hour)

**Location**: After cache functions (around line 150, after `add_rename_history()`)

**Add this function**:

```bash
# Detect category from tags, frontmatter, or content
detect_category() {
    local title="$1"
    local frontmatter="$2"
    local content="$3"
    
    # Priority 1: Check Obsidian tags in frontmatter
    if [ -n "$frontmatter" ]; then
        # Extract tags line (format: "tags: [tag1, tag2, tag3]" or "tags:\n  - tag1\n  - tag2")
        local tags=$(echo "$frontmatter" | grep -A 10 "^tags:" | sed 's/tags://g' | tr -d '[],-' | tr '\n' ' ' | tr '[:upper:]' '[:lower:]')
        
        # Check each tag against mapping
        for tag in $tags; do
            tag=$(echo "$tag" | xargs)  # trim whitespace
            if [ -n "${TAG_CATEGORIES[$tag]}" ]; then
                echo "${TAG_CATEGORIES[$tag]}"
                return 0
            fi
        done
    fi
    
    # Priority 2: Check frontmatter category field
    if [ -n "$frontmatter" ]; then
        local fm_category=$(echo "$frontmatter" | grep "^category:" | sed 's/^category: *//g' | tr -d '"' | tr '[:upper:]' '[:lower:]' | xargs)
        if [ -n "$fm_category" ]; then
            # Validate it's a known category
            case "$fm_category" in
                dev|meeting|idea|task|doc|research|personal|note)
                    echo "$fm_category"
                    return 0
                    ;;
            esac
        fi
    fi
    
    # Priority 3: Keyword matching in title (highest weight)
    local title_lower=$(echo "$title" | tr '[:upper:]' '[:lower:]')
    for category in "${!KEYWORD_CATEGORIES[@]}"; do
        local keywords="${KEYWORD_CATEGORIES[$category]}"
        if echo "$title_lower" | grep -qE "$keywords"; then
            echo "$category"
            return 0
        fi
    done
    
    # Priority 4: Keyword matching in content (lower weight)
    local content_lower=$(echo "$content" | head -50 | tr '[:upper:]' '[:lower:]')  # First 50 lines only
    for category in "${!KEYWORD_CATEGORIES[@]}"; do
        local keywords="${KEYWORD_CATEGORIES[$category]}"
        # Require multiple keyword matches for content-based detection (reduce false positives)
        local match_count=$(echo "$content_lower" | grep -oE "$keywords" | wc -l | xargs)
        if [ "$match_count" -ge 2 ]; then
            echo "$category"
            return 0
        fi
    done
    
    # Priority 5: Default fallback
    echo "$DEFAULT_CATEGORY"
}
```

**Testing Step 2**:
```bash
# Test tag-based detection
FRONTMATTER="---
tags: [development, coding]
---"
detect_category "Some Title" "$FRONTMATTER" ""
# Should output: dev

# Test keyword in title
detect_category "Fix Bug in Login API" "" ""
# Should output: dev

# Test default fallback
detect_category "Random Thoughts" "" ""
# Should output: note
```

---

### Step 3: Modify Rename Logic to Use Categories (45 min)

**Location**: Lines 351-391 (rename operation section)

**FIND this code** (around line 360):
```bash
if [ "$RENAME_FILE" = true ] && [ -n "$TITLE" ]; then
    # Generate new filename
    SLUGIFIED_TITLE=$(slugify "$TITLE")
    DIR=$(dirname "$INPUT_FILE")
    NEW_FILE="${DIR}/${SLUGIFIED_TITLE}.md"
```

**REPLACE with**:
```bash
if [ "$RENAME_FILE" = true ] && [ -n "$TITLE" ]; then
    # Detect category for intelligent naming
    CATEGORY=$(detect_category "$TITLE" "$FRONTMATTER" "$NOTE_CONTENT")
    print_status "Detected category: $CATEGORY"
    
    # Generate new filename with category prefix
    SLUGIFIED_TITLE=$(slugify "$TITLE")
    DIR=$(dirname "$INPUT_FILE")
    NEW_FILE="${DIR}/${CATEGORY}-${SLUGIFIED_TITLE}.md"
```

**Why add to rename section**:
- Category detection happens when we have full context (title + frontmatter)
- Rename already requires user confirmation (safe to add intelligence)
- Category prefix is permanent once set

---

### Step 4: Add Category Override Flag (30 min)

**Purpose**: Allow users to manually specify category

**Location 1**: Help text (around line 80)

**ADD to help**:
```bash
  -r, --rename-file      Rename file based on generated title
  -c, --category CAT     Override category detection (dev|meeting|idea|task|doc|research|personal|note)
```

**Location 2**: Argument parsing (around line 130)

**ADD case block**:
```bash
-c|--category)
    CATEGORY_OVERRIDE="$2"
    # Validate category
    case "$CATEGORY_OVERRIDE" in
        dev|meeting|idea|task|doc|research|personal|note)
            ;;
        *)
            print_error "Invalid category: $CATEGORY_OVERRIDE"
            echo "Valid categories: dev, meeting, idea, task, doc, research, personal, note"
            exit 1
            ;;
    esac
    shift 2
    ;;
```

**Location 3**: Variable defaults (around line 115)

**ADD**:
```bash
CATEGORY_OVERRIDE=""
```

**Location 4**: Modify Step 3 code to check override

**UPDATE the detect_category call**:
```bash
# Detect category for intelligent naming
if [ -n "$CATEGORY_OVERRIDE" ]; then
    CATEGORY="$CATEGORY_OVERRIDE"
    print_status "Using override category: $CATEGORY"
else
    CATEGORY=$(detect_category "$TITLE" "$FRONTMATTER" "$NOTE_CONTENT")
    print_status "Detected category: $CATEGORY"
fi
```

---

### Step 5: Add Category to Frontmatter (30 min)

**Purpose**: Make detected category explicit in file metadata

**Location**: After frontmatter injection in Sprint 1 code (around line 300)

**FIND** (from Sprint 1):
```bash
# Inject consistent datetime
if [ -n "$FRONTMATTER" ]; then
    # ... created/modified field injection ...
fi
```

**ADD AFTER datetime injection**:
```bash
# Add category to frontmatter if detected
if [ "$RENAME_FILE" = true ] && [ -n "$CATEGORY" ]; then
    # Check if frontmatter already has category field
    if echo "$FRONTMATTER" | grep -q "^category:"; then
        # Replace existing category
        FRONTMATTER=$(echo "$FRONTMATTER" | sed "s/^category: .*/category: $CATEGORY/")
        print_status "Updated category in frontmatter: $CATEGORY"
    else
        # Add category field (insert after created/modified)
        FRONTMATTER=$(echo "$FRONTMATTER" | awk -v cat="$CATEGORY" '
            /^created:/ { print; print "category: " cat; next }
            { print }
        ')
        print_status "Added category to frontmatter: $CATEGORY"
    fi
fi
```

**Why add to frontmatter**:
- Makes category queryable in Obsidian
- Allows Dataview/Templater plugins to use it
- Preserves category across future renames

---

### Step 6: Testing (2 hours)

**Test Case 1: Tag-Based Category**
```bash
cat > /tmp/test-tag-category.md << 'EOF'
---
tags: [development, python]
---

# Python Script

This script handles API requests.
EOF

./obsidian-polish /tmp/test-tag-category.md -r -y

# Verify:
# 1. File renamed to: dev-python-script.md
# 2. Frontmatter has: category: dev
# 3. Console shows: "Detected category: dev"
```

**Test Case 2: Keyword-Based Category (Title)**
```bash
echo "# Meeting Notes from Q1 Planning" > /tmp/test-keyword.md
./obsidian-polish /tmp/test-keyword.md -r -y

# Verify:
# 1. File renamed to: meeting-notes-q1-planning.md  
# 2. Category detected from keyword "meeting"
```

**Test Case 3: Keyword-Based Category (Content)**
```bash
cat > /tmp/test-content-keyword.md << 'EOF'
# Project Findings

After extensive research and analysis, we investigated several approaches.
The study revealed interesting patterns in the data.
EOF

./obsidian-polish /tmp/test-content-keyword.md -r -y

# Verify:
# 1. Detected category: research (from "research", "analysis", "study" keywords)
# 2. File renamed to: research-project-findings.md
```

**Test Case 4: Category Override**
```bash
echo "# Random Note About Stuff" > /tmp/test-override.md
./obsidian-polish /tmp/test-override.md -r -c task -y

# Verify:
# 1. File renamed to: task-random-note-about-stuff.md
# 2. Console shows: "Using override category: task"
# 3. Frontmatter has: category: task
```

**Test Case 5: Default Fallback**
```bash
echo "# Just Some Thoughts" > /tmp/test-default.md
./obsidian-polish /tmp/test-default.md -r -y

# Verify:
# 1. File renamed to: note-just-some-thoughts.md
# 2. Default category "note" applied
```

**Test Case 6: Invalid Category Override**
```bash
./obsidian-polish /tmp/test.md -c invalid-category

# Verify:
# 1. Error message shown
# 2. Script exits without processing
# 3. Shows valid category list
```

**Test Case 7: Frontmatter Category Field**
```bash
cat > /tmp/test-fm-category.md << 'EOF'
---
title: Some Note
category: personal
---

Content here.
EOF

./obsidian-polish /tmp/test-fm-category.md -r -y

# Verify:
# 1. File renamed to: personal-some-note.md
# 2. Frontmatter category preserved
```

---

## Sprint Completion Checklist

- [ ] Category configuration added (tag mappings, keyword mappings)
- [ ] `detect_category()` function implemented
- [ ] Rename logic updated to use category prefix
- [ ] `--category` override flag added (help, parsing, validation)
- [ ] Category added to frontmatter
- [ ] Test Case 1 passes (tag-based)
- [ ] Test Case 2 passes (keyword in title)
- [ ] Test Case 3 passes (keyword in content)
- [ ] Test Case 4 passes (override)
- [ ] Test Case 5 passes (default fallback)
- [ ] Test Case 6 passes (invalid override)
- [ ] Test Case 7 passes (frontmatter category)
- [ ] No regressions in existing functionality
- [ ] Git commit created

---

## Commit Message

```bash
git add obsidian-polish
git commit -m "feat(naming): implement intelligent category-based filenames

- Add category detection from tags, frontmatter, or content keywords
- Support 8 categories: dev, meeting, idea, task, doc, research, personal, note
- Filename format: {category}-{slugified-title}.md
- Add --category flag for manual override
- Inject detected category into frontmatter
- Priority: tags > frontmatter > title keywords > content keywords > default

Category detection:
- Tag-based: Exact match on Obsidian tags (highest priority)
- Frontmatter: Explicit category field
- Title keywords: Pattern matching in title
- Content keywords: Pattern matching in first 50 lines (2+ matches required)
- Default: 'note' fallback

Examples:
- 'Fix Login Bug' → dev-fix-login-bug.md
- 'Q1 Planning Meeting' → meeting-q1-planning.md
- 'App Redesign Concept' → idea-app-redesign-concept.md

Closes Sprint 3 of obsidian-polish enhancement project"
```

---

## Handoff to Next Sprint

**What was completed**:
✅ Category detection with 4-tier priority system  
✅ 8 semantic categories supported  
✅ Filename format: `{category}-{slugified-title}.md`  
✅ Manual category override via `--category` flag  
✅ Category injected into frontmatter metadata  

**What's available for Sprint 4**:
- `detect_category()` - Can be extended for AI-enhanced detection
- `CATEGORY` variable - Available after rename decision
- Category mappings - Can be expanded with new categories
- Frontmatter category field - Can be used by additional patterns

**Ready for**: Sprint 4 (Pattern Enrichment - OPTIONAL)

---

## Troubleshooting

**Issue**: Category always defaults to "note"  
**Fix**: Check keyword regex. Test with:
```bash
echo "meeting notes" | grep -qE "meeting|discussed|agenda" && echo "MATCH"
```

**Issue**: Associative arrays not working (`TAG_CATEGORIES`)  
**Fix**: Requires bash 4+. Check version: `bash --version`  
On macOS, install newer bash: `brew install bash`

**Issue**: Category detection too aggressive (false positives)  
**Fix**: Increase content match threshold:
```bash
if [ "$match_count" -ge 3 ]; then  # Changed from 2 to 3
```

**Issue**: Tags not detected from frontmatter  
**Fix**: Debug tag extraction:
```bash
echo "$FRONTMATTER" | grep -A 10 "^tags:"
```
Check both formats: `tags: [a, b]` and `tags:\n  - a\n  - b`

**Issue**: Filename too long with category prefix  
**Fix**: Already handled in Sprint 1 (100 char truncation applies to full filename)

---

## Enhancement Ideas (Post-Sprint)

1. **Sub-categories**: `dev-backend-api-design.md`, `dev-frontend-ui-component.md`
2. **AI-enhanced detection**: Use Fabric pattern to classify content
3. **Category statistics**: Track most-used categories in cache
4. **Category aliases**: Allow user-defined category mappings
5. **Interactive mode**: Prompt user to confirm/change detected category

---

## Next Session Quick Start

1. Verify Sprint 3 completed (check for `detect_category()` function)
2. Test category detection: Create notes with different tags/keywords
3. Check renamed filenames have category prefixes
4. Optionally proceed to Sprint 4: `sprint-4-pattern-enrichment-implementation.md`
5. Or finalize project: Update documentation, create final commit
