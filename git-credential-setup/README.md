# Git Credential Helper Setup

**Problem:** Git keeps asking for credentials every time you push/pull.

**Root Cause:** No credential helper configured to save your credentials.

---

## Current System Status

**OS:** Linux  
**Git Version:** 2.47.3  
**Remote URL:** `https://github.com/fabiofalopes/.myscripts.git`  
**Current Config:** ❌ No credential helper set

---

## Quick Diagnosis

Check if you have a credential helper configured:

```bash
git config --global credential.helper
```

If this returns **nothing**, you have no credential helper (the problem).

---

## Solution Options

### Option 1: Store (Plain-text File) ⚡ **EASIEST**

**Pros:**
- Simple one-command setup
- Persistent (credentials saved forever)
- Works immediately

**Cons:**
- Credentials stored in plain text in `~/.git-credentials`
- Anyone with access to your machine can read them
- Requires good machine security (encrypted disk, locked screen, etc.)

**Setup:**

```bash
# Enable store credential helper
git config --global credential.helper store

# Next time you do a git operation (push/pull), enter credentials ONCE:
# Username: fabiofalopes
# Password: <your-github-classic-token>

# Credentials are now saved in ~/.git-credentials
```

**Managing Credentials:**

```bash
# View stored credentials
cat ~/.git-credentials

# Remove specific credential (edit file)
nano ~/.git-credentials

# Remove all credentials
rm ~/.git-credentials

# Disable credential helper
git config --global --unset credential.helper
```

**Security Note:** Only use this if you have:
- Encrypted disk
- Strong user password
- Auto-lock screen when idle
- Physical security of your machine

---

### Option 2: Libsecret (GNOME Keyring Integration) 🔒 **MOST SECURE**

**Pros:**
- Credentials stored in OS keyring (encrypted)
- Same security as your system password manager
- Persistent across reboots
- Fits your existing workflow

**Cons:**
- Requires compiling from source (~5-10 min setup)
- Needs development libraries installed
- Slightly more complex

**Setup:**

```bash
# 1. Install build dependencies
sudo apt install libsecret-1-0 libsecret-1-dev build-essential

# 2. Navigate to source directory
cd /usr/share/doc/git/contrib/credential/libsecret

# 3. Compile the credential helper
sudo make

# 4. Configure git to use it
git config --global credential.helper /usr/lib/git-core/git-credential-libsecret

# 5. Test with a git operation (push/pull)
# Enter credentials ONCE - they're stored in GNOME Keyring

# 6. Verify it's working
git config --global credential.helper
# Should output: /usr/lib/git-core/git-credential-libsecret
```

**Managing Credentials:**

```bash
# View/manage credentials in GNOME Keyring GUI
seahorse

# Or use command line
secret-tool search protocol https

# Clear specific credential
secret-tool clear protocol https host github.com

# Disable credential helper
git config --global --unset credential.helper
```

**Why This is Better:**
- Your credentials are encrypted with your login password
- Same security as browser saved passwords
- No plain-text files
- If someone steals `~/.git-credentials` with `store` option, they have your token
- If they steal your machine with `libsecret`, they still need your login password

---

### Option 3: Cache (In-Memory Temporary) ⏱️ **MOST SECURE BUT TEMPORARY**

**Pros:**
- Never written to disk
- Most secure
- Auto-expires after timeout

**Cons:**
- Need to re-enter credentials after timeout (default 15 min)
- Lost on reboot

**Setup:**

```bash
# Cache for 24 hours (86400 seconds)
git config --global credential.helper 'cache --timeout=86400'

# Or 7 days (604800 seconds)
git config --global credential.helper 'cache --timeout=604800'

# After timeout, you need to enter credentials again
```

**Managing Credentials:**

```bash
# Clear cache immediately
git credential-cache exit

# Check if cache is running
ps aux | grep git-credential-cache

# Disable
git config --global --unset credential.helper
```

---

### Option 4: SSH Keys 🔑 **BEST LONG-TERM**

**Pros:**
- Most secure authentication method
- No tokens to manage/expire
- Works across all git operations
- Industry standard

**Cons:**
- Need to generate SSH keys
- Need to add public key to GitHub
- Need to change remote URLs from HTTPS to SSH
- Different workflow initially

**Setup:**

```bash
# 1. Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "fabiofalopes@gmail.com"
# Press Enter for default location (~/.ssh/id_ed25519)
# Enter passphrase (optional but recommended)

# 2. Start ssh-agent
eval "$(ssh-agent -s)"

# 3. Add key to agent
ssh-add ~/.ssh/id_ed25519

# 4. Copy public key
cat ~/.ssh/id_ed25519.pub
# Copy the output

# 5. Add to GitHub
# - Go to https://github.com/settings/keys
# - Click "New SSH key"
# - Paste the public key
# - Give it a title (e.g., "Linux Desktop")

# 6. Change your remote URLs from HTTPS to SSH
git remote set-url origin git@github.com:fabiofalopes/.myscripts.git

# 7. Test SSH connection
ssh -T git@github.com
# Should see: "Hi fabiofalopes! You've successfully authenticated..."

# 8. Now git push/pull work without passwords
```

