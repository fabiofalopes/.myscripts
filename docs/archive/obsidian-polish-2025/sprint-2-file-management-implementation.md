# Sprint 2: File Management Implementation

**Duration**: 2 days  
**Complexity**: MEDIUM  
**Risk**: MEDIUM  
**Dependencies**: Sprint 1 (datetime handling)

---

## Sprint Goal

Implement centralized cache-based backup system and HTML comment-based rename history tracking to replace `.bak` file clutter.

---

## Pre-Implementation Checklist

- [ ] Sprint 1 completed (datetime variables available)
- [ ] Read master plan: `obsidian-polish-enhancement-project.md`
- [ ] Backup current script: `cp obsidian-polish obsidian-polish.backup-sprint2`
- [ ] Current script at: `/Users/fabiofalopes/projetos/hub/.myscripts/obsidian-polish`

---

## Current State Analysis

**Problem**: Script currently creates `.bak` files in same directory as input files:
- Line 82: Help text mentions `--no-backup` flag
- Lines 126-129: Parse `--no-backup` flag
- Lines 344-349: Create `.bak` file with `cp "$INPUT_FILE" "${INPUT_FILE}.bak"`
- Lines 351-391: Handle rename operation (no history tracking)

**What we're building**:
1. **Cache system** at `~/.cache/obsidian-polish/` for backups
2. **HTML comment history** embedded in renamed files
3. **Automatic cleanup** of old backups (30 days, 10 per file)

---

## Architecture Overview

### Cache Directory Structure

```
~/.cache/obsidian-polish/
├── backups/
│   ├── 2025-12-21_153022_a4f8e2_note-md.md
│   ├── 2025-12-21_153055_7c3d2e_draft-md.md
│   └── 2025-12-21_154211_b9f1a3_meeting-notes-md.md
├── index.txt
└── .last_cleanup
```

**Backup filename format**:
```
{YYYY-MM-DD_HHMMSS}_{hash}_{original-basename}.md
```

- `timestamp`: Sortable, human-readable (`$SCRIPT_START_DATETIME`)
- `hash`: First 6 chars of MD5 of full path (prevents collisions)
- `basename`: Original filename with `.` → `-`

**Index file format** (pipe-delimited):
```
# timestamp|source_file|backup_file|operation|new_file
2025-12-21T15:30:22|/Users/fabio/notes/note.md|2025-12-21_153022_a4f8e2_note-md.md|edit|
2025-12-21T15:30:55|/Users/fabio/notes/draft.md|2025-12-21_153055_7c3d2e_draft-md.md|rename|/Users/fabio/notes/better-title.md
```

### HTML Comment History Format

When a file is renamed, append to end of file:
```markdown
Content of note here...

<!-- rename-history
2025-12-21 15:30:55: note.md → better-title.md
2025-12-22 09:14:33: better-title.md → final-name.md
-->
```

---

## Implementation Steps

### Step 1: Add Cache Configuration (10 min)

**Location**: After line 35 (after datetime variables from Sprint 1)

**Add these lines**:

```bash
# ========== CACHE CONFIGURATION ==========
# Central backup cache to avoid .bak file clutter
CACHE_DIR="${OBSIDIAN_POLISH_CACHE:-$HOME/.cache/obsidian-polish}"
BACKUPS_DIR="$CACHE_DIR/backups"
INDEX_FILE="$CACHE_DIR/index.txt"
CLEANUP_MARKER="$CACHE_DIR/.last_cleanup"
```

**Why configurable**: Users can override with env var for custom locations.

---

### Step 2: Implement Cache Functions (1 hour)

**Location**: After line 63 (after `slugify()` function)

**Add these functions**:

