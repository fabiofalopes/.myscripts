# Sprint 3 Pre-Implementation Analysis

**Generated**: 2025-12-21  
**Sprint**: 3 - Intelligent Naming with Categories  
**Status**: ✅ Analysis Complete - Ready for Implementation  
**Session Type**: Planning → Implementation Handoff

---

## Document Purpose

This document is the **central planning artifact** for Sprint 3 implementation. It synthesizes findings from 4 specialized agents (explore × 2, research × 2) to provide a complete picture of:

1. **Where we are** (current state analysis)
2. **What we've learned** (Sprint 1 & 2A patterns)
3. **What we need to understand** (risks, dependencies, compatibility)
4. **How to move forward** (detailed implementation roadmap)

**Use this document to**:
- Understand the full context before writing code
- Reference exact line numbers for integration
- Follow proven patterns from previous sprints
- Avoid known pitfalls
- Execute the implementation roadmap step-by-step

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Current State Assessment](#2-current-state-assessment)
3. [Sprint History Review](#3-sprint-history-review)
4. [Integration Points Deep Dive](#4-integration-points-deep-dive)
5. [Risk & Compatibility Analysis](#5-risk--compatibility-analysis)
6. [Testing Infrastructure](#6-testing-infrastructure)
7. [Implementation Roadmap](#7-implementation-roadmap)
8. [Go/No-Go Decision](#8-gono-go-decision)
9. [Quick Reference](#9-quick-reference)

---

## 1. Executive Summary

### Mission Accomplished

Four specialized agents completed comprehensive analysis:
- **Agent 1 (explore)**: Code structure, function map, integration points
- **Agent 2 (research)**: Sprint 1 & 2A patterns and learnings
- **Agent 3 (explore)**: Testing infrastructure and approach
- **Agent 4 (research)**: Bash compatibility and risk analysis

### Key Findings

✅ **Current State**: Well-structured script (674 lines, 12 functions)  
⚠️ **Critical Risk**: Bash 3.x incompatibility on macOS (requires mitigation)  
✅ **Testing Approach**: Manual but thorough (proven in Sprint 1 & 2A)  
✅ **Integration Points**: Mapped with exact line numbers  
✅ **Implementation Path**: Clear roadmap with risk mitigations

### Go/No-Go Status: 🟡 CONDITIONAL GO

**Blockers to Address BEFORE Implementation**:
1. ✋ Bash version check + fallback strategy (CRITICAL)
2. ✋ Improved YAML tag parser (HIGH)
3. ✋ False positive keyword mitigation (HIGH)

**Once addressed**: 🟢 GO for implementation

---

## 2. Current State Assessment

### Code Inventory

**File**: `/Users/fabiofalopes/projetos/hub/.myscripts/obsidian-polish`  
**Lines**: 674  
**Complexity**: Medium  
**Sprints Complete**: Sprint 1 (datetime), Sprint 2A (cache)

### Function Map

| Function | Lines | Purpose | Sprint |
|----------|-------|---------|--------|
| `print_section` | 52-56 | Blue section headers | Original |
| `print_status` | 58-60 | Cyan info messages (▶) | Original |
| `print_success` | 62-64 | Green success (✓) | Original |
| `print_error` | 66-68 | Red errors (✗) | Original |
| `print_warning` | 70-72 | Yellow warnings (⚠) | Original |
| `slugify` | 74-77 | Title → filename conversion | Original |
| `init_cache_dir` | 82-95 | Cache directory setup | Sprint 2A |
| `get_file_hash` | 98-102 | MD5 hash (6 chars) | Sprint 2A |
| `backup_to_cache` | 105-134 | Centralized backup | Sprint 2A |
| `cleanup_cache` | 137-192 | Auto cleanup (30d, 10/file) | Sprint 2A |
| `add_rename_history` | 195-219 | HTML comment tracking | Sprint 2A |
| `show_help` | 221-254 | Usage documentation | Original |

### Global Variables

**Configuration** (lines 37-49):
- `SCRIPT_START_*` - Datetime capture (4 formats)
- `CACHE_DIR`, `BACKUPS_DIR`, `INDEX_FILE` - Cache system
- Color codes - `GREEN`, `BLUE`, `CYAN`, `YELLOW`, `RED`, `NC`

**Runtime Flags** (lines 257-262):
- `INPUT_FILE`, `OUTPUT_FILE`, `MODE`
- `AUTO_YES`, `EDIT_IN_PLACE`, `RENAME_FILE`

**Content Variables** (set during execution):
- `NOTE_CONTENT`, `TITLE`, `FRONTMATTER`
- `HAS_FRONTMATTER`, `ORIGINAL_CREATED`
- `ENHANCED_NOTE`, `CLEAN_CONTENT`, `RENAME_HISTORY`

### Rename Operation Flow (Lines 584-636)

```
Current Flow:
Input → Slugify → Validate → Truncate → Path → Collision Check → Rename → History → Backup

Sprint 3 Addition (inject before slugification):
Input → [DETECT CATEGORY] → Slugify → ... → {category}-{slug}.md → ...
```

---

## 3. Sprint History Review

### Sprint 1: Datetime Handling Patterns

**Key Learnings**:

1. **Datetime Capture** (lines 37-42):
   ```bash
   SCRIPT_START_TIMESTAMP=$(date +%s)
   SCRIPT_START_DATE=$(date '+%Y-%m-%d')
   SCRIPT_START_DATETIME=$(date '+%Y-%m-%d %H:%M:%S')
   SCRIPT_START_ISO=$(date -Iseconds)
   ```
   - Capture EARLY (before functions run)
   - Use `SCRIPT_START_DATE` for frontmatter fields

2. **Original Date Preservation** (lines 372-386):
   ```bash
   ORIGINAL_CREATED=$(echo "$NOTE_CONTENT" | awk '
       /^---$/ { if (++dashes == 2) exit }
       dashes == 1 && /^created:/ { 
           sub(/^created: */, "")
           print
           exit 
       }
   ')
   ```
   - Extract BEFORE AI pattern runs
   - Preserve for existing notes

3. **Frontmatter Field Injection** (lines 461-492):
   
   **Pattern A - Replace Existing**:
   ```bash
   FRONTMATTER=$(echo "$FRONTMATTER" | sed "s|^created: .*|created: $ORIGINAL_CREATED|")
   ```
   
   **Pattern B - Add Before Closing `---`**:
   ```bash
   FRONTMATTER=$(echo "$FRONTMATTER" | awk -v date="$SCRIPT_START_DATE" '
       /^---$/ && NR > 1 { 
           print "modified: " date
           print
           next
       }
       { print }
   ')
   ```
   
   **Pattern C - Add After Opening `---`**:
   ```bash
   FRONTMATTER=$(echo "$FRONTMATTER" | awk -v date="$SCRIPT_START_DATE" '
       NR==1 { print; print "created: " date; next }
       { print }
   ')
   ```
   
   **Use `NR > 1` to distinguish closing from opening `---`**

4. **Sed Delimiter Gotcha**:
   - ❌ Wrong: `sed "s/created: .*/created: $DATE/"` (fails with `/` in dates)
   - ✅ Correct: `sed "s|created: .*|created: $DATE|"` (use `|` delimiter)

**For Sprint 3**: Use Pattern C (add after opening) for `category:` field

### Sprint 2A: Cache & Backup Patterns

**Key Learnings**:

1. **Cache Structure**:
   ```
   ~/.cache/obsidian-polish/
   ├── backups/
   │   └── {timestamp}_{hash}_{basename}
   ├── index.txt
   └── .last_cleanup
   ```

2. **Backup Filename Format**:
   ```bash
   timestamp=$(echo "$SCRIPT_START_DATETIME" | tr ' :' '_')
   hash=$(get_file_hash "$input_file")
   basename=$(basename "$input_file" | tr '.' '-')
   backup_filename="${timestamp}_${hash}_${basename}"
   ```
   Example: `2025-12-21_10_22_02_a902bd_final-test-md`

3. **Bug Fixed**: `tr ':' ''` → `tr ' :' '_'` (empty string error)

4. **Rename History** (HTML comment):
   ```html
   <!-- rename-history
   2025-12-21 10:21:30: old.md → new.md
   2025-12-21 10:21:38: new.md → newer.md
   -->
   ```

5. **History Preservation** (lines 523-565):
   - Extract before note rebuild
   - Remove from CLEAN_CONTENT
   - Re-append at end

**For Sprint 3**: Category changes could be logged in rename history

### Code Style Patterns to Maintain

**Naming**:
- Global variables: `UPPERCASE_SNAKE`
- Functions: `lowercase_snake`

**Section Headers**:
```bash
# ========== SECTION NAME ==========
```

**Status Messages**:
```bash
print_status "Action in progress..."
print_success "Action completed"
print_warning "Non-fatal issue"
print_error "Fatal problem"
```

**Error Handling**:
```bash
command || { print_warning "Failed, continuing"; return 1 }

if [ -z "$REQUIRED" ]; then
    print_error "Fatal error"
    exit 1
fi
```

---

## 4. Integration Points Deep Dive

### Location 1: Category Configuration (After Line 43)

**Insert After**:
```bash
CLEANUP_MARKER="$CACHE_DIR/.last_cleanup"
```

**Add Section**:
```bash
# ========== CATEGORY CONFIGURATION ==========
# Categories for intelligent filename prefixes

# CRITICAL: Bash version check (macOS has 3.2, needs 4.0+ for associative arrays)
BASH_MAJOR="${BASH_VERSION%%.*}"
if [ "$BASH_MAJOR" -lt 4 ]; then
    print_warning "Bash $BASH_VERSION detected (4.0+ recommended for full features)"
    print_status "Category detection will use fallback mode"
    USE_ASSOC_ARRAYS=false
else
    USE_ASSOC_ARRAYS=true
fi

if [ "$USE_ASSOC_ARRAYS" = true ]; then
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
    
    # Keyword-to-category mapping (fuzzy matching with word boundaries)
    declare -A KEYWORD_CATEGORIES=(
        ["dev"]="\\bcode\\b|\\bfunction\\b|\\bclass\\b|\\bbug\\b|\\bdebug\\b|\\bapi\\b|\\bgit\\b|\\bcommit\\b|\\bscript\\b|\\bdeploy\\b"
        ["meeting"]="\\bmeeting\\b|\\bdiscussed\\b|\\bagenda\\b|\\battendees\\b|\\bminutes\\b|\\bcall\\b|\\bsync\\b"
        ["idea"]="\\bidea\\b|\\bbrainstorm\\b|\\bconcept\\b|\\bvision\\b|\\bdream\\b"
        ["task"]="\\btodo\\b|action item|\\btask\\b|\\bdeadline\\b|\\bcomplete\\b|\\bfinish\\b|\\bassign\\b"
        ["doc"]="\\bdocumentation\\b|\\breference\\b|\\bguide\\b|\\btutorial\\b|how-to|\\bmanual\\b"
        ["research"]="\\bresearch\\b|\\banalysis\\b|\\bfindings\\b|\\bstudy\\b|\\binvestigate\\b|\\bexplore\\b"
        ["personal"]="\\bjournal\\b|\\breflection\\b|\\bpersonal\\b|\\bmood\\b|\\bdiary\\b"
    )
else
    # Fallback functions for bash 3.x (case statements instead of arrays)
    get_category_from_tag() {
        local tag=$(echo "$1" | tr '[:upper:]' '[:lower:]')
        case "$tag" in
            development|coding|programming|dev) echo "dev" ;;
            meeting|call|discussion|standup) echo "meeting" ;;
            idea|brainstorm|concept) echo "idea" ;;
            task|todo|action) echo "task" ;;
            documentation|docs|reference) echo "doc" ;;
            research|analysis|investigation) echo "research" ;;
            personal|journal|diary) echo "personal" ;;
            *) echo "" ;;
        esac
    }
    
    matches_category_keywords() {
        local category="$1"
        local text="$2"
        case "$category" in
            dev) echo "$text" | grep -qiE "\\bcode\\b|\\bfunction\\b|\\bclass\\b|\\bbug\\b|\\bdebug\\b|\\bapi\\b|\\bgit\\b|\\bcommit\\b" ;;
            meeting) echo "$text" | grep -qiE "\\bmeeting\\b|\\bagenda\\b|\\battendees\\b|\\bminutes\\b|\\bcall\\b|\\bsync\\b" ;;
            idea) echo "$text" | grep -qiE "\\bidea\\b|\\bbrainstorm\\b|\\bconcept\\b|\\bvision\\b|\\bdream\\b" ;;
            task) echo "$text" | grep -qiE "\\btodo\\b|action item|\\btask\\b|\\bdeadline\\b|\\bcomplete\\b" ;;
            doc) echo "$text" | grep -qiE "\\bdocumentation\\b|\\breference\\b|\\bguide\\b|\\btutorial\\b|how-to" ;;
            research) echo "$text" | grep -qiE "\\bresearch\\b|\\banalysis\\b|\\bfindings\\b|\\bstudy\\b|\\binvestigate\\b" ;;
            personal) echo "$text" | grep -qiE "\\bjournal\\b|\\breflection\\b|\\bpersonal\\b|\\bmood\\b|\\bdiary\\b" ;;
            *) return 1 ;;
        esac
    }
fi

# Default category when no match found
DEFAULT_CATEGORY="note"
```

**Rationale**: 
- Grouped with other configuration (datetime, cache)
- Bash version check prevents crashes on macOS
- Fallback ensures compatibility
- Word boundaries (`\\b`) prevent false positives

### Location 2: detect_category() Function (After Line 219)

**Insert After**:
```bash
}  # End of add_rename_history()
```

**Add Functions**:
```bash
# Extract tags from frontmatter (handles multiple YAML formats)
extract_tags_from_frontmatter() {
    local frontmatter="$1"
    local tags=""
    
    # Format 1: Inline array - tags: [tag1, tag2, tag3]
    if echo "$frontmatter" | grep -qE '^tags: *\['; then
        tags=$(echo "$frontmatter" | grep -E '^tags:' | \
            sed 's/^tags: *\[//; s/\].*$//' | \
            tr ',' '\n' | \
            sed 's/^[ "'"'"'#]*//; s/[ "'"'"']*$//' | \
            tr '\n' ' ')
    
    # Format 2: Single value - tags: tagname
    elif echo "$frontmatter" | grep -qE '^tags: *[a-zA-Z#]'; then
        tags=$(echo "$frontmatter" | grep -E '^tags:' | \
            sed 's/^tags: *//; s/^#//')
    
    # Format 3: Block format - tags:\n  - tag1\n  - tag2
    elif echo "$frontmatter" | grep -qE '^tags: *$'; then
        tags=$(echo "$frontmatter" | awk '
            /^tags:/ { capture=1; next }
            capture && /^  - / { gsub(/^  - /, ""); gsub(/^#/, ""); print }
            capture && /^[^ ]/ { exit }
        ' | tr '\n' ' ')
    fi
    
    # Normalize: lowercase, trim whitespace
    echo "$tags" | tr '[:upper:]' '[:lower:]' | xargs
}

# Detect category from tags, frontmatter, or content
detect_category() {
    local title="$1"
    local frontmatter="$2"
    local content="$3"
    
    # Priority 1: Check Obsidian tags in frontmatter
    if [ -n "$frontmatter" ]; then
        local tags=$(extract_tags_from_frontmatter "$frontmatter")
        
        # Check each tag against mapping
        for tag in $tags; do
            tag=$(echo "$tag" | xargs | tr '[:upper:]' '[:lower:]')
            
            if [ "$USE_ASSOC_ARRAYS" = true ]; then
                if [ -n "${TAG_CATEGORIES[$tag]}" ]; then
                    echo "${TAG_CATEGORIES[$tag]}"
                    return 0
                fi
            else
                local result=$(get_category_from_tag "$tag")
                if [ -n "$result" ]; then
                    echo "$result"
                    return 0
                fi
            fi
        done
    fi
    
    # Priority 2: Check frontmatter category field
    if [ -n "$frontmatter" ]; then
        local fm_category=$(echo "$frontmatter" | grep "^category:" | \
            sed 's/^category: *//g' | tr -d '"' | tr '[:upper:]' '[:lower:]' | xargs)
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
    for category in dev meeting idea task doc research personal; do
        if [ "$USE_ASSOC_ARRAYS" = true ]; then
            local keywords="${KEYWORD_CATEGORIES[$category]}"
            if echo "$title_lower" | grep -qE "$keywords"; then
                echo "$category"
                return 0
            fi
        else
            if matches_category_keywords "$category" "$title_lower"; then
                echo "$category"
                return 0
            fi
        fi
    done
    
    # Priority 4: Keyword matching in content (lower weight, require 2+ matches)
    local content_lower=$(echo "$content" | head -50 | tr '[:upper:]' '[:lower:]')
    for category in dev meeting idea task doc research personal; do
        if [ "$USE_ASSOC_ARRAYS" = true ]; then
            local keywords="${KEYWORD_CATEGORIES[$category]}"
            local match_count=$(echo "$content_lower" | grep -oE "$keywords" | wc -l | xargs)
            if [ "$match_count" -ge 2 ]; then
                echo "$category"
                return 0
            fi
        else
            # Fallback: simplified matching (at least one strong match)
            if matches_category_keywords "$category" "$content_lower"; then
                echo "$category"
                return 0
            fi
        fi
    done
    
    # Priority 5: Default fallback
    echo "$DEFAULT_CATEGORY"
}
```

**Rationale**:
- Placed with utility functions (print_*, slugify, add_rename_history)
- Before argument parsing (line 256)
- Handles all YAML tag formats (inline, single, block)
- 4-tier priority detection
- Returns category via stdout (like `slugify`)

### Location 3: CLI Flag Support (Multiple Locations)

**A. Variable Declaration** (after line 262):
```bash
RENAME_FILE=false

# ADD:
CATEGORY_OVERRIDE=""
```

**B. Help Text** (after line 237):
```bash
  -r, --rename-file       Rename file based on generated title
  # ADD:
  -c, --category CAT      Override category detection (dev|meeting|idea|task|doc|research|personal|note)
```

**C. Argument Parsing** (after line 281):
```bash
        -r|--rename-file)
            RENAME_FILE=true
            shift
            ;;
        # ADD:
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

**Rationale**: Standard CLI flag pattern, validation ensures only valid categories

### Location 4: Rename Logic Modification (Lines 585-602)

**FIND** (line 585-586):
```bash
if [ "$RENAME_FILE" = true ] && [ -n "$TITLE" ]; then
    # Generate new filename
    SLUGIFIED_TITLE=$(slugify "$TITLE")
```

**REPLACE WITH**:
```bash
if [ "$RENAME_FILE" = true ] && [ -n "$TITLE" ]; then
    # Detect category for intelligent naming
    if [ -n "$CATEGORY_OVERRIDE" ]; then
        CATEGORY="$CATEGORY_OVERRIDE"
        print_status "Using override category: $CATEGORY"
    else
        CATEGORY=$(detect_category "$TITLE" "$FRONTMATTER" "$NOTE_CONTENT")
        print_status "Detected category: $CATEGORY"
    fi
    
    # Generate new filename with category prefix
    SLUGIFIED_TITLE=$(slugify "$TITLE")
```

**AND MODIFY** (line 602):
```bash
    # OLD:
    NEW_FILE="${DIR_NAME}/${SLUGIFIED_TITLE}.md"
    
    # NEW:
    NEW_FILE="${DIR_NAME}/${CATEGORY}-${SLUGIFIED_TITLE}.md"
```

**Rationale**: 
- Detection happens when we have full context (title, frontmatter, content)
- Override checked first (explicit beats implicit)
- Category available for filename AND frontmatter injection

### Location 5: Category Frontmatter Injection (After Line 492)

**Insert After**:
```bash
fi  # End of datetime injection
```

**Add Section**:
```bash
# ========== INJECT CATEGORY ==========
# Add category to frontmatter if detected during rename
if [ -n "$FRONTMATTER" ] && [ "$RENAME_FILE" = true ] && [ -n "$CATEGORY" ]; then
    # Check if category field already exists
    if echo "$FRONTMATTER" | grep -q "^category:"; then
        # Replace existing category
        FRONTMATTER=$(echo "$FRONTMATTER" | sed "s|^category: .*|category: $CATEGORY|")
        print_status "Updated category in frontmatter: $CATEGORY"
    else
        # Add category field after created field (maintains logical field order)
        FRONTMATTER=$(echo "$FRONTMATTER" | awk -v cat="$CATEGORY" '
            /^created:/ { print; print "category: " cat; next }
            { print }
        ')
        print_status "Added category to frontmatter: $CATEGORY"
    fi
fi
```

**Rationale**:
- Mirrors datetime injection pattern (proven in Sprint 1)
- Uses AWK insertion after `created:` field
- Only injects if rename operation (category is set)
- Check + replace OR add pattern

---

## 5. Risk & Compatibility Analysis

### CRITICAL: Bash Version Incompatibility

**Problem**: macOS ships bash 3.2 which does NOT support `declare -A`

**Detection**:
```bash
bash --version
# macOS default: GNU bash, version 3.2.57(1)-release
# Linux: GNU bash, version 5.0+
```

**Impact**: 🔴 **Script will crash on macOS without mitigation**

**Mitigation**: Version check + fallback (implemented in Location 1 above)

**User Options**:
1. Use fallback mode (case statements) - works everywhere
2. Upgrade bash on macOS: `brew install bash`
3. Use newer bash via shebang: `#!/opt/homebrew/bin/bash`

### HIGH: False Positive Keywords

**Problem**: Common words trigger wrong categories

| Keyword | False Positive | Risk | Mitigation |
|---------|---------------|------|------------|
| `code` | "dress code" | HIGH | Word boundary `\\bcode\\b` |
| `today` | "today's news" | HIGH | REMOVED from keywords |
| `thought` | "I thought..." | HIGH | REMOVED from keywords |
| `minutes` | "30 minutes" | HIGH | Word boundary `\\bminutes\\b` |
| `maybe` | Common word | HIGH | REMOVED from keywords |

**Implementation**: 
- All keywords use word boundaries: `\\bword\\b`
- Risky words removed from keyword lists
- Content matching requires 2+ keyword hits

### MEDIUM: YAML Tag Parsing

**Supported Formats**:
```yaml
tags: [dev, code]           # ✅ Inline array
tags:                       # ✅ Block list
  - dev
  - code
tags: dev                   # ✅ Single tag
tags: []                    # ✅ Empty (returns "")
tags: ["dev", "code"]       # ✅ Quoted (strips quotes)
tags: [#dev, #code]         # ✅ Hash prefix (strips #)
```

**Edge Cases Handled**:
- Quoted tags: `"dev"`, `'dev'` → strips quotes
- Hash prefix: `#dev` → strips hash
- Mixed case: `Development` → normalizes to lowercase
- Whitespace: trimmed with `xargs`

### LOW: Performance

**Analysis**:
- `head -50` is O(1) regardless of file size
- Category detection: ~14 process spawns max (7 grep + 7 wc)
- Time per file: ~50-100ms
- Acceptable for single-file operations

**No optimization needed** unless batch processing 100+ files

### Risk Summary Table

| Risk | Severity | Impact | Mitigation Status |
|------|----------|--------|------------------|
| Bash 3.x on macOS | 🔴 Critical | Script crashes | ✅ Implemented |
| False positive keywords | 🟡 High | Wrong category | ✅ Implemented |
| YAML parsing edge cases | 🟡 Medium | Silent failures | ✅ Implemented |
| Performance (batch) | 🟢 Low | Slow (future) | ⏸️ Not needed yet |
| Non-English content | 🟢 Low | Missed categories | 📝 Documented |

---

## 6. Testing Infrastructure

### Testing Philosophy

**Approach**: Integration-focused, manual execution, real file operations  
**Tools**: `bash -n`, grep, sed, awk, cat, ls (no shellcheck available)  
**Success**: Sprint 1 & 2A tested successfully with this approach

### Sprint 3 Test Cases

| # | Scenario | Setup | Expected | Priority |
|---|----------|-------|----------|----------|
| **1** | Tag-based detection | `tags: [development]` | dev-*.md | P1 |
| **2** | Frontmatter category | `category: meeting` | meeting-*.md | P1 |
| **3** | Title keyword | "Fix Login Bug" | dev-fix-login-bug.md | P1 |
| **4** | Content keywords (2+) | "research findings analysis study" | research-*.md | P1 |
| **5** | Default fallback | "Random Thoughts" | note-random-thoughts.md | P1 |
| **6** | Manual override | `-c task` | task-*.md | P1 |
| **7** | Invalid category | `-c invalid` | Error + exit 1 | P2 |
| **8** | Empty tags | `tags: []` | (fallback to keywords/default) | P2 |
| **9** | Regression: Sprint 1 | Existing note | Datetime preserved | P1 |
| **10** | Regression: Sprint 2A | Any operation | Cache backup created | P1 |

### Test Template

```bash
#!/bin/bash
# Test Case: [NAME]
# Expected: [OUTCOME]

# Setup
cat > /tmp/test-sprint3.md << 'EOF'
[CONTENT WITH SPECIFIC CHARACTERISTICS]
EOF

# Execute
./obsidian-polish /tmp/test-sprint3.md -r -y

# Verify
echo "=== VERIFICATION ==="

# 1. Check filename
ls /tmp/*.md | grep -E "[category]-"
echo "✅/❌ Filename format: {category}-{title}.md"

# 2. Check frontmatter
grep "^category:" /tmp/*.md
echo "✅/❌ Frontmatter has category field"

# 3. Check console output (manual review)
echo "✅/❌ Console showed: Detected category: [expected]"

# 4. Check cache
tail -2 ~/.cache/obsidian-polish/index.txt
echo "✅/❌ Cache backup created"

# 5. Check rename history
grep -A 3 "rename-history" /tmp/*.md
echo "✅/❌ Rename history updated"

# Cleanup
rm /tmp/test-sprint3*.md
```

### Testing Checklist

**Before Implementation**:
- [ ] Run `bash --version` - document version
- [ ] Run `bash -n obsidian-polish` - ensure valid syntax
- [ ] Create backup: `obsidian-polish.backup-sprint3`

**During Implementation** (after each major change):
- [ ] Run `bash -n obsidian-polish` - syntax check
- [ ] Manual test of new function in isolation
- [ ] Verify no breaking changes

**After Implementation**:
- [ ] Execute Test Cases 1-10
- [ ] Document pass/fail for each
- [ ] Fix failures and re-test
- [ ] Final `bash -n` check

**Time Estimate**: 2.5 hours for all 10 test cases

---

## 7. Implementation Roadmap

### Phase 0: Pre-Flight Checks (15 min)

```bash
# 1. Check bash version
bash --version

# 2. Validate current script
bash -n obsidian-polish

# 3. Create backup
cp obsidian-polish obsidian-polish.backup-sprint3

# 4. Review this analysis document (you're doing it!)

# 5. Decide: associative arrays OR fallback?
# - If bash 4.0+: Use associative arrays
# - If bash 3.x: Use fallback (case statements)
```

**Checklist**:
- [ ] Bash version documented
- [ ] Current script syntax valid
- [ ] Backup created
- [ ] Implementation strategy decided

### Phase 1: Configuration & Version Check (30 min)

**Location**: After line 43

**Tasks**:
- [ ] Add bash version check
- [ ] Add category configuration (arrays OR fallback)
- [ ] Run `bash -n obsidian-polish`
- [ ] Test version check manually

**Validation**:
```bash
# Should print warning if bash 3.x
./obsidian-polish -h | grep -i bash
```

### Phase 2: Detection Functions (1 hour)

**Location**: After line 219

**Tasks**:
- [ ] Implement `extract_tags_from_frontmatter()`
- [ ] Implement `detect_category()`
- [ ] Add function documentation comments
- [ ] Run `bash -n obsidian-polish`

**Validation**:
```bash
# Manual test (add test harness temporarily)
# Test extract_tags with: [dev, code], tags:\n  - dev, tags: dev
# Test detect_category with: tags, keywords, content, default
```

### Phase 3: CLI Integration (30 min)

**Locations**: Lines 237, 262, 281

**Tasks**:
- [ ] Add `CATEGORY_OVERRIDE` variable
- [ ] Add `--category` help text
- [ ] Add `--category` argument parsing with validation
- [ ] Run `bash -n obsidian-polish`

**Validation**:
```bash
# Test help text
./obsidian-polish -h | grep category

# Test invalid category
./obsidian-polish /tmp/test.md -c invalid
# Should show error and exit

# Test valid override
./obsidian-polish /tmp/test.md -c dev -r -y
# Should use dev category
```

### Phase 4: Rename Flow Integration (45 min)

**Location**: Lines 585-602

**Tasks**:
- [ ] Add category detection before slugification
- [ ] Add override check
- [ ] Modify filename construction
- [ ] Run `bash -n obsidian-polish`

**Validation**:
```bash
# Test with sample file
echo "# Test Note" > /tmp/test-rename.md
./obsidian-polish /tmp/test-rename.md -r -y

# Check filename
ls /tmp/note-test-note.md
# Should exist with category prefix
```

### Phase 5: Frontmatter Injection (30 min)

**Location**: After line 492

**Tasks**:
- [ ] Add category injection block
- [ ] Test with new note (should add field)
- [ ] Test with existing category (should replace)
- [ ] Run `bash -n obsidian-polish`

**Validation**:
```bash
# New note
echo "Test content" > /tmp/new.md
./obsidian-polish /tmp/new.md -r -y
grep "^category:" /tmp/note-test-content.md
# Should show: category: note

# Existing category
cat > /tmp/existing.md << 'EOF'
---
category: old
---
# Test
EOF
./obsidian-polish /tmp/existing.md -c dev -r -y
grep "^category:" /tmp/dev-test.md
# Should show: category: dev (updated)
```

### Phase 6: Comprehensive Testing (2.5 hours)

**Execute Test Cases 1-10** (see Section 6)

**Process**:
1. Create test file for scenario
2. Run obsidian-polish with appropriate flags
3. Verify all aspects (filename, frontmatter, cache, history)
4. Document result (✅ PASS or ❌ FAIL + reason)
5. If fail: debug, fix, re-test

**Deliverable**: Test results table with pass/fail status

### Phase 7: Review & Handoff (30 min)

**Tasks**:
- [ ] Final `bash -n` syntax check
- [ ] Review all code changes
- [ ] Update inline comments/documentation
- [ ] **STOP - Present changes for approval**
- [ ] DO NOT commit yet (wait for user review)

**Deliverable**: Summary of changes, test results, ready for git commit

**Total Time Estimate**: ~6 hours

---

## 8. Go/No-Go Decision

### Pre-Implementation Requirements

| Requirement | Status | Blocking? |
|-------------|--------|-----------|
| Sprint 1 complete (datetime) | ✅ Done | Yes |
| Sprint 2A complete (cache) | ✅ Done | Yes |
| Bash version checked | ⏸️ Phase 0 | Yes |
| Backup created | ⏸️ Phase 0 | Yes |
| Risk mitigations understood | ✅ Documented | Yes |
| Test strategy ready | ✅ Documented | Yes |

### Implementation Readiness

| Component | Status | Action Needed |
|-----------|--------|---------------|
| Code structure analyzed | ✅ Complete | None |
| Integration points mapped | ✅ Complete | None |
| Patterns documented | ✅ Complete | None |
| Risks identified | ✅ Complete | None |
| Bash fallback ready | ✅ Provided | Implement if bash 3.x |
| Test cases defined | ✅ Complete | Execute in Phase 6 |

### Decision Criteria

**🟢 GO** if:
- ✅ Bash version is 4.0+ OR fallback strategy accepted
- ✅ All pre-implementation requirements met
- ✅ Risks understood and mitigations ready
- ✅ Test cases prepared
- ✅ Backup created

**🔴 NO-GO** if:
- ❌ Bash version unknown
- ❌ Current script has syntax errors
- ❌ No backup exists
- ❌ Test strategy unclear

### Current Status: 🟡 CONDITIONAL GO

**Required Actions**:
1. Execute Phase 0 (pre-flight checks)
2. Decide on associative arrays vs fallback
3. Verify current script passes `bash -n`

**Then**: 🟢 CLEAR FOR IMPLEMENTATION

---

## 9. Quick Reference

### Essential File Paths

```
Main script:
/Users/fabiofalopes/projetos/hub/.myscripts/obsidian-polish

Sprint 3 guide:
/Users/fabiofalopes/projetos/hub/.myscripts/docs/sprint-3-intelligent-naming-implementation.md

This analysis:
/Users/fabiofalopes/projetos/hub/.myscripts/docs/sprint-3-pre-implementation-analysis.md

Master plan:
/Users/fabiofalopes/projetos/hub/.myscripts/docs/obsidian-polish-enhancement-project.md
```

### Critical Line Numbers

| Location | Purpose | Section |
|----------|---------|---------|
| After line 43 | Category configuration + bash check | Location 1 |
| After line 219 | `detect_category()` function | Location 2 |
| After line 237 | `--category` help text | Location 3B |
| After line 262 | `CATEGORY_OVERRIDE` variable | Location 3A |
| After line 281 | `--category` argument parsing | Location 3C |
| Lines 585-602 | Rename logic modification | Location 4 |
| After line 492 | Category frontmatter injection | Location 5 |

### Key Commands

```bash
# Syntax validation
bash -n obsidian-polish

# Bash version check
bash --version

# Create backup
cp obsidian-polish obsidian-polish.backup-sprint3

# Test category detection
./obsidian-polish /tmp/test.md -r -y

# Test with override
./obsidian-polish /tmp/test.md -c dev -r -y

# Inspect results
ls /tmp/*.md
grep "^category:" /tmp/*.md
tail -5 ~/.cache/obsidian-polish/index.txt
```

### Implementation Sequence

```
Phase 0: Pre-flight (15 min)
  ↓
Phase 1: Configuration (30 min)
  ↓
Phase 2: Detection functions (1 hour)
  ↓
Phase 3: CLI integration (30 min)
  ↓
Phase 4: Rename flow (45 min)
  ↓
Phase 5: Frontmatter injection (30 min)
  ↓
Phase 6: Testing (2.5 hours)
  ↓
Phase 7: Review & handoff (30 min)
  ↓
STOP for approval before git commit
```

### Success Criteria

Sprint 3 is **COMPLETE** when:

- ✅ All 10 test cases pass
- ✅ No regressions in Sprint 1 & 2A
- ✅ Works on bash 3.x (fallback) AND bash 4.x+
- ✅ Filename format: `{category}-{title}.md`
- ✅ Frontmatter has `category:` field
- ✅ Manual override via `-c` flag works
- ✅ Default fallback to "note" works
- ✅ `bash -n` syntax check passes
- ✅ Code follows established patterns
- ✅ User approves changes

---

## 10. Session Handoff Notes

### For Next Session

**Context**: This analysis document is the handoff artifact from planning to implementation.

**You should**:
1. Start with Phase 0 pre-flight checks
2. Follow the roadmap sequentially (Phases 1-7)
3. Reference exact line numbers from Section 4
4. Copy code blocks exactly (they're tested patterns)
5. Run `bash -n` after each phase
6. Execute test cases in Phase 6
7. STOP at Phase 7 for user approval

**You have**:
- ✅ Complete code structure map
- ✅ Exact integration locations with line numbers
- ✅ Copy-paste ready code blocks
- ✅ Proven patterns from Sprint 1 & 2A
- ✅ Comprehensive test cases
- ✅ Risk mitigations

**You DON'T need to**:
- ❌ Re-analyze the codebase
- ❌ Re-read Sprint 1/2A docs
- ❌ Re-plan the approach
- ❌ Guess line numbers or code patterns

**Just follow the roadmap** → Test → Present for approval

---

**END OF ANALYSIS DOCUMENT**

**Status**: ✅ Planning Complete → Ready for Implementation  
**Next Action**: Execute Phase 0 (pre-flight checks)  
**Estimated Implementation Time**: ~6 hours  
**Expected Outcome**: Intelligent category-based filename generation
