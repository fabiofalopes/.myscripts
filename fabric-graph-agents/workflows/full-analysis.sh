#!/bin/bash
# FULL POWER WORKFLOW - Runs complete dimensional analysis with all agents

set -e

INPUT_FILE="$1"
OUTPUT_BASE="${2:-./analysis-$(date +%Y%m%d-%H%M%S)}"

if [ -z "$INPUT_FILE" ]; then
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║     FABRIC GRAPH AGENTS - FULL ANALYSIS WORKFLOW             ║
╚══════════════════════════════════════════════════════════════╝

Usage: $0 <input_file> [output_dir]

This runs the COMPLETE workflow:
  1. Dimensional Extraction
  2. Question Narrowing (per dimension)
  3. Threat Intelligence
  4. Config Validation (if applicable)
  5. Wisdom Synthesis
  6. Graph Visualization

Example:
  ./full-analysis.sh my-rambling.txt
  ./full-analysis.sh security-notes.md ./my-analysis

EOF
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: File not found: $INPUT_FILE"
    exit 1
fi

AGENTS_DIR="$HOME/Documents/projetos/hub/.myscripts/fabric-graph-agents/agents"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

section() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${YELLOW}$1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Create output structure
mkdir -p "$OUTPUT_BASE"/{dimensions,questions,research,validation,synthesis,graphs,logs}

log "🚀 Starting FULL ANALYSIS WORKFLOW"
log "📥 Input: $INPUT_FILE"
log "📁 Output: $OUTPUT_BASE"

# ============================================================================
# STAGE 1: DIMENSIONAL EXTRACTION
# ============================================================================
section "STAGE 1: DIMENSIONAL EXTRACTION"

log "Extracting semantic dimensions..."

cat "$INPUT_FILE" | fabric-ai --pattern dimension_extractor_ultra | \
    sed -n '/^```json/,/^```$/p' | sed '1d;$d' > "$OUTPUT_BASE/dimensions/_extraction.json"

# Parse and create dimension files
cat "$OUTPUT_BASE/dimensions/_extraction.json" | \
    jq -r '.dimensions[] | "\(.filename)|\(.type)|\(.weight)|\(.keywords | join(","))|\(.content)"' | \
    while IFS='|' read -r filename type weight keywords content; do
        log "  📄 Creating: $filename"
        {
            echo "# $(echo $filename | sed 's/.md//' | sed 's/-/ /g')"
            echo ""
            echo "**Type**: $type  "
            echo "**Weight**: $weight  "
            echo "**Keywords**: $keywords  "
            echo ""
            echo "---"
            echo ""
            echo "$content"
        } > "$OUTPUT_BASE/dimensions/$filename"
    done

