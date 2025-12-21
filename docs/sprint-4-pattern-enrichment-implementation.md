# Sprint 4: Pattern Enrichment Implementation (OPTIONAL)

**Duration**: 3 days  
**Complexity**: HIGH  
**Risk**: MEDIUM  
**Dependencies**: Sprint 1 (datetime), Sprint 2 (cache), Sprint 3 (categories)  
**Status**: OPTIONAL - Consider skipping if basic enhancements meet needs

---

## Sprint Goal

Enrich Obsidian note frontmatter with semantic metadata from additional Fabric AI patterns (wisdom, summary, patterns, rating).

---

## ⚠️ Decision Point

**Before starting this sprint**, consider:

**PROS of implementing**:
- Rich semantic metadata in frontmatter
- Better note searchability in Obsidian
- Dataview/Templater integration opportunities
- AI-extracted insights preserved

**CONS of implementing**:
- 3+ days development effort
- Significantly slower processing (4-5 patterns per note)
- Higher API costs (4-5x calls to AI models)
- Frontmatter becomes very long (100+ lines)
- Complexity increases maintenance burden

**RECOMMENDATION**: 
- Skip if basic functionality (Sprints 1-3) meets needs
- Consider as future enhancement if users request richer metadata
- Alternative: Implement as separate script (`obsidian-enrich`) to run on-demand

---

## Pre-Implementation Checklist

- [ ] Sprints 1-3 completed
- [ ] Decision made to proceed (review PROS/CONS above)
- [ ] Read master plan: `obsidian-polish-enhancement-project.md`
- [ ] Backup script: `cp obsidian-polish obsidian-polish.backup-sprint4`
- [ ] Verify Fabric patterns exist: `fabric -l | grep -E '(extract_wisdom|summarize|extract_patterns|rate_content)'`

---

## Current State Analysis

**Current behavior**:
- Runs 1-2 Fabric patterns: `obsidian_note_title` + `obsidian_frontmatter_gen` (or combined)
- Frontmatter has: title, created, modified, category, tags (basic metadata)

**Target behavior**:
- Optionally run 4 additional patterns
- Frontmatter includes: wisdom, summary, patterns, quality_rating
- New flag: `--enrich` to enable pattern enrichment

**Patterns to add**:
1. `extract_wisdom` - Key insights, quotes, references
2. `summarize` - Content summary
3. `extract_patterns` - Recurring themes, patterns
4. `rate_content` - Quality/importance rating

---

## Architecture Overview

### Enrichment Pipeline

```
Original workflow:
1. Read note
2. Run obsidian_note_polish (or title + frontmatter)
3. Write enhanced note

Enhanced workflow (with --enrich):
1. Read note
2. Run obsidian_note_polish
3. ➜ Run extract_wisdom
4. ➜ Run summarize
5. ➜ Run extract_patterns
6. ➜ Run rate_content
7. Merge all metadata into frontmatter
8. Write enriched note
```

### Frontmatter Example (Enriched)

```yaml
---
title: Docker Kubernetes Deployment Guide
created: 2025-12-21
modified: 2025-12-21
category: dev
tags: [docker, kubernetes, devops, deployment]
summary: |
  Comprehensive guide on deploying applications using Docker containers
  orchestrated by Kubernetes. Covers deployment configs, services, and
  best practices for production environments.
wisdom:
  - "Always define resource limits in production deployments"
  - "Use namespace isolation for multi-tenant clusters"
  - "Reference: Kubernetes Best Practices by Brendan Burns"
patterns:
  - Declarative configuration management
  - Container orchestration patterns
  - Health check and readiness probe patterns
quality_rating: 8/10
rating_reasoning: "Well-structured with practical examples, but could use more troubleshooting section"
---
```

---

## Implementation Steps

### Step 1: Add Enrichment Configuration (15 min)

**Location**: After category configuration (after line 70, with Sprint 3 additions)

**Add these lines**:

