# Shell Enhancement Vision

## The Goal: Kali Linux Shell Experience

When you use Kali Linux and open a terminal, everything just *works*:
- Commands autocomplete as you type
- Invalid commands show red, valid ones green
- History suggestions appear inline (grey text after cursor)
- Tab completion has colors, groups, arrow-key navigation
- It's fast, visual, and prevents errors before you hit Enter

**This project brings that experience to macOS and Debian.**

---

## What Makes Kali's Shell Special

Kali's shell experience isn't magic—it's three things:

### 1. zsh-autosuggestions
Fish-like inline suggestions from command history. As you type, it shows (in grey) what you typed before that matches.

```
$ git pu[grey: sh origin main]
       ↑ press → to accept
```

### 2. zsh-syntax-highlighting
Real-time syntax coloring. Valid commands turn green, invalid turn red, strings get quoted colors. You see errors *before* pressing Enter.

```
$ ecoh hello    # red (typo!)
$ echo hello    # green (valid)
$ echo "hello"  # "hello" in yellow
```

### 3. Enhanced Completion Menu
Not just a list—a navigable, colored, grouped menu:
- Arrow keys to move between options
- Colors distinguish files, directories, executables
- Groups organize by type (files, flags, commands)
- Case-insensitive matching

---

## What Kali Does NOT Use

**Kali deliberately avoids heavy frameworks:**
- No oh-my-zsh (too heavy for low-powered devices)
- No prezto, zinit, or similar
- Just native zsh + two small plugins + smart `zstyle` configuration

**However**, if you already have oh-my-zsh (like on macOS), you can add the same plugins to it.

---

## The Technical Recipe

From Kali's official `/etc/skel/.zshrc`:

```bash
# Core completion system
autoload -Uz compinit
compinit

# Menu selection with arrow keys
zstyle ':completion:*:*:*:*:*' menu select

# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Colors in completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Group completions
zstyle ':completion:*' group-name ''
zstyle ':completion:*' format 'Completing %d'

# Auto-rehash (find new commands immediately)
zstyle ':completion:*' rehash true

# Plugins
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

That's it. ~20 lines of config + 2 plugins = Kali experience.

---

## Cross-Platform Strategy

| System | Approach |
|--------|----------|
| **macOS** | Already has Zsh. Add plugins to oh-my-zsh or standalone. |
| **Debian** | Install Zsh + plugins via apt. Or keep Bash and accept the difference. |
| **Kali** | Already configured! Nothing to do. |

### A Note on Bash (Debian)

On Debian, the default shell is Bash. Bash has a different feel—it doesn't have the same plugin ecosystem as Zsh. You can either:

1. **Switch to Zsh on Debian** - Get the full Kali experience
2. **Stay with Bash** - Use what comes out of the box, accept it's different

The pragmatic approach: on Debian work machines, just use what's there. The terminal works, it's fine. If you want the enhanced experience, install Zsh. But it's not mandatory—Bash is Bash, and that's okay.

**TODO (Debian):** When working on the Debian machine, test and develop `setup-debian.sh` to optionally bring the same Zsh experience there. This is a future task to do on that machine directly.

---

## Why This Matters

Every day you type hundreds of commands. Small improvements compound:

- **Autosuggestions**: Save keystrokes, recall forgotten commands
- **Syntax highlighting**: Catch typos before execution
- **Better completion**: Find options you didn't know existed

The Kali team optimized for power users who live in the terminal. So do we.

---

## Success Criteria

After setup, you should be able to:

1. Type `git pu` and see `sh origin main` suggested in grey
2. Press `→` to accept the suggestion
3. See `git push` turn green (valid command)
4. Type `gti push` and see it turn red (invalid)
5. Press `Tab` after `ls -` and navigate colored options with arrows

---

## References

- [Kali 2020.3 Release - Zsh Announcement](https://www.kali.org/blog/kali-linux-2020-3-release/)
- [Kali Default .zshrc](https://gitlab.com/kalilinux/packages/kali-defaults/-/blob/kali/master/etc/skel/.zshrc)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [grml-zsh-config](https://grml.org/zsh/) (alternative comprehensive config)
