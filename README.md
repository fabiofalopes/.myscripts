# .myscripts

Personal scripts and custom fabric patterns for AI-assisted workflows.

## Installation

Add to `.bashrc`:

```shell
export PATH=$PATH:/home/$USER/.myscripts
```

## Structure

- **Scripts**: Executable tools that orchestrate AI patterns (`txrefine`, `workflow-design`, etc.)
- **fabric-custom-patterns/**: Custom fabric AI patterns used by the scripts
- **docs/**: Documentation and guides
- **tmux/**: tmux configuration and setup scripts

## Obsidian Integration (Optional)

To edit patterns in Obsidian while keeping them tracked here:

```bash
# From your Obsidian vault
cd ~/Documents/Obsidian_Vault_01/Vault_01/
ln -s ~/.myscripts/fabric-custom-patterns fabric-custom-patterns
```

This creates a symlink FROM Obsidian TO this repo, allowing you to:
- View and edit patterns in Obsidian's comfortable interface
- Keep patterns versioned with the scripts that depend on them
- Maintain a single source of truth in this repo

## Fabric Configuration

To use these custom patterns with fabric:

```bash
# Link from fabric's patterns directory to this repo
ln -s ~/.myscripts/fabric-custom-patterns ~/.config/fabric/patterns/custom
```

See `NOTES.md` for detailed workflow documentation.