```bash
# ========== PATTERN ENRICHMENT CONFIGURATION ==========
# Additional Fabric patterns for rich metadata extraction

# Patterns to run when --enrich flag is used
ENRICHMENT_PATTERNS=(
    "extract_wisdom"
    "summarize"
    "extract_patterns"
    "rate_content"
)

# Verify pattern availability on script start (optional, helps debugging)
verify_enrichment_patterns() {
    local available_patterns=$($FABRIC_CMD -l 2>/dev/null)
    local missing=()
    
    for pattern in "${ENRICHMENT_PATTERNS[@]}"; do
        if ! echo "$available_patterns" | grep -q "^$pattern$"; then
            missing+=("$pattern")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_warning "Missing Fabric patterns for enrichment: ${missing[*]}"
        print_status "Install with: fabric --update-patterns"
        return 1
    fi
    
    return 0
}
```

---

### Step 2: Add --enrich Flag (20 min)

**Location 1**: Help text (around line 85)

**ADD to help**:
```bash
  --enrich               Run additional Fabric patterns for rich metadata
                         (extract_wisdom, summarize, extract_patterns, rate_content)
                         Warning: Significantly slower, uses more API calls
```

**Location 2**: Argument parsing (around line 140)

**ADD case block**:
```bash
--enrich)
    ENRICH_MODE=true
    shift
    ;;
```

**Location 3**: Variable defaults (around line 120)

**ADD**:
```bash
ENRICH_MODE=false
```

---

### Step 3: Implement Enrichment Function (2 hours)

**Location**: After `detect_category()` function (around line 200)

**Add this function**:

```bash
# Run enrichment patterns and extract metadata
enrich_metadata() {
    local content="$1"
    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" RETURN
    
    print_section "Running Enrichment Patterns"
    
    # Initialize metadata variables
    local wisdom=""
    local summary=""
    local patterns=""
    local rating=""
    local rating_reasoning=""
    
    # Pattern 1: Extract Wisdom
    print_status "Running extract_wisdom..."
    local wisdom_file="$temp_dir/wisdom.txt"
    echo "$content" | $FABRIC_CMD -p extract_wisdom > "$wisdom_file" 2>&1
    
    if [ -s "$wisdom_file" ]; then
        # Parse wisdom output (expect bullet points or numbered list)
        wisdom=$(cat "$wisdom_file" | grep -E "^[-*•]|^[0-9]+\." | head -10)
        if [ -n "$wisdom" ]; then
            print_success "Extracted wisdom ($(echo "$wisdom" | wc -l | xargs) insights)"
        fi
    fi
    
    # Pattern 2: Summarize
    print_status "Running summarize..."
    local summary_file="$temp_dir/summary.txt"
    echo "$content" | $FABRIC_CMD -p summarize > "$summary_file" 2>&1
    
    if [ -s "$summary_file" ]; then
        # Take first paragraph or 200 chars
        summary=$(cat "$summary_file" | head -5 | tr '\n' ' ' | cut -c1-200)
        if [ -n "$summary" ]; then
            print_success "Generated summary"
        fi
    fi
    
    # Pattern 3: Extract Patterns
    print_status "Running extract_patterns..."
    local patterns_file="$temp_dir/patterns.txt"
    echo "$content" | $FABRIC_CMD -p extract_patterns > "$patterns_file" 2>&1
    
    if [ -s "$patterns_file" ]; then
        patterns=$(cat "$patterns_file" | grep -E "^[-*•]|^[0-9]+\." | head -10)
        if [ -n "$patterns" ]; then
            print_success "Extracted patterns ($(echo "$patterns" | wc -l | xargs) patterns)"
        fi
    fi
    
    # Pattern 4: Rate Content
    print_status "Running rate_content..."
    local rating_file="$temp_dir/rating.txt"
    echo "$content" | $FABRIC_CMD -p rate_content > "$rating_file" 2>&1
    
    if [ -s "$rating_file" ]; then
        # Parse rating (expect "X/10" or similar)
        rating=$(cat "$rating_file" | grep -oE "[0-9]+/10" | head -1)
        rating_reasoning=$(cat "$rating_file" | grep -i "reason" | head -1 | sed 's/.*: //')
        
        if [ -n "$rating" ]; then
            print_success "Content rated: $rating"
        fi
    fi
    
    # Return as pipe-delimited string for parsing
    # Format: wisdom|||summary|||patterns|||rating|||reasoning
    echo "${wisdom}|||${summary}|||${patterns}|||${rating}|||${rating_reasoning}"
}
```

