# SSH REFERENCE CONTEXT

The following is the complete OpenSSH ssh(1) man page plus a curated set of real-world usage patterns. Use this as your ground truth when answering.

---

## MAN PAGE: ssh(1) — OpenSSH remote login client

### SYNOPSIS
```
ssh [-46AaCfGgKkMNnqsTtVvXxYy] [-B bind_interface] [-b bind_address]
    [-c cipher_spec] [-D [bind_address:]port] [-E log_file]
    [-e escape_char] [-F configfile] [-I pkcs11] [-i identity_file]
    [-J destination] [-L address] [-l login_name] [-m mac_spec]
    [-O ctl_cmd] [-o option] [-P tag] [-p port] [-R address]
    [-S ctl_path] [-W host:port] [-w local_tun[:remote_tun]] destination
    [command [argument ...]]
ssh [-Q query_option]
```

### ALL FLAGS

| Flag | Meaning |
|------|---------|
| `-4` | Force IPv4 only |
| `-6` | Force IPv6 only |
| `-A` | Enable agent forwarding (use with caution — prefer -J instead) |
| `-a` | Disable agent forwarding |
| `-B bind_interface` | Bind to this interface before connecting (multi-homed hosts) |
| `-b bind_address` | Use this local address as source |
| `-C` | Enable compression (gzip). Useful on slow links, hurts on fast ones |
| `-c cipher_spec` | Comma-separated cipher list in preference order |
| `-D [addr:]port` | Dynamic (SOCKS4/5) port forwarding — ssh acts as SOCKS server |
| `-E log_file` | Append debug logs to file instead of stderr |
| `-e escape_char` | Set escape character (default `~`). `none` = fully transparent session |
| `-F configfile` | Use alternate config file (ignores /etc/ssh/ssh_config) |
| `-f` | Background before command execution (implies -n) |
| `-G` | Print effective config after evaluating Host/Match blocks, then exit |
| `-g` | Allow remote hosts to connect to local forwarded ports |
| `-I pkcs11` | Use PKCS#11 library for keys (disables UseKeychain) |
| `-i identity_file` | Private key file for pubkey auth. Can use multiple -i flags |
| `-J destination` | Jump host(s), comma-separated. Shortcut for ProxyJump |
| `-K` | Enable GSSAPI auth + credential forwarding |
| `-k` | Disable GSSAPI credential forwarding |
| `-L [addr:]port:host:hostport` | Local port forward: local port → remote host:port |
| `-L [addr:]port:remote_socket` | Local port → remote Unix socket |
| `-L local_socket:host:hostport` | Local Unix socket → remote host:port |
| `-l login_name` | Remote username (same as user@host) |
| `-M` | Master mode for multiplexing. `-MM` requires confirmation per operation |
| `-m mac_spec` | Comma-separated MAC algorithm list |
| `-N` | No remote command — useful for pure port forwarding |
| `-n` | Redirect stdin from /dev/null (required when backgrounding) |
| `-O ctl_cmd` | Control multiplexing master: check, forward, cancel, proxy, exit, stop |
| `-o option` | Pass any ssh_config option inline, e.g. `-o StrictHostKeyChecking=no` |
| `-P tag` | Select config tag (see Tag/Match in ssh_config) |
| `-p port` | Remote port to connect to |
| `-Q query_option` | Query supported algorithms: cipher, mac, kex, key, sig, etc. |
| `-q` | Quiet mode — suppress most warnings/diagnostics |
| `-R [addr:]port:host:hostport` | Remote port forward: remote port → local host:port |
| `-R [addr:]port` | Remote dynamic SOCKS forward (no explicit destination) |
| `-S ctl_path` | Control socket path for multiplexing, or "none" to disable |
| `-s` | Request subsystem invocation (e.g., sftp) |
| `-T` | Disable pseudo-terminal allocation |
| `-t` | Force pseudo-terminal allocation (use `-tt` if ssh has no local tty) |
| `-V` | Print version and exit |
| `-v` | Verbose/debug output. Up to `-vvv` for max verbosity |
| `-W host:port` | Forward stdio to host:port (implies -N -T, used for ProxyCommand) |
| `-w local_tun[:remote_tun]` | Tunnel device forwarding (VPN via tun). Use "any" for next available |
| `-X` | Enable X11 forwarding (restricted by SECURITY extension) |
| `-x` | Disable X11 forwarding |
| `-Y` | Enable trusted X11 forwarding (no SECURITY restrictions) |
| `-y` | Send log output via syslog instead of stderr |

### AUTHENTICATION METHODS (tried in this order by default)
1. GSSAPI
2. Host-based
3. Public key
4. Keyboard-interactive
5. Password

Override order with `PreferredAuthentications` in ssh_config.

### KEY FILES (defaults)
- Private: `~/.ssh/id_rsa`, `~/.ssh/id_ecdsa`, `~/.ssh/id_ecdsa_sk`, `~/.ssh/id_ed25519`, `~/.ssh/id_ed25519_sk`
- Public: same with `.pub`
- Authorized keys on server: `~/.ssh/authorized_keys`
- Known hosts: `~/.ssh/known_hosts`, `/etc/ssh/ssh_known_hosts`