```bash
# ========== CACHE MANAGEMENT FUNCTIONS ==========

# Initialize cache directory structure
init_cache_dir() {
    if [ ! -d "$BACKUPS_DIR" ]; then
        mkdir -p "$BACKUPS_DIR"
        print_status "Created cache directory: $CACHE_DIR"
    fi
    
    if [ ! -f "$INDEX_FILE" ]; then
        cat > "$INDEX_FILE" << 'EOF'
# Obsidian Polish Backup Index
# Format: timestamp|source_file|backup_file|operation|new_file
EOF
        print_status "Initialized cache index"
    fi
}

# Generate short hash for file path uniqueness
get_file_hash() {
    local filepath="$1"
    local abs_path=$(realpath "$filepath" 2>/dev/null || echo "$filepath")
    echo "$abs_path" | md5sum | cut -c1-6
}

# Backup file to central cache
backup_to_cache() {
    local input_file="$1"
    local operation="${2:-edit}"
    local new_file="${3:-}"  # Optional: for rename operations
    
    # Initialize cache if needed
    init_cache_dir
    
    # Generate backup filename
    local timestamp=$(echo "$SCRIPT_START_DATETIME" | tr ' ' '_' | tr ':' '')
    local hash=$(get_file_hash "$input_file")
    local basename=$(basename "$input_file" | tr '.' '-')
    local backup_filename="${timestamp}_${hash}_${basename}"
    local backup_path="$BACKUPS_DIR/$backup_filename"
    
    # Copy file to cache
    cp "$input_file" "$backup_path" 2>/dev/null || {
        print_warning "Backup failed, continuing anyway"
        return 1
    }
    
    # Append to index
    local abs_source=$(realpath "$input_file" 2>/dev/null || echo "$input_file")
    echo "${SCRIPT_START_ISO}|${abs_source}|${backup_filename}|${operation}|${new_file}" >> "$INDEX_FILE"
    
    # Trigger cleanup check (async, non-blocking)
    cleanup_cache &
    
    echo "$backup_path"
}

# Clean up old backups
cleanup_cache() {
    # Check if cleanup needed
    local file_count=$(find "$BACKUPS_DIR" -type f 2>/dev/null | wc -l)
    local last_cleanup=0
    
    if [ -f "$CLEANUP_MARKER" ]; then
        # macOS and Linux compatible stat
        last_cleanup=$(stat -c %Y "$CLEANUP_MARKER" 2>/dev/null || stat -f %m "$CLEANUP_MARKER" 2>/dev/null || echo 0)
    fi
    
    local now=$(date +%s)
    local age=$((now - last_cleanup))
    
    # Only cleanup if >100 files or >24h since last cleanup
    if [ "$file_count" -lt 100 ] && [ "$age" -lt 86400 ]; then
        return 0
    fi
    
    print_status "Running cache cleanup (background)..."
    
    # Remove files older than 30 days
    find "$BACKUPS_DIR" -type f -mtime +30 -delete 2>/dev/null
    
    # Per-file limit: keep last 10 backups per source file
    if [ -f "$INDEX_FILE" ]; then
        # Create temp file with entries to keep
        local temp_index=$(mktemp)
        
        # Copy header
        grep "^#" "$INDEX_FILE" > "$temp_index"
        
        # Process entries: sort by source file, then timestamp descending
        # Keep newest 10 per source file, delete older backups
        grep -v "^#" "$INDEX_FILE" | sort -t'|' -k2,2 -k1,1r | \
        awk -F'|' -v backups_dir="$BACKUPS_DIR" '
        {
            source = $2
            backup_file = $3
            count[source]++
            
            if (count[source] <= 10) {
                # Keep this entry
                print $0
            } else {
                # Delete the backup file
                system("rm -f \"" backups_dir "/" backup_file "\" 2>/dev/null")
            }
        }
        ' >> "$temp_index"
        
        mv "$temp_index" "$INDEX_FILE"
    fi
    
    # Update cleanup marker
    touch "$CLEANUP_MARKER"
}
```

**Testing Step 2**:
```bash
# Source the script functions
source obsidian-polish

# Test cache initialization
init_cache_dir
ls -la ~/.cache/obsidian-polish/

# Test hash generation
get_file_hash "/tmp/test.md"

# Test backup
echo "test" > /tmp/test-backup.md
backup_to_cache "/tmp/test-backup.md" "edit"
ls -la ~/.cache/obsidian-polish/backups/
cat ~/.cache/obsidian-polish/index.txt
```

---

### Step 3: Implement Rename History Function (30 min)

**Location**: After cache functions (still after line 63 area)

**Add this function**:

```bash
# Add rename history to file as HTML comment
add_rename_history() {
    local file="$1"
    local old_name="$2"
    local new_name="$3"
    
    # Create history entry
    local history_entry="${SCRIPT_START_DATETIME}: $(basename "$old_name") → $(basename "$new_name")"
    
    # Check if file already has rename history
    if grep -q "<!-- rename-history" "$file" 2>/dev/null; then
        # Append to existing history (before closing -->)
        sed -i.tmp "s|-->|${history_entry}\n-->|" "$file"
        rm -f "${file}.tmp"
        print_status "Updated rename history"
    else
        # Add new history section
        cat >> "$file" << EOF

<!-- rename-history
${history_entry}
-->
EOF
        print_status "Added rename history"
    fi
}
```

**Why HTML comments**: 
- Invisible in Obsidian rendered view
- Preserved during exports
- Easy to parse programmatically
- Standard markdown feature