**Managing SSH Keys:**

```bash
# List your SSH keys
ls -la ~/.ssh

# Test GitHub connection
ssh -T git@github.com

# Change remote back to HTTPS (if needed)
git remote set-url origin https://github.com/fabiofalopes/.myscripts.git

# Add passphrase to existing key
ssh-keygen -p -f ~/.ssh/id_ed25519
```

**Why SSH is Better Long-Term:**
- No tokens to expire
- More secure than Personal Access Tokens
- One setup, works forever
- Standard in professional environments

---

## Comparison Table

| Feature | Store | Libsecret | Cache | SSH |
|---------|-------|-----------|-------|-----|
| **Setup Time** | 10 sec | 5-10 min | 10 sec | 2-5 min |
| **Security** | ⚠️ Low (plain-text) | 🔒 High (encrypted) | 🔒 High (memory) | 🔒 Very High |
| **Persistence** | ✅ Forever | ✅ Forever | ⏱️ Timeout | ✅ Forever |
| **Complexity** | Simple | Medium | Simple | Medium |
| **Survives Reboot** | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |
| **Best For** | Personal secured machine | Daily driver secure | Shared/public machines | Professional use |

---

## Recommendations

### Quick Fix (Now)
Use **Store** if:
- You need it working in 10 seconds
- Your machine is physically secure
- You have disk encryption
- You're the only user

### Better Security (5-10 min)
Use **Libsecret** if:
- You want proper security without changing workflow
- You're on GNOME/Linux desktop with keyring
- You want encrypted credential storage
- You don't want to switch to SSH yet

### Best Practice (2-5 min)
Use **SSH Keys** if:
- You want to do it right
- You don't mind a small learning curve
- You want maximum security
- You're tired of managing tokens

---

## My Recommendation for You

Based on your description:

1. **Right now:** Use `store` to stop the immediate pain
2. **This weekend:** Set up `libsecret` (5 min) for better security
3. **Eventually:** Migrate to SSH keys for best practice

Why this progression:
- `store` fixes your problem NOW (literally 1 command)
- `libsecret` gives you security without changing your workflow
- SSH is the "right way" but can wait until you're ready

---

## Troubleshooting

### Still Asking for Password After Setup

```bash
# Check what's configured
git config --global credential.helper

# Check if credential file exists (for store)
ls -la ~/.git-credentials

# Check if cache is running (for cache)
ps aux | grep git-credential-cache

# Test credential helper directly
echo "protocol=https
host=github.com
" | git credential fill
```

### Token Expired

```bash
# For store: Edit the file
nano ~/.git-credentials
# Change the token after the : in the github.com line

# For libsecret: Clear and re-enter
secret-tool clear protocol https host github.com
# Next git operation will ask for new token

# For cache: Just wait for timeout or force clear
git credential-cache exit
```

### Wrong Username/Token Saved

```bash
# For store: Edit or delete
nano ~/.git-credentials
# or
rm ~/.git-credentials

# For libsecret:
secret-tool clear protocol https host github.com

# For cache:
git credential-cache exit

# Then do a git operation and enter correct credentials
```

### Check What's Actually Configured

```bash
# Global config
git config --global --list | grep credential

# All configs (global, system, local)
git config --list | grep credential

# Credential helper location
git config --global credential.helper
```

---

## Current GitHub Token Info

**Token Type:** Classic Personal Access Token  
**Location:** https://github.com/settings/tokens  
**Username for Git:** `fabiofalopes`  
**Password for Git:** Your classic token (starts with `ghp_...`)

When Git asks for credentials:
- **Username:** `fabiofalopes` (or just press Enter if pre-filled)
- **Password:** Your classic token (NOT your GitHub password)

---

## Further Reading

- [Git Credential Storage Official Docs](https://git-scm.com/docs/gitcredentials)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- [GitHub SSH Setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

---

## Quick Reference Commands

```bash
# Set store helper
git config --global credential.helper store

# Set libsecret helper (after compiling)
git config --global credential.helper /usr/lib/git-core/git-credential-libsecret

# Set cache helper (24 hours)
git config --global credential.helper 'cache --timeout=86400'

# Check current helper
git config --global credential.helper

# Remove credential helper
git config --global --unset credential.helper

# View stored credentials (store only)
cat ~/.git-credentials

# Clear cache (cache only)
git credential-cache exit

# Clear libsecret credentials
secret-tool clear protocol https host github.com

# Test SSH connection
ssh -T git@github.com

# Change remote to SSH
git remote set-url origin git@github.com:fabiofalopes/.myscripts.git

# Change remote to HTTPS
git remote set-url origin https://github.com/fabiofalopes/.myscripts.git
```

---

**Last Updated:** 2025-12-30  
**Your System:** Linux, Git 2.47.3, HTTPS remote