---

### Step 4: Integrate Enrichment into Workflow (1.5 hours)

**Location**: After frontmatter generation (around line 295, after combined mode case)

**FIND** (end of frontmatter generation):
```bash
        print_success "Generated title and frontmatter"
        ;;
esac
```

**ADD AFTER this block**:

```bash
# Step 3.5: Enrichment (if enabled)
if [ "$ENRICH_MODE" = true ]; then
    # Verify patterns available
    if ! verify_enrichment_patterns; then
        print_error "Cannot run enrichment: missing Fabric patterns"
        print_status "Continuing without enrichment..."
        ENRICH_MODE=false
    else
        # Run enrichment
        ENRICHED_DATA=$(enrich_metadata "$NOTE_CONTENT")
        
        # Parse enriched data (pipe-delimited)
        IFS='|||' read -r WISDOM SUMMARY PATTERNS RATING RATING_REASONING <<< "$ENRICHED_DATA"
        
        # Inject into frontmatter
        if [ -n "$FRONTMATTER" ]; then
            # Build enriched frontmatter
            TEMP_FM=$(mktemp)
            
            # Copy existing frontmatter (up to closing ---)
            echo "$FRONTMATTER" | awk '/^---$/ && NR > 1 { exit } { print }' > "$TEMP_FM"
            
            # Add enriched fields
            if [ -n "$SUMMARY" ]; then
                echo "summary: |" >> "$TEMP_FM"
                echo "  $SUMMARY" >> "$TEMP_FM"
            fi
            
            if [ -n "$WISDOM" ]; then
                echo "wisdom:" >> "$TEMP_FM"
                echo "$WISDOM" | sed 's/^/  - /' >> "$TEMP_FM"
            fi
            
            if [ -n "$PATTERNS" ]; then
                echo "patterns:" >> "$TEMP_FM"
                echo "$PATTERNS" | sed 's/^/  - /' >> "$TEMP_FM"
            fi
            
            if [ -n "$RATING" ]; then
                echo "quality_rating: \"$RATING\"" >> "$TEMP_FM"
            fi
            
            if [ -n "$RATING_REASONING" ]; then
                echo "rating_reasoning: \"$RATING_REASONING\"" >> "$TEMP_FM"
            fi
            
            # Add closing ---
            echo "---" >> "$TEMP_FM"
            
            # Replace frontmatter
            FRONTMATTER=$(cat "$TEMP_FM")
            rm -f "$TEMP_FM"
            
            print_success "Enriched frontmatter with additional metadata"
        fi
    fi
fi
```

---

### Step 5: Add Progress Indicators (30 min)

**Purpose**: Enrichment is slow (4-5 patterns), show progress to user

**Location**: Inside `enrich_metadata()` function

**ADD progress tracking**:

```bash
# At start of enrich_metadata():
local total_patterns=${#ENRICHMENT_PATTERNS[@]}
local current=0

# Before each pattern:
current=$((current + 1))
print_status "[$current/$total_patterns] Running extract_wisdom..."

# Apply to all 4 patterns
```

**Also add time estimates**:

```bash
# At start of enrichment (before enrich_metadata call):
print_warning "Enrichment mode: This will take 2-5 minutes depending on note length"
print_status "Running ${#ENRICHMENT_PATTERNS[@]} additional patterns..."
START_TIME=$(date +%s)

# After enrichment:
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
print_success "Enrichment completed in ${ELAPSED}s"
```

---

### Step 6: Error Handling and Fallbacks (45 min)

**Purpose**: Individual pattern failures shouldn't break entire script

**Modify `enrich_metadata()` to wrap each pattern in error handling**:

```bash
# Example for extract_wisdom:
print_status "[$current/$total_patterns] Running extract_wisdom..."
local wisdom_file="$temp_dir/wisdom.txt"

if echo "$content" | timeout 120 $FABRIC_CMD -p extract_wisdom > "$wisdom_file" 2>&1; then
    if [ -s "$wisdom_file" ]; then
        wisdom=$(cat "$wisdom_file" | grep -E "^[-*•]|^[0-9]+\." | head -10)
        [ -n "$wisdom" ] && print_success "Extracted wisdom"
    else
        print_warning "extract_wisdom returned empty result"
    fi
else
    print_warning "extract_wisdom failed or timed out, skipping"
fi

# Apply timeout and error handling to all 4 patterns
```

