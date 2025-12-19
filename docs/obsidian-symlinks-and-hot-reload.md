# Obsidian: Symlinks + Hot Reload (Final Workflow)

**Last updated**: 2025-12-19

## Outcome (what we use going forward)

We do **not** maintain a custom command for this.

We use:

1. **Plain symlinks** into a dedicated vault folder (e.g. `_linked/`)
2. An **upstream Hot Reload plugin** to mitigate Obsidian not always refreshing external changes reliably

This keeps the workflow simple, standard, and low-maintenance.

---

## The core idea

- Keep real projects wherever they belong (e.g. `~/Documents/...`, `~/projetos/...`)
- In the Obsidian vault, keep a single folder for external links:

```text
$OBSVAULT/_linked/
```

- Symlink projects into that folder:

```bash
export OBSVAULT="$HOME/Documents/Obsidian_Vault_01/Vault_01"
mkdir -p "$OBSVAULT/_linked"

ln -s "$HOME/Documents/monitor-lusofona" "$OBSVAULT/_linked/monitor-lusofona"
```

To remove links later:

```bash
rm "$OBSVAULT/_linked/monitor-lusofona"
```

---

## Upstream Hot Reload plugin (refresh reliability)

There are two common "hot reload" tools people use in the Obsidian ecosystem; pick what matches the problem:

### A) Reload Obsidian when watched paths change (useful for symlinked/external content)

- Repo: `EthanGunter/obsidan-hot-reload`
- Install: via Obsidian Community Plugins
- What it does: reloads Obsidian when specified files/dirs change (can include paths outside the vault)

This is the closest match when the problem is: "Obsidian isn’t noticing changes in symlinked/external folders quickly or consistently".

### B) Reload Obsidian *plugins* during plugin development

- Repo: `pjeby/hot-reload`
- Install: manual (clone/unzip into `.obsidian/plugins/`)
- What it does: auto-disables/re-enables plugins when their `main.js` or `styles.css` changes

This is mainly for plugin/theme development; it’s not a general solution for note refresh.

---

## What happened (brief story / why we removed the old stuff)

We initially started building a custom helper command to manage these links.

Then we realized:
- it was growing unnecessary complexity (registry/config/edge cases)
- it duplicated what standard symlinks already give us
- the real pain point was Obsidian refresh behavior, which upstream “hot reload” plugins already address

So we deleted the custom tooling and kept only:
- the `_linked/` convention
- references to upstream solutions

---

## Decision

**We keep the workflow intentionally boring**:
- `ln -s` to add links
- `rm` to remove links
- Hot Reload plugin (from upstream) to smooth refresh issues