DIM_COUNT=$(ls -1 "$OUTPUT_BASE/dimensions"/*.md 2>/dev/null | wc -l | tr -d ' ')
success "Extracted $DIM_COUNT dimensions"

# ============================================================================
# STAGE 2: QUESTION NARROWING (Per Dimension)
# ============================================================================
section "STAGE 2: QUESTION NARROWING"

log "Generating specific questions for each dimension..."

for dim_file in "$OUTPUT_BASE/dimensions"/*.md; do
    if [ -f "$dim_file" ]; then
        dim_name=$(basename "$dim_file" .md)
        log "  🔍 Processing: $dim_name"
        
        cat "$dim_file" | fabric-ai --pattern extract_questions > \
            "$OUTPUT_BASE/questions/${dim_name}-questions.md" 2>/dev/null || \
            echo "# Questions for $dim_name\n\nFailed to extract questions." > \
            "$OUTPUT_BASE/questions/${dim_name}-questions.md"
        
        # Also improve the questions
        cat "$OUTPUT_BASE/questions/${dim_name}-questions.md" | \
            fabric-ai --pattern improve_prompt > \
            "$OUTPUT_BASE/questions/${dim_name}-improved.md" 2>/dev/null || \
            cp "$OUTPUT_BASE/questions/${dim_name}-questions.md" \
               "$OUTPUT_BASE/questions/${dim_name}-improved.md"
    fi
done

QUESTION_COUNT=$(ls -1 "$OUTPUT_BASE/questions"/*-improved.md 2>/dev/null | wc -l | tr -d ' ')
success "Generated questions for $QUESTION_COUNT dimensions"

# ============================================================================
# STAGE 3: THREAT INTELLIGENCE
# ============================================================================
section "STAGE 3: THREAT INTELLIGENCE"

log "Generating research queries for security-related dimensions..."

# Combine all technical dimensions
cat "$OUTPUT_BASE/dimensions"/*.md | \
    grep -l "Type.*technical" | \
    xargs cat > "$OUTPUT_BASE/research/_combined-technical.md" 2>/dev/null || \
    echo "No technical dimensions found" > "$OUTPUT_BASE/research/_combined-technical.md"

# Generate search queries
log "  🔎 Analyzing threats..."
cat "$OUTPUT_BASE/research/_combined-technical.md" | \
    fabric-ai --pattern search_query_generator > \
    "$OUTPUT_BASE/research/search-queries.md" 2>/dev/null || \
    echo "# Search Queries\n\nFailed to generate queries." > \
    "$OUTPUT_BASE/research/search-queries.md"

# Optimize queries
log "  🎯 Optimizing search queries..."
cat "$OUTPUT_BASE/research/search-queries.md" | \
    fabric-ai --pattern deep_search_optimizer > \
    "$OUTPUT_BASE/research/optimized-queries.md" 2>/dev/null || \
    cp "$OUTPUT_BASE/research/search-queries.md" \
       "$OUTPUT_BASE/research/optimized-queries.md"

success "Generated research queries"

# ============================================================================
# STAGE 4: SECURITY ANALYSIS
# ============================================================================
section "STAGE 4: SECURITY ANALYSIS"

log "Running security analysis on technical dimensions..."

# Generate security questions
cat "$OUTPUT_BASE/research/_combined-technical.md" | \
    fabric-ai --pattern ask_secure_by_design_questions > \
    "$OUTPUT_BASE/validation/security-questions.md" 2>/dev/null || \
    echo "# Security Questions\n\nFailed to generate." > \
    "$OUTPUT_BASE/validation/security-questions.md"

# Analyze risks
log "  ⚠️  Analyzing risks..."
cat "$OUTPUT_BASE/validation/security-questions.md" | \
    fabric-ai --pattern analyze_risk > \
    "$OUTPUT_BASE/validation/risk-analysis.md" 2>/dev/null || \
    echo "# Risk Analysis\n\nFailed to analyze." > \
    "$OUTPUT_BASE/validation/risk-analysis.md"

success "Completed security analysis"

# ============================================================================
# STAGE 5: WISDOM SYNTHESIS
# ============================================================================
section "STAGE 5: WISDOM SYNTHESIS"

log "Synthesizing insights from all dimensions..."

# Combine everything
cat "$OUTPUT_BASE/dimensions"/*.md > "$OUTPUT_BASE/synthesis/_all-dimensions.md" 2>/dev/null

# Extract wisdom
log "  💡 Extracting wisdom..."
cat "$OUTPUT_BASE/synthesis/_all-dimensions.md" | \
    fabric-ai --pattern extract_wisdom > \
    "$OUTPUT_BASE/synthesis/wisdom.md" 2>/dev/null || \
    echo "# Wisdom\n\nFailed to extract." > "$OUTPUT_BASE/synthesis/wisdom.md"

# Extract insights
log "  🎯 Extracting insights..."
cat "$OUTPUT_BASE/synthesis/wisdom.md" | \
    fabric-ai --pattern extract_insights > \
    "$OUTPUT_BASE/synthesis/insights.md" 2>/dev/null || \
    echo "# Insights\n\nFailed to extract." > "$OUTPUT_BASE/synthesis/insights.md"

# Extract recommendations
log "  📋 Generating recommendations..."
cat "$OUTPUT_BASE/synthesis/insights.md" | \
    fabric-ai --pattern extract_recommendations > \
    "$OUTPUT_BASE/synthesis/recommendations.md" 2>/dev/null || \
    echo "# Recommendations\n\nFailed to generate." > "$OUTPUT_BASE/synthesis/recommendations.md"

# Create master action plan
log "  🚀 Creating master action plan..."
{
    echo "# Master Action Plan"
    echo ""
    echo "**Generated**: $(date)"
    echo "**Source**: $INPUT_FILE"
    echo "**Dimensions Analyzed**: $DIM_COUNT"
    echo ""
    echo "---"
    echo ""
    echo "## Key Insights"
    echo ""
    cat "$OUTPUT_BASE/synthesis/insights.md" | tail -n +2
    echo ""
    echo "---"
    echo ""
    echo "## Recommendations"
    echo ""
    cat "$OUTPUT_BASE/synthesis/recommendations.md" | tail -n +2
    echo ""
    echo "---"
    echo ""
    echo "## Security Considerations"
    echo ""
    cat "$OUTPUT_BASE/validation/risk-analysis.md" | tail -n +2 | head -20
    echo ""
    echo "---"
    echo ""
    echo "## Research Queries"
    echo ""
    cat "$OUTPUT_BASE/research/optimized-queries.md" | tail -n +2 | head -20
} > "$OUTPUT_BASE/MASTER-ACTION-PLAN.md"

success "Created master action plan"

# ============================================================================
# STAGE 6: GRAPH VISUALIZATION
# ============================================================================
section "STAGE 6: GRAPH VISUALIZATION"

log "Creating execution graph visualization..."

# Create a sample graph showing the workflow
cat > "$OUTPUT_BASE/graphs/workflow-graph.json" << 'EOF'
{
  "strategy": "comprehensive_analysis",
  "graph": {
    "nodes": [
      {
        "id": "node-1",
        "pattern": "dimension_extractor_ultra",
        "description": "Extract semantic dimensions"
      },
      {
        "id": "node-2",
        "pattern": "extract_questions",
        "description": "Generate questions per dimension"
      },
      {
        "id": "node-3",
        "pattern": "search_query_generator",
        "description": "Generate research queries"
      },
      {
        "id": "node-4",
        "pattern": "ask_secure_by_design_questions",
        "description": "Security analysis"
      },
      {
        "id": "node-5",
        "pattern": "extract_wisdom",
        "description": "Synthesize wisdom"
      },
      {
        "id": "node-6",
        "pattern": "extract_recommendations",
        "description": "Generate action plan"
      }
    ],
    "execution_order": [[1], [2, 3, 4], [5], [6]]
  }
}
EOF

# Visualize if tools available
if [ -f "./fabric-analysis/lib/visualize_graph.sh" ]; then
    ./fabric-analysis/lib/visualize_graph.sh "$OUTPUT_BASE/graphs/workflow-graph.json" > \
        "$OUTPUT_BASE/graphs/workflow-visualization.txt"
fi

if [ -f "./fabric-analysis/lib/graph_to_mermaid.py" ]; then
    python3 ./fabric-analysis/lib/graph_to_mermaid.py "$OUTPUT_BASE/graphs/workflow-graph.json" > \
        "$OUTPUT_BASE/graphs/workflow-mermaid.md"
fi

success "Created graph visualizations"

# ============================================================================
# FINAL SUMMARY
# ============================================================================
section "ANALYSIS COMPLETE"

echo ""
echo "📊 RESULTS SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  📁 Output Directory: $OUTPUT_BASE"
echo "  📄 Dimensions Extracted: $DIM_COUNT"
echo "  ❓ Question Sets Generated: $QUESTION_COUNT"
echo "  🔍 Research Queries: $(cat "$OUTPUT_BASE/research/optimized-queries.md" 2>/dev/null | grep -c "^-" || echo "N/A")"
echo "  ⚠️  Security Analysis: Complete"
echo "  💡 Wisdom Synthesis: Complete"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 KEY OUTPUTS:"
echo ""
echo "  🎯 Master Action Plan:"
echo "     $OUTPUT_BASE/MASTER-ACTION-PLAN.md"
echo ""
echo "  📊 Dimensions:"
echo "     $OUTPUT_BASE/dimensions/"
echo ""
echo "  ❓ Questions:"
echo "     $OUTPUT_BASE/questions/"
echo ""
echo "  🔍 Research:"
echo "     $OUTPUT_BASE/research/"
echo ""
echo "  ⚠️  Security:"
echo "     $OUTPUT_BASE/validation/"
echo ""
echo "  💡 Synthesis:"
echo "     $OUTPUT_BASE/synthesis/"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
success "FULL ANALYSIS COMPLETE!"
echo ""
echo "🚀 Next Steps:"
echo "   1. Read: $OUTPUT_BASE/MASTER-ACTION-PLAN.md"
echo "   2. Review dimensions in: $OUTPUT_BASE/dimensions/"
echo "   3. Use research queries from: $OUTPUT_BASE/research/"
echo ""