**Why timeout**: Some patterns may hang on very long notes or API issues.

---

### Step 7: Testing (3 hours)

**Test Case 1: Basic Enrichment**
```bash
cat > /tmp/test-enrich-basic.md << 'EOF'
# Kubernetes Deployment Best Practices

Always define resource limits for production deployments.
Use namespace isolation for multi-tenant clusters.
Implement health checks and readiness probes.

Key patterns:
- Declarative configuration management
- Rolling update strategies
- Auto-scaling based on metrics

References:
- "Kubernetes Best Practices" by Brendan Burns
- Official Kubernetes documentation
EOF

./obsidian-polish /tmp/test-enrich-basic.md --enrich

# Verify:
# 1. Processing takes 2-5 minutes
# 2. Progress shown for each pattern
# 3. Frontmatter contains: summary, wisdom, patterns, quality_rating
# 4. Wisdom includes quotes/references
# 5. Summary is concise (200 chars)
```

**Test Case 2: Enrichment with Missing Pattern**
```bash
# Temporarily rename a pattern
mv ~/.config/fabric/patterns/extract_wisdom ~/.config/fabric/patterns/extract_wisdom.bak

./obsidian-polish /tmp/test-missing.md --enrich

# Verify:
# 1. Warning shown about missing pattern
# 2. Script continues without enrichment
# 3. OR: Enrichment runs but skips missing pattern

# Restore pattern
mv ~/.config/fabric/patterns/extract_wisdom.bak ~/.config/fabric/patterns/extract_wisdom
```

**Test Case 3: Short Note (Minimal Content)**
```bash
echo "# Quick Note\n\nJust a reminder." > /tmp/test-short.md
./obsidian-polish /tmp/test-short.md --enrich

# Verify:
# 1. Patterns run but return minimal/empty results
# 2. Frontmatter only includes fields with actual data
# 3. No errors or crashes
```

**Test Case 4: Very Long Note (Performance)**
```bash
# Generate long note (1000 lines)
{
    echo "# Long Research Document"
    echo ""
    for i in {1..1000}; do
        echo "Line $i of research content with various topics and themes."
    done
} > /tmp/test-long.md

time ./obsidian-polish /tmp/test-long.md --enrich

# Verify:
# 1. Processing completes (may take 5-10 minutes)
# 2. No timeouts or crashes
# 3. Metadata extracted successfully
# 4. Time shown in output
```

**Test Case 5: Enrichment + Rename + Category**
```bash
cat > /tmp/test-full-pipeline.md << 'EOF'
---
tags: [development, docker]
---

# Container Orchestration Guide

Comprehensive guide on Docker and Kubernetes deployment strategies.
Covers best practices, common pitfalls, and production readiness.
EOF

./obsidian-polish /tmp/test-full-pipeline.md --enrich -r -y

# Verify:
# 1. File renamed to: dev-container-orchestration-guide.md
# 2. Category detected: dev
# 3. Frontmatter enriched with wisdom/summary/patterns/rating
# 4. All sprints working together
```

**Test Case 6: Pattern Timeout Handling**
```bash
# Simulate slow pattern (if possible, or just verify timeout in code)
# Test that timeout (120s) prevents hanging
```

---

## Sprint Completion Checklist

- [ ] Enrichment configuration added (pattern list)
- [ ] `verify_enrichment_patterns()` function implemented
- [ ] `--enrich` flag added (help, parsing, default)
- [ ] `enrich_metadata()` function implemented
- [ ] Enrichment integrated into workflow (after frontmatter generation)
- [ ] Progress indicators added
- [ ] Error handling and timeouts implemented
- [ ] Test Case 1 passes (basic enrichment)
- [ ] Test Case 2 passes (missing pattern handling)
- [ ] Test Case 3 passes (short note)
- [ ] Test Case 4 passes (long note performance)
- [ ] Test Case 5 passes (full pipeline integration)
- [ ] No regressions in existing functionality
- [ ] Git commit created

