# Obsidian Symlinks Cheat Sheet

**Last updated**: 2025-12-19

This is the *boring, reliable workflow*.

## 0) One-time setup

Pick a single folder inside your vault to hold external links:

```bash
export OBSVAULT="$HOME/Documents/Obsidian_Vault_01/Vault_01"
mkdir -p "$OBSVAULT/_linked"
```

(You can add the `export OBSVAULT=...` to your shell config.)

## 1) Add link (bring a project into Obsidian)

```bash
ln -s "/absolute/path/to/project" "$OBSVAULT/_linked/project"
```

Examples:

```bash
ln -s "$HOME/Documents/monitor-lusofona" "$OBSVAULT/_linked/monitor-lusofona"
ln -s "$HOME/projetos/some-repo" "$OBSVAULT/_linked/some-repo"
```

## 2) Remove link (clean up later)

```bash
rm "$OBSVAULT/_linked/project"
```

## 3) List what’s linked

```bash
ls -la "$OBSVAULT/_linked"
```

## 4) If Obsidian doesn’t refresh reliably

Use an upstream “Hot Reload” plugin to reload Obsidian when watched paths change.

Reference note (context + options):
- `~/.myscripts/docs/obsidian-symlinks-and-hot-reload.md`

## Optional: tiny convenience alias (not a tool)

If you *really* want shorter typing, keep it as an alias/function in your shell, not a custom tool:

```bash
# add to ~/.bashrc or ~/.zshrc
oln() { ln -s "$1" "$OBSVAULT/_linked/${2:-$(basename "$1")}"; }
olrm() { rm "$OBSVAULT/_linked/$1"; }
```
