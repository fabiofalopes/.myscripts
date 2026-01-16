# LSP Setup Guide for Python and C

## What is LSP?

The Language Server Protocol (LSP) provides modern IDE features like autocomplete, go-to-definition, hover information, and semantic analysis across multiple languages and editors.

**Key Features:**
- **Smart Completions** - Intelligent autocomplete for functions, variables, types, and imports
- **Navigation** - Goto definition/declaration, find references, and document symbols
- **Code Intelligence** - Hover information, semantic token highlighting, and inlay hints
- **Development Tools** - Automatic formatting, code actions, selection ranges
- **Symbol Operations** - Rename symbols, find all references, and project navigation

## Supported Language Servers

### Python - pyright
- **Type checking** - Comprehensive static type analysis
- **Autocomplete** - Intelligent code suggestions
- **Definition navigation** - Jump to definitions and references
- **Hover docs** - Function signatures and documentation

### C/C++ - clangd
- **Code completion** - Context-aware suggestions
- **Diagnostic info** - Compiler-like error/warning detection
- **Symbol navigation** - Find definitions and references
- **Code formatting** - Automatic code formatting via clang-format

## Installation via Mason

Mason is the recommended way to install LSP servers for Neovim:

```bash
# Install Mason (if not already installed)
:Mason

# Install language servers
:MasonInstall pyright
:MasonInstall clangd

# Or install all at once
:MasonInstall pyright clangd
```

### Mason Auto-Setup

Your Neovim configuration (`~/.config/nvim/lua/plugins/configs/lsp.lua`) automatically ensures these servers are installed on startup.

## Alternative Installation Methods

### Debian/Ubuntu (apt)

```bash
# Install clangd
sudo apt install clangd

# Install pyright via npm
npm install -g pyright
```

### debian.griffo.io Repository (for latest versions)

Add the repository for up-to-date development tools:

```bash
# Add GPG key
curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg

# Add repository
echo "deb https://debian.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list

# Update package lists
sudo apt update

# Install clangd (if available)
sudo apt install clangd
```

## Neovim Configuration

LSP is configured in `/home/fabio/.config/nvim/lua/plugins/configs/lsp.lua`

### LSP Keymaps

Your Neovim configuration includes these universal LSP keybindings:

| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `K` | Hover information |
| `gi` | Go to implementation |
| `Ctrl+k` | Signature help |
| `Leader+rn` | Rename symbol |
| `Leader+ca` | Code actions |
| `gr` | Find references |
| `Leader+f` | Format buffer |

### Neovim LSP Config

The configuration is managed by Mason-lspconfig. Both pyright and clangd are automatically installed and configured:

```lua
ensure_installed = {
    "lua_ls",     -- Lua
    "pyright",    -- Python
    "clangd",     -- C/C++
    "html",       -- HTML
    "cssls",      -- CSS
}
```

**Manual clangd configuration** (if needed):

```lua
require('lspconfig').clangd.setup({
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    root_dir = require('lspconfig.util').root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
    capabilities = capabilities,
    on_attach = on_attach,
})
```

## Useful Commands

### Neovim LSP Commands

- `:LspInfo` - Show attached LSP clients
- `:LspRestart` - Restart LSP servers
- `:LspStop` - Stop LSP servers
- `:LspStart` - Start LSP servers
- `:Mason` - Open Mason package manager
- `:MasonUpdate` - Update Mason packages

### Python Development

```bash
# Run Python script
python script.py

# Run with type checking
mypy script.py

# Format code
black script.py
ruff format script.py

# Lint code
ruff check script.py
```

### C/C++ Development

```bash
# Compile C file
gcc -o program program.c

# Compile with debugging symbols
gcc -g -o program program.c

# Compile C++ file
g++ -o program program.cpp

# Check clangd version
clangd --version

# Generate compile_commands.json for clangd (recommended)
# This helps clangd understand your build system
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
```

### LSP Management

```bash
# Update pyright (via npm)
npm update -g pyright

# Update clangd (via apt)
sudo apt update && sudo apt install --only-upgrade clangd

# Check versions
pyright --version
clangd --version
```

## Configuration

### pyright Configuration

Create `pyrightconfig.json` or `pyproject.toml`:

```json
{
    "include": [
        "src"
    ],
    "exclude": [
        "**/node_modules",
        "**/__pycache__",
        ".venv"
    ],
    "pythonVersion": "3.11",
    "typeCheckingMode": "basic",
    "reportMissingImports": true,
    "reportMissingTypeStubs": false
}
```

### clangd Configuration

Create `.clangd` in your project root:

```yaml
CompileFlags:
  Add: [-Wall, -Wextra, -I./include]
Diagnostics:
  UnusedIncludes: Strict
  MissingIncludes: Strict
Hover:
  ShowAKA: Yes
InlayHints:
  Enabled: Yes
  ParameterNames: Yes
  DeducedTypes: Yes
Completion:
  AllScopes: Yes
```

### clang-format Configuration

Create `.clang-format`:

```yaml
BasedOnStyle: Google
IndentWidth: 4
ColumnLimit: 100
```

## Troubleshooting

### LSP Not Starting

Check if servers are installed and in PATH:
```bash
which pyright
pyright --version

which clangd
clangd --version
```

### Neovim Not Detecting LSP

Restart Neovim or manually restart the LSP:
```vim
:LspRestart
```

### clangd Missing compile_commands.json

Generate it with CMake:
```bash
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
ln -s build/compile_commands.json compile_commands.json
```

Or create manually:
```json
[
  {
    "directory": "/path/to/project",
    "command": "gcc -c main.c -I./include",
    "file": "main.c"
  }
]
```

### pyright Import Errors

Ensure you're using the correct Python environment:
- Check your virtual environment is activated
- Verify `pythonPath` in pyright config
- Try `:PyrightRestartPython` (if using pyright plugin)

### Outdated LSP Versions

Update from Mason or package manager:
```vim
:MasonUpdate
```

```bash
# System packages
sudo apt update && sudo apt install --only-upgrade clangd

# npm packages
npm update -g pyright
```

## Resources

### Python
- [pyright GitHub](https://github.com/microsoft/pyright)
- [pyright Documentation](https://microsoft.github.io/pyright/)
- [Python Type Hints](https://docs.python.org/3/library/typing.html)

### C/C++
- [clangd GitHub](https://github.com/clangd/clangd)
- [clangd Documentation](https://clangd.llvm.org/)
- [compile_commands.json](https://clang.llvm.org/docs/JSONCompilationDatabase.html)

### General
- [LSP Specification](https://microsoft.github.io/language-server-protocol/)
- [nvim-lspconfig Documentation](https://github.com/neovim/nvim-lspconfig)
- [Mason.nvim](https://github.com/williamboman/mason.nvim)
- [debian.griffo.io](https://debian.griffo.io/)

## Supported Editors

- **Neovim/Vim** - Native LSP support (recommended)
- **VS Code** - Official Python and C/C++ extensions
- **Emacs** - lsp-mode/eglot compatibility
- **Sublime Text** - LSP package integration
- **Kate/KDevelop** - Built-in LSP support