**Testing Step 3**:
```bash
echo "Test note content" > /tmp/test-rename.md
add_rename_history "/tmp/test-rename.md" "old-name.md" "new-name.md"
cat /tmp/test-rename.md

# Should show:
# Test note content
#
# <!-- rename-history
# 2025-12-21 15:30:55: old-name.md → new-name.md
# -->
```

---

### Step 4: Replace .bak Creation with Cache (30 min)

**Location**: Lines 344-349 (backup creation)

**FIND this code**:
```bash
# Create backup if requested
if [ "$NO_BACKUP" = false ]; then
    BACKUP_FILE="${INPUT_FILE}.bak"
    cp "$INPUT_FILE" "$BACKUP_FILE"
    print_success "Backup created: $BACKUP_FILE"
fi
```

**REPLACE with**:
```bash
# Create backup in cache (always, for safety)
BACKUP_PATH=$(backup_to_cache "$INPUT_FILE" "edit")
if [ -n "$BACKUP_PATH" ]; then
    print_success "Backup saved: $(basename "$BACKUP_PATH")"
    print_status "Cache location: $CACHE_DIR"
else
    print_warning "Backup creation failed, but continuing"
fi
```

**Why remove NO_BACKUP**:
- Backups now in cache (no clutter) → no reason to skip
- Safety-first approach
- Automatic cleanup handles size concerns

---

### Step 5: Remove --no-backup Flag (15 min)

**Changes needed**:

**1. Remove from help text (line 82)**:
```bash
# DELETE this line:
  -n, --no-backup        Skip backup creation
```

**2. Remove from argument parsing (lines 126-129)**:
```bash
# DELETE this case block:
-n|--no-backup)
    NO_BACKUP=true
    shift
    ;;
```

**3. Remove from variable defaults (around line 110)**:
```bash
# DELETE this line:
NO_BACKUP=false
```

---

### Step 6: Integrate Rename History (30 min)

**Location**: Lines 351-391 (rename operation)

**FIND the rename section** (around line 360):
```bash
if [ "$RENAME_FILE" = true ] && [ -n "$TITLE" ]; then
    # Generate new filename
    SLUGIFIED_TITLE=$(slugify "$TITLE")
    DIR=$(dirname "$INPUT_FILE")
    NEW_FILE="${DIR}/${SLUGIFIED_TITLE}.md"
    
    # ... confirmation logic ...
    
    # Perform rename
    mv "$INPUT_FILE" "$NEW_FILE"
    print_success "Renamed: $(basename "$INPUT_FILE") → $(basename "$NEW_FILE")"
fi
```

**ADD after the `mv` command**:

```bash
# Perform rename
mv "$INPUT_FILE" "$NEW_FILE"
print_success "Renamed: $(basename "$INPUT_FILE") → $(basename "$NEW_FILE")"

# Add rename history to the file
add_rename_history "$NEW_FILE" "$INPUT_FILE" "$NEW_FILE"

# Record rename in cache index
backup_to_cache "$NEW_FILE" "rename" "$NEW_FILE"
```

**Why backup after rename**:
- Cache tracks the rename operation
- Index shows old → new mapping
- Allows recovery if rename was mistake

---

### Step 7: Testing (2 hours)

**Test Case 1: Cache Creation**
```bash
# Remove cache if exists
rm -rf ~/.cache/obsidian-polish

# Run script
echo "Test note" > /tmp/test-cache.md
./obsidian-polish /tmp/test-cache.md

# Verify:
# 1. ~/.cache/obsidian-polish/backups/ exists
# 2. Backup file created with correct naming format
# 3. index.txt has entry
# 4. No .bak file in /tmp/
```

**Test Case 2: Rename with History**
```bash
cat > /tmp/rename-test.md << 'EOF'
This is a note about shell scripting and automation workflows.
EOF

./obsidian-polish /tmp/rename-test.md -r -y

# Verify:
# 1. File renamed (e.g., to shell-scripting-automation-workflows.md)
# 2. Renamed file contains HTML comment with history
# 3. Cache index shows rename operation
# 4. Backup exists in cache
```

**Test Case 3: Multiple Renames (History Accumulation)**
```bash
# Create note
echo "Kubernetes deployment strategies" > /tmp/multi-rename.md

# First rename
./obsidian-polish /tmp/multi-rename.md -r -y
FIRST_NAME=$(ls /tmp/kubernetes-*.md)

# Edit and rename again
echo "Kubernetes deployment strategies and best practices" > "$FIRST_NAME"
./obsidian-polish "$FIRST_NAME" -r -y

# Verify:
# 1. HTML comment has 2 rename entries
# 2. History shows chain: original → first → second
```

