# obsidian-polish Session Handoff - 2025-12-19

**Status**: Analysis complete, implementation pending  
**Priority**: Ready to implement when you return  
**Location**: `~/.myscripts/obsidian-polish`

---

## Context

We analyzed the obsidian-polish script comprehensively and planned two major improvements:

1. **Rename enhancements** - Add `-r` short alias + fix edge case bugs
2. **Cache-based backup system** - Replace `.bak` files with centralized cache

The documentation at `docs/obsidian-polish.md` already exists and is comprehensive. It will need updating after we implement the cache system.

---

## Current State of obsidian-polish

**Working features:**
- Title + frontmatter generation with Fabric patterns
- In-place editing with `.bak` backup files
- Pipe mode (stdin → stdout + clipboard)
- Output to different file (`-o`)
- `--rename-file` flag (recently added, no short alias yet)
- `--no-backup` to skip backup creation
- `-y` for auto-confirmation

**Known bugs found during analysis:**
1. Empty slugified titles create hidden files (e.g., `/.md`)
2. No filename length validation (extremely long titles could fail)
3. `--rename-file` has no short alias despite being "almost always" used

**Design issues identified:**
1. `.bak` files clutter user directories
2. No automatic cleanup of backups
3. Backups don't track rename operations properly

---

## What We're Building

### Phase A: Quick Fixes (do first)

**1. Add `-r` alias for `--rename-file`**

File: `~/.myscripts/obsidian-polish`  
Line 130: Change `--rename-file)` to `-r|--rename-file)`  
Line 83 (help): Change to `-r, --rename-file       Rename file based on generated title`

**2. Fix empty slugified title bug**

After line 357, add validation:
```bash
SLUGIFIED_TITLE=$(slugify "$TITLE")

# Validate slugified title
if [ -z "$SLUGIFIED_TITLE" ] || [ "$SLUGIFIED_TITLE" = "-" ]; then
    print_warning "Title cannot be converted to valid filename: '$TITLE'"
    print_status "Using timestamp-based name instead"
    SLUGIFIED_TITLE="note-$(date +%Y%m%d-%H%M%S)"
fi

# Truncate to prevent filesystem issues
if [ ${#SLUGIFIED_TITLE} -gt 100 ]; then
    SLUGIFIED_TITLE="${SLUGIFIED_TITLE:0:100}"
    print_warning "Title truncated to 100 characters for filename"
fi
```

**3. Add flag interaction warnings**

After line 155, add:
```bash
# Validate flag combinations
if [ "$RENAME_FILE" = true ] && [ -n "$OUTPUT_FILE" ]; then
    print_warning "--rename-file is ignored when using -o/--output"
fi

if [ "$RENAME_FILE" = true ] && [ "$MODE" = "frontmatter-only" ]; then
    print_warning "--rename-file requires title generation (ignored with -f)"
fi
```

---

### Phase B: Cache System (main feature)

**Goal**: Replace `.bak` files in same directory with centralized cache at `~/.cache/obsidian-polish/`

**Benefits:**
- Clean user directories (no more .bak clutter)
- Automatic intelligent cleanup
- Better tracking of backups + renames
- Safety net preserved

#### Cache Architecture

```
~/.cache/obsidian-polish/
├── backups/
│   ├── 2025-12-19_143022_5a8f9b_note-md.md
│   └── 2025-12-19_143055_7c3d2e_draft-md.md
├── index.txt
└── .last_cleanup
```

**Backup filename format:**
`{YYYY-MM-DD_HHMMSS}_{hash}_{original-basename}.md`

- timestamp: sortable, human-readable
- hash: first 6 chars of md5 of full path (prevents collisions)
- basename: original filename with dots → dashes

**Index file format (pipe-delimited):**
```
# timestamp|source_file|backup_file|operation|new_file
2025-12-19T14:30:22|/home/fabio/notes/note.md|2025-12-19_143022_5a8f9b_note-md.md|edit|
2025-12-19T14:30:55|/home/fabio/notes/draft.md|2025-12-19_143055_7c3d2e_draft-md.md|rename|/home/fabio/notes/new-title.md
```

#### Cleanup Policy

**Triggers** (run in background, non-blocking):
- Cache has > 100 backup files, OR
- Last cleanup was > 24 hours ago

**Rules:**
1. Delete files older than 30 days
2. Keep last 10 backups per unique source file
3. Update index to remove deleted entries

**Why these limits:**
- 30 days: reasonable recovery window
- 10 per file: covers multiple editing sessions
- Markdown files small, cache stays ~10MB even with heavy use

#### Functions to Implement

```bash
# Add after line 35 (cache configuration)
CACHE_DIR="${OBSIDIAN_POLISH_CACHE:-$HOME/.cache/obsidian-polish}"
BACKUPS_DIR="$CACHE_DIR/backups"
INDEX_FILE="$CACHE_DIR/index.txt"
CLEANUP_MARKER="$CACHE_DIR/.last_cleanup"
```

**init_cache_dir()** - Create directory structure + index file if not exists

**get_file_hash(filepath)** - Generate 6-char hash for uniqueness

**backup_to_cache(input_file, operation)** - Main backup function:
- Generate backup filename
- Copy file to cache
- Append to index
- Trigger cleanup check (async)
- Return backup path

**cleanup_cache()** - Remove old backups:
- Check if cleanup needed
- Remove files > 30 days old
- Keep last 10 per source file
- Update cleanup marker

#### Code Changes Required

**Remove --no-backup flag:**
- Delete lines 126-129 (argument parsing)
- Delete line 82 (help text)
- Always backup to cache (safety-first)

