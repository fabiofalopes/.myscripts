# Obsidian symlinks workflow — session handoff log

**Date**: 2025-12-19  
**Timestamp (system)**: 2025-12-19 20:55:43 WET

This file is a precise handoff of what was done, why, what exists now, and what to do next.

---

## 1) What this session was *actually* about

We wanted a reliable way to work on external folders (projects/repos) inside Obsidian.

- The goal was **not** to reorganize projects into the vault.
- The goal was to **keep projects where they already live** (e.g. `~/Documents/...`, `~/projetos/...`) and **surface them inside Obsidian**.

The key friction discovered/assumed from the start:
- Obsidian sometimes **does not refresh** reliably when files are changed outside of Obsidian, especially when viewing external content through symlinks.

---

## 2) Initial direction (that we abandoned)

We initially moved toward creating a custom helper command called `obslink`.

### 2.1 What `obslink` was supposed to do (conceptually)
- Create/remove/manage symlinks into the vault.
- Provide a nicer interface than `ln -s` / `rm`.

### 2.2 Why we abandoned it
We concluded that it was the wrong solution and explicitly decided:

- The symlink creation itself is already solved perfectly by `ln -s`.
- The real pain point is **Obsidian’s refresh/inotify behavior**, not symlink management.
- A custom tool would grow complexity (state, registry, edge cases) while still not solving the refresh problem.

**Decision:** no custom command. Keep it boring.

---

## 3) What we removed (scorched earth)

We removed all traces of the `obslink` concept/tooling so it’s effectively “as if it never existed”.

Deleted paths:
- `~/.myscripts/obslink`
- `~/.myscripts/obslink.d/`
- `~/.local/bin/obslink`

Result:
- `obslink` is not present on PATH.

---

## 4) What we standardized instead (the actual workflow)

### 4.1 The minimal workflow
1. Choose a single folder inside the vault to hold symlinks:
   - `.../Vault_01/_linked/`
2. For each external project, create a symlink inside `_linked/`.
3. If Obsidian doesn’t notice file changes reliably: use **upstream refresh strategies** (Obsidian reload hotkey; plugin only if needed).

### 4.2 Why `_linked/` exists
- It prevents scattering symlinks everywhere in the vault.
- It makes it obvious which content is “external”.
- It keeps removals safe and predictable.

---

## 5) What exists right now (verified state)

### 5.1 Vault location used
- `OBSVAULT=/home/fabio/Documents/Obsidian_Vault_01/Vault_01`

### 5.2 Symlink created (and verified)
Symlink exists:
- `/home/fabio/Documents/Obsidian_Vault_01/Vault_01/_linked/monitor-lusofona`

Symlink target:
- `/home/fabio/Documents/monitor-lusofona`

This was verified via:
- `ls -la "$OBSVAULT/_linked"`
- `readlink -f "$OBSVAULT/_linked/monitor-lusofona"`

### 5.3 Plugin directory state (verified)
The vault already has some plugins installed, but **no hot-reload / file-explorer-reload plugin** was installed as part of this work.

Checked directory:
- `/home/fabio/Documents/Obsidian_Vault_01/Vault_01/.obsidian/plugins/`

Observed entries (examples):
- `dataview`, `terminal`, `copilot`, etc.

---

## 6) Documentation work (where we wrote the “source of truth”)

We intentionally decided:
- Do **not** document this inside `monitor-lusofona`.
- Keep it in `~/.myscripts/docs/` as a durable personal workflow note.

### 6.1 Files created/maintained
These exist and describe the current workflow:

1) `~/.myscripts/docs/obsidian-symlinks-cheatsheet.md`
- “Do this” commands for `ln -s`, `rm`, and listing.
- Contains the `_linked/` convention and example symlink to `monitor-lusofona`.

2) `~/.myscripts/docs/obsidian-symlinks-and-hot-reload.md`
- Explains the final decision: symlinks + upstream refresh methods.
- Explains that a custom tool was removed.
- Mentions two “hot reload” concepts (general vault reload vs plugin-dev reload).

3) `~/.myscripts/NOTES.md`
- Contains a link section referencing the two docs above.

---

## 7) Important correction discovered during research

There is a crucial nuance in plugin choices:

### 7.1 “Reload app without saving”
- This is an Obsidian command.
- It’s a common community workaround to force Obsidian to re-read everything.
- It’s effective but heavy for big vaults.

### 7.2 A targeted approach exists: “reload file explorer”
We identified a plugin specifically aimed at the symptoms we care about:
- Repository: `mnaoumov/obsidian-file-explorer-reload`
- Adds commands like: “Reload File Explorer” and folder reload context items.
- This plugin is **not accepted into the official Community Plugins list**.
- Installation method is via **BRAT** (Obsidian plugin that installs plugins from GitHub).

This plugin’s stated purpose matches our problem statement:
- External bulk file changes (copy/move/delete) not reflected in File Explorer.
- Avoid full app reload.

So we have a clear escalation ladder:
1) Try built-in Obsidian reload hotkey.
2) If pain persists, install BRAT and then this plugin.

---

## 8) Next steps (exact continuation plan)

These were not executed yet; they are the planned continuation.

### Step A — Run the minimal refresh test
Goal: find out if Obsidian refresh is actually broken for your use case.

1) In Obsidian, open:
- `_linked/monitor-lusofona`

2) In terminal, do 2–3 actions inside `/home/fabio/Documents/monitor-lusofona`:
- Create: `touch obsidian-refresh-test.md`
- Rename: `mv obsidian-refresh-test.md obsidian-refresh-test-renamed.md`
- Delete: `rm obsidian-refresh-test-renamed.md`

3) Observe:
- Does File Explorer update immediately?
- Does it lag?
- Does it not update at all until reload?

Record result in this handoff file when you resume.

### Step B — If refresh is flaky, bind the Obsidian reload command
In Obsidian:
- Bind hotkey for: `Reload app without saving`

Use it intentionally as a manual “sync with disk now” action.

### Step C — If hotkey reload is too heavy, install a targeted plugin
Install path:
1) Install and enable **BRAT**.
2) Use BRAT to install:
   - `mnaoumov/obsidian-file-explorer-reload`
3) Validate new commands:
- “Reload File Explorer”
- “Reload Folder” / “Reload Folder with Subfolders”

### Step D — Update the cheat sheet with whatever is chosen
Update:
- `~/.myscripts/docs/obsidian-symlinks-cheatsheet.md`

Specifically:
- Replace the generic “use a Hot Reload plugin” line with the actual chosen method:
  - either “use reload app hotkey”
  - or “BRAT + file-explorer-reload plugin”

Keep it short and action-oriented.

---

## 9) Non-goals (what we explicitly avoided)

- No new scripts/tools.
- No `obslink` revival.
- No documentation inside `monitor-lusofona`.
- No plugin installation (yet) until we prove the refresh pain is real.

---

## 10) Quick copy-paste snippets

### Verify current link state
```bash
OBSVAULT="$HOME/Documents/Obsidian_Vault_01/Vault_01"
ls -la "$OBSVAULT/_linked"
readlink -f "$OBSVAULT/_linked/monitor-lusofona"
```

### Create/remove links
```bash
ln -s "/absolute/path/to/project" "$OBSVAULT/_linked/project"
rm "$OBSVAULT/_linked/project"
```

### Refresh test actions
```bash
cd "/home/fabio/Documents/monitor-lusofona"
touch obsidian-refresh-test.md
mv obsidian-refresh-test.md obsidian-refresh-test-renamed.md
rm obsidian-refresh-test-renamed.md
```
