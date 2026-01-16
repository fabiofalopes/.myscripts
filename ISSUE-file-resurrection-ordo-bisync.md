# ISSUE: Files Resurrecting After Deletion (Ordo Bisync)

**Status:** OPEN - Needs investigation
**Priority:** HIGH
**Reported:** 2026-01-15
**Affects:** Obsidian Vault files synced via OrdoMount

## Problem Description

Files deleted in Obsidian keep reappearing in the vault's main folder. Example:
- File: `śdsds.md` in `/home/fabio/Documents/Obsidian_Vault_01/Vault_01/`
- Deleted 4+ times, keeps coming back
- `obsidian-polish` has NOT touched this file

## Root Cause Analysis

### Confirmed: OrdoMount/rclone bisync is the culprit

**Evidence:**
1. `ordo-sync.service` is running (systemd user service)
2. Sync target: `/home/fabio/Documents` ↔ `onedrive-f6388:Documents/`
3. Sync interval: 100 seconds (very aggressive)
4. Uses `rclone bisync` with file watching (inotifywait)

### How bisync resurrects files:

```
rclone bisync maintains state files:
~/.cache/rclone/bisync/*.lst   (file listings)

When you delete a file locally:
1. Local delete happens
2. Bisync sees the file missing locally
3. Bisync checks remote - file might still exist there
4. Bisync thinks: "remote has file, local doesn't = sync it back"
5. File is restored from cloud
```

### Why file is NOT on remote but still resurrects:

Possible causes:
1. **Stale bisync state** - listing files are out of sync
2. **Race condition** - delete happens during sync window
3. **Conflict resolution** - bisync defaults to `--conflict-resolve newer`
4. **Trash folder sync** - Obsidian moves to `.trash`, bisync might restore

## Investigation Commands

```bash
# Check bisync state files
ls -la ~/.cache/rclone/bisync/ | grep -i obsidian

# Check if file in bisync listing
grep -r "sdsds" ~/.cache/rclone/bisync/

# Check OrdoMount logs
tail -100 ~/projetos/hub/OrdoMount/ordo/logs/ordo-sync.log | grep -i sdsds

# Check sync daemon status
systemctl --user status ordo-sync.service

# Force bisync resync (CAUTION: may overwrite)
ORDO_FORCE_RESYNC=1 ~/projetos/hub/OrdoMount/ordo/scripts/ordo-sync.sh sync
```

## Potential Solutions

### Option 1: Configure exclusions (Recommended)

Add to `/home/fabio/projetos/hub/OrdoMount/ordo/config/sync-excludes.conf`:
```
# Exclude Obsidian trash
- .trash/**
- .obsidian/workspace*
```

### Option 2: Delete bisync state to force fresh sync

```bash
# Stop daemon first
systemctl --user stop ordo-sync.service

# Remove bisync state for this target
rm -f ~/.cache/rclone/bisync/*Documents*

# Remove local state marker
rm -f /home/fabio/Documents/.rclone-bisync-state

# Restart with fresh state
systemctl --user start ordo-sync.service
```

### Option 3: Delete file from BOTH local AND remote

```bash
# Delete locally
rm "/home/fabio/Documents/Obsidian_Vault_01/Vault_01/śdsds.md"

# Delete from remote (if exists)
rclone delete "onedrive-f6388:Documents/Obsidian_Vault_01/Vault_01/śdsds.md"

# Force immediate sync
~/projetos/hub/OrdoMount/ordo/scripts/ordo-sync.sh sync
```

### Option 4: Use Obsidian's .trash properly

Obsidian config: Settings → Files & Links → Deleted files → Move to Obsidian trash

Then exclude `.trash` from sync (see Option 1).

## Related Components

| Component | Location | Purpose |
|-----------|----------|---------|
| OrdoMount | `~/projetos/hub/OrdoMount/` | Bidirectional cloud sync |
| ordo-sync.sh | `~/projetos/hub/OrdoMount/ordo/scripts/ordo-sync.sh` | Main sync script |
| Sync config | `~/projetos/hub/OrdoMount/ordo/config/sync-targets.conf` | Defines sync targets |
| Exclusions | `~/projetos/hub/OrdoMount/ordo/config/sync-excludes.conf` | Files to skip |
| Daemon | `systemctl --user status ordo-sync.service` | Background sync service |

## NOT Related

- `obsidian-polish` - Does NOT touch files unless explicitly called
- Git - Vault is not a git repo
- Obsidian Sync - Not used (using OrdoMount instead)

## Next Steps

1. [ ] Check bisync state files for stale entries
2. [ ] Add `.trash/**` to sync-excludes.conf
3. [ ] Test deletion after exclusion configured
4. [ ] Consider increasing sync interval (100s is aggressive)
5. [ ] Document proper file deletion workflow

## Temporary Workaround

Until fixed, delete files this way:

```bash
# 1. Stop sync daemon
systemctl --user stop ordo-sync.service

# 2. Delete file
rm "/path/to/file.md"

# 3. Delete from remote too
rclone delete "onedrive-f6388:Documents/path/to/file.md"

# 4. Restart daemon
systemctl --user start ordo-sync.service
```

---

**Cross-reference:** This issue is documented here for context when working on:
- OrdoMount improvements
- obsidian-polish tool (NOT the cause, but related workflow)