---

## Commit Message

```bash
git add obsidian-polish
git commit -m "feat(enrich): add optional semantic metadata extraction

- Add --enrich flag to enable rich metadata extraction
- Run 4 additional Fabric patterns: extract_wisdom, summarize, 
  extract_patterns, rate_content
- Inject metadata into frontmatter (wisdom, summary, patterns, rating)
- Add progress indicators for long-running operations
- Implement pattern availability verification
- Add error handling and 120s timeout per pattern

Frontmatter enrichment includes:
- summary: AI-generated content summary (200 chars)
- wisdom: Key insights, quotes, and references
- patterns: Recurring themes and patterns
- quality_rating: Content quality score (X/10)
- rating_reasoning: Explanation of rating

Performance notes:
- Enrichment adds 2-5 minutes processing time
- 4-5x API calls vs basic mode
- Recommended for important/reference notes only

Usage:
  ./obsidian-polish note.md --enrich
  ./obsidian-polish note.md --enrich -r -y

Closes Sprint 4 (OPTIONAL) of obsidian-polish enhancement project"
```

---

## Handoff to Project Completion

**What was completed**:
✅ Optional enrichment mode with 4 additional patterns  
✅ Rich semantic metadata in frontmatter  
✅ Progress tracking for long operations  
✅ Error handling and timeout protection  
✅ Integration with all previous sprints  

**Project status**:
🎉 **ALL SPRINTS COMPLETE** (if Sprint 4 implemented)  
🎉 **CORE SPRINTS COMPLETE** (if Sprint 4 skipped)

**What to do next**:
1. Update user documentation: `docs/obsidian-polish.md`
2. Add examples to README
3. Create final summary commit
4. Optional: Tag release version (`git tag v2.0.0`)
5. Optional: Create changelog

---

## Performance Optimization Ideas (Post-Sprint)

1. **Parallel pattern execution**: Run all 4 patterns concurrently (reduces time from 5min to 90s)
2. **Caching pattern results**: Store in cache, reuse if note unchanged
3. **Selective enrichment**: `--enrich-only wisdom,summary` to run subset of patterns
4. **Batch mode**: Process multiple notes efficiently
5. **Custom pattern priority**: Allow user to configure which patterns to run

---

## Alternative Approaches

If Sprint 4 seems too heavy, consider:

### Option A: Separate Script
Create `obsidian-enrich` as standalone tool:
```bash
# Run basic polish
./obsidian-polish note.md -r

# Later, enrich specific notes on-demand
./obsidian-enrich note.md
```

### Option B: Config File
Allow `.obsidian-polish.conf` to enable enrichment per-directory:
```yaml
enrich: true
patterns: [extract_wisdom, summarize]
```

### Option C: Obsidian Plugin Integration
Create Obsidian plugin that calls enrichment on note save/hotkey.

---

## Troubleshooting

**Issue**: Enrichment very slow (>10 minutes)  
**Fix**: 
- Check Fabric model configuration (use faster model)
- Reduce note length (truncate to first 500 lines before patterns)
- Run patterns in parallel (advanced: use background jobs)

**Issue**: Frontmatter becomes unreadable (too long)  
**Fix**: 
- Limit wisdom/patterns to top 5 items: `head -5`
- Move enriched data to separate note: `note-enriched.md`
- Use Obsidian callouts instead of frontmatter

**Issue**: Pattern failures break script  
**Fix**: 
- Check Fabric installation: `fabric -l`
- Verify API keys configured
- Check timeout value (increase if needed: `timeout 300`)

**Issue**: Memory issues with very long notes  
**Fix**:
- Truncate content before patterns: `echo "$content" | head -500`
- Process in chunks, aggregate results

---

## Next Session Quick Start

1. Verify Sprint 4 completed (check for `enrich_metadata()` function)
2. Test enrichment: `./obsidian-polish note.md --enrich`
3. Check frontmatter has: wisdom, summary, patterns, rating
4. Update user documentation with new features
5. Create project summary and close enhancement project
