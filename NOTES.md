# .myscripts Notes

## Development Philosophy

This workspace is designed for **developing scripts that interact with fabric AI prompts**.

### The Workflow:
1. **Create/modify custom fabric patterns** (AI prompts) in `fabric-custom-patterns/`
2. **Build scripts** that orchestrate these patterns into useful workflows
3. **Test and iterate** on both scripts and patterns in the same location
4. **Deploy** - scripts run from anywhere, patterns are tracked in the repo

### The Architecture:
```
.myscripts/                         # Script development & execution
├── txrefine                        # Script that uses patterns
├── workflow-design                 # Script that uses patterns
├── (other scripts)
└── fabric-custom-patterns/         # ACTUAL PATTERNS (tracked in git)
    ├── transcript-analyzer/        # Pattern definitions
    ├── transcript-refiner/
    └── (other patterns)
```

This architecture ensures:
- ✅ Scripts and their dependencies are versioned together
- ✅ Repo is self-contained and functional
- ✅ Patterns can be edited in Obsidian (via symlink from Obsidian)
- ✅ Clone the repo → everything works

## Repository Structure

### fabric-custom-patterns/
**The source of truth for custom fabric patterns used by scripts in this repo.**

- **Location**: `~/.myscripts/fabric-custom-patterns/`
- **Purpose**: Contains the actual pattern definitions that scripts depend on
- **Tracked in Git**: ✅ YES - patterns are versioned with the scripts that use them
- **Why tracked**: Scripts like `txrefine` and `workflow-design` depend on specific patterns. Without the patterns, the scripts are useless.

### The Obsidian Connection (Optional Setup)

For comfortable editing of patterns in Obsidian:

```bash
# From your Obsidian vault, create a symlink TO this repo
cd ~/Documents/Obsidian_Vault_01/Vault_01/
ln -s ~/.myscripts/fabric-custom-patterns fabric-custom-patterns

# Now you can view/edit patterns in Obsidian while they're tracked here
```

**Important**: The symlink goes FROM Obsidian TO this repo, not the other way around.
- Source of truth: `~/.myscripts/fabric-custom-patterns/` (this repo)
- Obsidian convenience: Symlink for viewing/editing
- Git tracks: The actual patterns in this repo

### Fabric Configuration

To use these patterns with fabric:

```bash
# Option 1: Symlink from fabric's custom patterns directory
ln -s ~/.myscripts/fabric-custom-patterns ~/.config/fabric/patterns/custom

# Option 2: Or configure fabric to read from this location directly
# (refer to fabric documentation for configuration options)
```

## Current Scripts

### txrefine
**Purpose**: Refine voice transcriptions using AI analysis

**Patterns Used**: 
- `transcript-analyzer` - Analyzes transcription for errors
- `transcript-refiner` - Applies corrections

**Workflow**:
1. Receives raw transcription via pipe
2. Stage 1: Runs `transcript-analyzer` to identify issues
3. Stage 2: Runs `transcript-refiner` with raw text + analysis
4. Outputs refined transcription and copies to clipboard

**Usage**:
```bash
voicenote | txrefine
cat transcript.txt | txrefine
xclip -o | txrefine
```

**Development Notes**:
- Requires piped input (no defaults)
- Shows real-time fabric command outputs
- Two-stage processing for better results
- Pattern files can be edited in `fabric-custom-patterns/`

## Development Tools

### workflow-architect pattern
When designing new workflows, use the `workflow-architect` pattern:

```bash
echo "I want to create a workflow that..." | fabric -p workflow-architect
```

This pattern helps you:
- Break down complex tasks into stages
- Design composable patterns
- Create script orchestration logic
- Define input/output contracts
- Plan testing strategies

**Location**: `fabric-custom-patterns/workflow-architect/`

## Obsidian symlinks + hot reload

Cheat sheet + context:

- `~/.myscripts/docs/obsidian-symlinks-cheatsheet.md`
- `~/.myscripts/docs/obsidian-symlinks-and-hot-reload.md`

Session handoff log:
- `~/.myscripts/docs/obsidian-symlinks-session-handoff-2025-12-19.md`