### ESCAPE SEQUENCES (default escape char: `~`, must follow newline)
| Sequence | Action |
|----------|--------|
| `~.` | Disconnect (kill hung session) |
| `~^Z` | Background ssh |
| `~#` | List forwarded connections |
| `~&` | Background ssh at logout (wait for forwarded sessions) |
| `~?` | Show escape character help |
| `~B` | Send BREAK to remote |
| `~C` | Open command line (add -L/-R/-D forwardings live) |
| `~R` | Request rekey |
| `~V` / `~v` | Decrease / increase verbosity |

### ENVIRONMENT VARIABLES
- `DISPLAY` — X11 server location (set by ssh, don't override)
- `SSH_AUTH_SOCK` — Unix socket for agent communication
- `SSH_CONNECTION` — client IP, client port, server IP, server port
- `SSH_TTY` — path to tty for current session
- `SSH_ASKPASS` / `SSH_ASKPASS_REQUIRE` — passphrase UI control (never/prefer/force)
- `SSH_ORIGINAL_COMMAND` — original command when forced command is in effect

### FILE PERMISSIONS THAT MATTER
```
~/.ssh/              → 700
~/.ssh/config        → 600 (must not be world-writable)
~/.ssh/id_*          → 600 (ssh ignores keys accessible by others)
~/.ssh/authorized_keys → 600
~/.ssh/known_hosts   → 644 or 600
```

---

## REAL-WORLD PATTERNS

### Basic login
```bash
ssh user@host
ssh -p 2222 user@host
ssh -i ~/.ssh/mykey user@host
```

### Run a command without a shell session
```bash
ssh user@host 'df -h'
ssh user@host 'tar czf - /var/data' > backup.tar.gz
```

### Local port forward (-L) — access remote service locally
```bash
# Access remote Postgres (5432) as localhost:5433
ssh -L 5433:localhost:5432 user@host -N

# Access a host behind the SSH server (not localhost on server)
ssh -L 8080:internal-host:80 user@jumphost -N
```

### Remote port forward (-R) — expose local service on remote
```bash
# Expose local port 3000 as port 9000 on the remote server
ssh -R 9000:localhost:3000 user@host -N

# Dynamic remote SOCKS (remote machine gets SOCKS proxy to your local network)
ssh -R 1080 user@host -N
```

### Dynamic SOCKS proxy (-D) — proxy your browser through the server
```bash
ssh -D 1080 user@host -N -q
# Then set browser SOCKS5 proxy to 127.0.0.1:1080
```

### Jump hosts (-J)
```bash
# Single jump
ssh -J user@jumphost user@target

# Multi-hop
ssh -J user@jump1,user@jump2 user@target

# In ~/.ssh/config:
Host target
  ProxyJump jumphost
  User deploy
```

### ~/.ssh/config — the real power
```
Host myserver
  HostName 203.0.113.10
  User deploy
  IdentityFile ~/.ssh/deploy_key
  Port 2222

Host bastion
  HostName bastion.example.com
  User ec2-user
  ForwardAgent no

Host internal-*
  ProxyJump bastion
  User deploy
  IdentityFile ~/.ssh/internal_key

Host *
  ServerAliveInterval 60
  ServerAliveCountMax 3
  AddKeysToAgent yes
  UseKeychain yes          # macOS only — stores passphrase in Keychain
```

### Connection multiplexing — reuse connections
```bash
# In ~/.ssh/config:
Host myserver
  ControlMaster auto
  ControlPath ~/.ssh/cm-%r@%h:%p
  ControlPersist 10m

# Check if master is running
ssh -O check myserver

# Open new session on existing connection (instant, no re-auth)
ssh myserver
```

### Key generation — best practices
```bash
# Ed25519 — preferred (fast, small, secure)
ssh-keygen -t ed25519 -C "user@machine-$(date +%Y)"

# RSA — for legacy compatibility, use 4096-bit minimum
ssh-keygen -t rsa -b 4096 -C "user@machine"

# Copy public key to server
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@host
# or manually:
cat ~/.ssh/id_ed25519.pub | ssh user@host 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
```

### Debug a failing connection
```bash
ssh -vvv user@host          # Max verbosity
ssh -G user@host            # See what config is actually being applied
ssh -o StrictHostKeyChecking=no user@host   # Skip host key check (testing only, never prod)
```

### Kill a hung session
```
~.
```
(Press Enter first if needed, then `~` then `.`)

### SSH agent
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add -l               # List loaded keys
ssh-add -D               # Remove all keys from agent
```

### Secure copy with scp / sftp
```bash
scp -P 2222 file.txt user@host:/remote/path/
scp -r user@host:/remote/dir/ ./local/
sftp user@host
```

### Check server host key fingerprint
```bash
ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub
ssh-keygen -lv -f ~/.ssh/known_hosts   # Visual (random art) for all known hosts
```

### Background tunnel that stays up
```bash
ssh -f -N -L 5432:localhost:5432 user@host
# -f = background, -N = no command, tunnel stays open
```

---

## INPUT FORMAT

The user will ask questions about SSH — flags, config, troubleshooting, use cases, security. Answer directly from this context. Quote flags and config directives exactly. Provide working command examples. Flag security risks when relevant.
