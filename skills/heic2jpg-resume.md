# Skill: Resume HEIC2JPG Project

**Skill ID**: `heic2jpg-resume`
**Purpose**: Resume work on the HEIC to JPG bulk converter implementation
**Project**: Multi-session development of `heic2jpg.sh`

---

## 🎯 Quick Context

You are implementing a bulk HEIC to JPG image converter script for `.myscripts`. This is a **multi-session project** - don't try to complete everything at once.

---

## 📋 Essential Information

### Project Files
- **Masterplan**: `/home/fabio/.myscripts/docs/plans/HEIC2JPG_MASTERPLAN.md`
- **Target Script**: `/home/fabio/.myscripts/heic2jpg.sh` (to be created)
- **Reference Script**: `/home/fabio/.myscripts/flac2mp3.sh` (existing pattern)

### Key Decisions (Already Made)
1. **Tool**: ImageMagick (primary) with auto-fallback to heif-convert
2. **Version**: Enhanced (all features included)
3. **Quality**: Default 90%, configurable via argument
4. **Metadata**: Preserve EXIF data
5. **Error Handling**: Robust (skip bad files, log errors, continue)

---

## 🔄 Resumption Protocol

### Step 1: Load Context
```bash
# Read the masterplan to see current status
Read: /home/fabio/.myscripts/docs/plans/HEIC2JPG_MASTERPLAN.md

# Check which phase you're in (look for unchecked boxes)
# Phases: 1=Core Development, 2=Documentation, 3=Testing, 4=Polish
```

### Step 2: Identify Current Task
Look for the **first unchecked box** in the masterplan. That's your next task.

### Step 3: Review Reference Implementation
```bash
# If starting Phase 1, read the reference script
Read: /home/fabio/.myscripts/flac2mp3.sh

# This shows the pattern to follow
```

### Step 4: Implement Current Task
- Work on **ONE task** at a time
- Update the checkbox when complete
- If task is large, break it into sub-tasks
- Don't skip ahead to future phases

### Step 5: Update Progress
After completing a task:
1. Mark checkbox as complete in masterplan: `- [x]`
2. If phase is complete, mark phase header
3. Save progress
4. Move to next task or hand off to next session

---

## 🎨 Implementation Pattern

### Script Structure (from flac2mp3.sh)
```bash
#!/bin/bash

# 1. Header comment with usage
# 2. Argument validation
# 3. Directory validation
# 4. Create output directory
# 5. Loop through files
# 6. Process each file
# 7. Done
```

### Key Differences for HEIC Version
- Tool detection (ImageMagick vs heif-convert)
- Quality parameter (optional 2nd arg)
- Case-insensitive file matching (*.heic, *.HEIC)
- Progress counter
- Error logging
- Summary report

---

## 📐 Phase Overview

### Phase 1: Core Development (Tasks 1.1 - 1.10)
**Goal**: Working script with all features
**Focus**: Functionality over polish
**Output**: `/home/fabio/.myscripts/heic2jpg.sh` (executable)

### Phase 2: Documentation (Tasks 2.1 - 2.5)
**Goal**: Complete documentation
**Focus**: User can understand and use
**Output**: Updated README, inline docs

### Phase 3: Testing (Tasks 3.1 - 3.10)
**Goal**: Verify all scenarios work
**Focus**: Edge cases and validation
**Output**: Test results, bug fixes

### Phase 4: Polish (Tasks 4.1 - 4.5)
**Goal**: Final improvements
**Focus**: UX and performance
**Output**: Production-ready script

---

## 🛠️ Technical Quick Reference

### Conversion Commands

**ImageMagick**:
```bash
convert "$input.heic" -quality 90 -strip none "$output.jpg"
```

**heif-convert**:
```bash
heif-convert -q 90 "$input.heic" "$output.jpg"
```

### Tool Detection
```bash
detect_conversion_tool() {
    if command -v convert &> /dev/null; then
        if convert -list format | grep -qi heic; then
            echo "imagemagick"
            return 0
        fi
    fi
    
    if command -v heif-convert &> /dev/null; then
        echo "heif-convert"
        return 0
    fi
    
    echo "none"
    return 1
}
```

### Case-Insensitive File Matching
```bash
shopt -s nocaseglob
for heic_file in "${input_dir}"/*.heic; do
    # Process
done
shopt -u nocaseglob
```

### Progress Counter
```bash
total=$(find "$dir" -maxdepth 1 -iname "*.heic" | wc -l)
current=0
for file in ...; do
    ((current++))
    echo "Converting $current/$total: $(basename "$file")"
done
```

---

## ✅ Session Checklist

**At start of each session**:
- [ ] Read masterplan to understand current state
- [ ] Identify current phase and next task
- [ ] Review relevant reference files
- [ ] Understand what needs to be done

**During session**:
- [ ] Work on ONE task at a time
- [ ] Test changes as you go
- [ ] Keep code clean and commented
- [ ] Update masterplan checkboxes

**At end of session**:
- [ ] Mark completed tasks in masterplan
- [ ] Save all changes
- [ ] Ensure project is resumable
- [ ] Note any blockers or questions

---

## 🚨 Important Reminders

### DO:
- ✅ Follow the masterplan phases in order
- ✅ Update checkboxes as you complete tasks
- ✅ Mirror `flac2mp3.sh` structure and style
- ✅ Test each feature as you implement it
- ✅ Handle errors gracefully
- ✅ Write clear, helpful error messages

### DON'T:
- ❌ Try to complete everything in one session
- ❌ Skip ahead to later phases
- ❌ Deviate from technical decisions in masterplan
- ❌ Forget to update progress checkboxes
- ❌ Leave the project in a non-resumable state

---

## 🎯 Current Status Quick Check

**To see where we are**:
```bash
# Count completed vs total tasks in Phase 1
grep "^- \[x\]" /home/fabio/.myscripts/docs/plans/HEIC2JPG_MASTERPLAN.md | wc -l

# See next unchecked task
grep "^- \[ \]" /home/fabio/.myscripts/docs/plans/HEIC2JPG_MASTERPLAN.md | head -1
```

---

## 📞 Handoff Template

**When handing off to next session**, update masterplan with:
```markdown
### Session Notes

**Session [N] - [Date]**:
- Completed: [List tasks completed]
- Current Status: [Phase X.Y]
- Next Task: [Next unchecked task]
- Blockers: [Any issues or questions]
- Notes: [Any important context]
```

---

## 🔗 Related Resources

- **flac2mp3.sh**: Pattern to follow
- **Masterplan**: Complete project spec
- **ImageMagick docs**: `man convert`
- **heif-convert docs**: `heif-convert --help`

---

## 🎬 Getting Started (First Session)

If this is your first session on this project:

1. **Read the masterplan**: Understand the full scope
2. **Read flac2mp3.sh**: See the pattern
3. **Start Phase 1.1**: Create the script file
4. **Follow the spec**: All decisions are made
5. **Update progress**: Mark checkboxes as you go

**First command**:
```bash
Read: /home/fabio/.myscripts/docs/plans/HEIC2JPG_MASTERPLAN.md
```

---

**Skill Version**: 1.0
**Last Updated**: 2026-01-23
**Status**: Ready for use