**Test Case 4: Cleanup Trigger**
```bash
# Create 101 backup files to trigger cleanup
for i in {1..101}; do
    echo "Test $i" > /tmp/test-$i.md
    ./obsidian-polish /tmp/test-$i.md
done

# Wait for background cleanup
sleep 2

# Verify cleanup ran (check .last_cleanup timestamp)
stat ~/.cache/obsidian-polish/.last_cleanup
```

**Test Case 5: Old File Cleanup**
```bash
# Create old backup files (simulate 31+ days old)
touch -t 202411010000 ~/.cache/obsidian-polish/backups/old-backup.md

# Trigger cleanup
./obsidian-polish /tmp/trigger-cleanup.md

# Verify old file deleted
ls ~/.cache/obsidian-polish/backups/ | grep old-backup
# Should return nothing
```

---

## Sprint Completion Checklist

- [ ] Cache configuration variables added
- [ ] Cache functions implemented (`init_cache_dir`, `get_file_hash`, `backup_to_cache`, `cleanup_cache`)
- [ ] Rename history function implemented (`add_rename_history`)
- [ ] `.bak` creation replaced with cache backup
- [ ] `--no-backup` flag removed from help, parsing, and defaults
- [ ] Rename history integrated into rename operation
- [ ] Test Case 1 passes (cache creation)
- [ ] Test Case 2 passes (rename with history)
- [ ] Test Case 3 passes (multiple renames)
- [ ] Test Case 4 passes (cleanup trigger)
- [ ] Test Case 5 passes (old file cleanup)
- [ ] No existing functionality broken
- [ ] Git commit created

---

## Commit Message

```bash
git add obsidian-polish
git commit -m "feat(cache): implement centralized backup and rename history

- Replace .bak files with centralized cache at ~/.cache/obsidian-polish/
- Add backup_to_cache() function with collision-safe naming
- Implement automatic cleanup (30 days, 10 backups per file)
- Track backups in index.txt with timestamp/source/operation
- Add HTML comment-based rename history in files
- Remove --no-backup flag (always backup, no clutter)
- Integrate rename tracking in cache index

Benefits:
- No more .bak file clutter in user directories
- Automatic cleanup prevents cache bloat
- Rename history embedded in files (portable)
- Cache tracks full backup/rename lineage

Closes Sprint 2 of obsidian-polish enhancement project"
```

---

## Handoff to Next Sprint

**What was completed**:
✅ Cache directory structure at `~/.cache/obsidian-polish/`  
✅ Backup files use collision-safe naming  
✅ Index tracks all backup operations  
✅ Automatic cleanup (30 days, 10 per file)  
✅ HTML comment rename history in files  
✅ `.bak` files eliminated  

**What's available for next sprints**:
- `backup_to_cache()` - Can be called with "edit" or "rename" operation
- `add_rename_history()` - Can be enhanced for category tracking
- `$CACHE_DIR` - Available for future features
- Rename history format - Can be extended with metadata

**Ready for**: Sprint 3 (Intelligent Naming with Categories)

---

## Troubleshooting

**Issue**: `realpath: command not found` (some systems)  
**Fix**: Replace with `readlink -f "$filepath"` or fall back:
```bash
abs_path=$(realpath "$filepath" 2>/dev/null || readlink -f "$filepath" 2>/dev/null || echo "$filepath")
```

**Issue**: `md5sum: command not found` (macOS)  
**Fix**: Use `md5` on macOS:
```bash
echo "$abs_path" | md5sum 2>/dev/null || echo "$abs_path" | md5
```

**Issue**: Rename history not appearing  
**Fix**: Check file permissions. Ensure script can append to file.

**Issue**: Cache filling up too fast  
**Fix**: Adjust cleanup policy in `cleanup_cache()`:
- Reduce days to 15: `find "$BACKUPS_DIR" -type f -mtime +15 -delete`
- Reduce per-file limit to 5: `if (count[source] <= 5)`

**Issue**: Background cleanup causing delays  
**Fix**: The `&` makes it async, but if issues persist, remove cleanup trigger from `backup_to_cache()` and run manually via cron.

---

## Next Session Quick Start

1. Verify Sprint 2 completed (check for cache functions after line 63)
2. Test cache system: `ls -la ~/.cache/obsidian-polish/`
3. Test rename history: Look for HTML comments in renamed files
4. Proceed to Sprint 3: `sprint-3-intelligent-naming-implementation.md`