**Replace backup creation (lines 344-349):**
```bash
# OLD:
if [ "$NO_BACKUP" = false ]; then
    BACKUP_FILE="${INPUT_FILE}.bak"
    cp "$INPUT_FILE" "$BACKUP_FILE"
    print_success "Backup created: $BACKUP_FILE"
fi

# NEW:
BACKUP_PATH=$(backup_to_cache "$INPUT_FILE" "edit")
print_success "Backup saved: $(basename "$BACKUP_PATH")"
print_status "Cache: $CACHE_DIR"
```

---

## Full Implementation Code (ready to copy-paste)

### Cache Functions (add after line 63, after slugify function)

```bash
# Cache configuration
CACHE_DIR="${OBSIDIAN_POLISH_CACHE:-$HOME/.cache/obsidian-polish}"
BACKUPS_DIR="$CACHE_DIR/backups"
INDEX_FILE="$CACHE_DIR/index.txt"
CLEANUP_MARKER="$CACHE_DIR/.last_cleanup"

# Initialize cache directory
init_cache_dir() {
    if [ ! -d "$BACKUPS_DIR" ]; then
        mkdir -p "$BACKUPS_DIR"
    fi
    
    if [ ! -f "$INDEX_FILE" ]; then
        echo "# Obsidian Polish Backup Index" > "$INDEX_FILE"
        echo "# Format: timestamp|source_file|backup_file|operation|new_file" >> "$INDEX_FILE"
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
    
    # Initialize cache if needed
    init_cache_dir
    
    # Generate backup filename
    local timestamp=$(date '+%Y-%m-%d_%H%M%S')
    local hash=$(get_file_hash "$input_file")
    local basename=$(basename "$input_file" | tr '.' '-')
    local backup_filename="${timestamp}_${hash}_${basename}"
    local backup_path="$BACKUPS_DIR/$backup_filename"
    
    # Copy file to cache
    cp "$input_file" "$backup_path"
    
    # Append to index
    local abs_source=$(realpath "$input_file")
    local iso_timestamp=$(date -Iseconds)
    echo "${iso_timestamp}|${abs_source}|${backup_filename}|${operation}|" >> "$INDEX_FILE"
    
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
        last_cleanup=$(stat -c %Y "$CLEANUP_MARKER" 2>/dev/null || stat -f %m "$CLEANUP_MARKER" 2>/dev/null || echo 0)
    fi
    
    local now=$(date +%s)
    local age=$((now - last_cleanup))
    
    # Only cleanup if >100 files or >24h since last cleanup
    if [ "$file_count" -lt 100 ] && [ "$age" -lt 86400 ]; then
        return 0
    fi
    
    # Remove files older than 30 days
    find "$BACKUPS_DIR" -type f -mtime +30 -delete 2>/dev/null
    
    # Per-file limit: keep last 10 backups per source file
    # Group by source file (field 2), sort by timestamp, keep newest 10
    if [ -f "$INDEX_FILE" ]; then
        # Create temp file with entries to keep
        local temp_index=$(mktemp)
        
        # Copy header
        grep "^#" "$INDEX_FILE" > "$temp_index"
        
        # Process entries: sort by source file, then timestamp descending
        grep -v "^#" "$INDEX_FILE" | sort -t'|' -k2,2 -k1,1r | \
        awk -F'|' '
        {
            source = $2
            count[source]++
            if (count[source] <= 10) {
                print $0
            } else {
                # Mark backup file for deletion
                print $3 > "/dev/stderr"
            }
        }
        ' >> "$temp_index" 2> >(while read backup_file; do
            rm -f "$BACKUPS_DIR/$backup_file" 2>/dev/null
        done)
        
        mv "$temp_index" "$INDEX_FILE"
    fi
    
    # Update cleanup marker
    touch "$CLEANUP_MARKER"
}
```

---

## TODO List (remaining tasks)

### High Priority
- [ ] Add `-r` alias for `--rename-file` (line 130)
- [ ] Fix empty slugified title bug (after line 357)
- [ ] Add filename length validation (after line 357)
- [ ] Implement cache functions (add after line 63)
- [ ] Replace .bak creation with cache calls (lines 344-349)
- [ ] Remove `--no-backup` flag (lines 82, 126-129)
- [ ] Update help text for changes (lines 65-100)

### Medium Priority
- [ ] Add flag interaction warnings (after line 155)
- [ ] Update `docs/obsidian-polish.md` for cache system

### Testing Required
- [ ] Test `-r` alias works same as `--rename-file`
- [ ] Test empty/invalid titles get fallback filename
- [ ] Test very long titles are truncated
- [ ] Test cache directory creation
- [ ] Test backup files appear in cache, not same directory
- [ ] Test cleanup triggers correctly
- [ ] Test rename tracking in index
- [ ] Test concurrent operations (run 2 instances)

---

## Quick Start When You Return

1. Open `~/.myscripts/obsidian-polish` in your editor
2. Read this document for context
3. Start with Phase A (quick fixes) - they're simple
4. Then implement Phase B (cache system) - copy code from above
5. Test each change incrementally
6. Update `docs/obsidian-polish.md` when done

**Test file for development:**
```bash
cd ~/.myscripts
echo "Test content for obsidian polish development" > /tmp/test-note.md
./obsidian-polish /tmp/test-note.md -r
```

---

## Notes

- Repository location on this machine: `~/.myscripts` (NOT `~/projects/hub`)
- The script uses `fabric-ai` or `fabric` command (detects automatically)
- Existing documentation at `docs/obsidian-polish.md` is comprehensive but documents current `.bak` behavior
- The cache system is designed to be invisible to users - just works better

---

**Created**: 2025-12-19  
**Session**: obsidian-polish enhancement planning  
**Next action**: Implement changes when you have time
