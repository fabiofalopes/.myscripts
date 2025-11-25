#!/usr/bin/env bash
# gen_unique_strings.sh
# Generates unique mixed-case strings, persists them, and keeps the store file bounded.
# Requires bash >= 4 (for associative arrays).

set -euo pipefail

# Config
STORE_FILE="${STORE_FILE:-generated_strings.txt}"
LOCK_FILE="${LOCK_FILE:-generated_strings.lock}"
LENGTH="${LENGTH:-8}"          # length of each generated string
MAX_LINES="${MAX_LINES:-100000}" # keep only the last MAX_LINES in the store file
SLEEP="${SLEEP:-0.2}"          # pause between generations (seconds)
VERBOSE="${VERBOSE:-1}"        # 1 = print each new string, 0 = silent

# Ensure store file exists
touch "$STORE_FILE"

# Check bash version
if ((BASH_VERSINFO[0] < 4)); then
  echo "This script requires bash >= 4 (for associative arrays)." >&2
  exit 1
fi

declare -A seen

# Load existing values into associative array for O(1) membership checks
# This keeps checks fast even if STORE_FILE has many lines.
while IFS= read -r line; do
  # ignore empty lines
  [[ -z "$line" ]] && continue
  seen["$line"]=1
done < "$STORE_FILE"

# Generate an n-char mixed-case string using /dev/urandom (A-Za-z)
generate_string() {
  local len=$1
  # tr -dc filters to letters; head -c picks the correct count.
  # Loop until we get exactly 'len' chars (rarely tr may drop chars).
  local s
  s=$(tr -dc 'A-Za-z' < /dev/urandom | head -c "$len")
  # fallback if for some reason string shorter
  while [ "${#s}" -lt "$len" ]; do
    s+=$(tr -dc 'A-Za-z' < /dev/urandom | head -c $((len - ${#s})))
  done
  printf '%s' "$s"
}

# Append new unique string to disk under lock and update in-memory set.
append_and_rotate() {
  local value="$1"

  # Acquire exclusive lock on the lock file descriptor (fd 200)
  exec 200>"$LOCK_FILE"
  flock -x 200

  # Double-check file to avoid race: maybe another process added the same string while we were working
  if ! grep -qxF -- "$value" "$STORE_FILE" 2>/dev/null; then
    printf '%s\n' "$value" >> "$STORE_FILE"
  else
    # Already present — release lock and return failure
    flock -u 200
    exec 200>&-
    return 1
  fi

  # Trim file if it's grown beyond MAX_LINES (keep the last MAX_LINES)
  local current_lines
  current_lines=$(wc -l < "$STORE_FILE" | tr -d ' ')
  if [ "$current_lines" -gt "$MAX_LINES" ]; then
    # Use tail to keep last MAX_LINES lines. Write to temp file then move atomically.
    local tmpfile="${STORE_FILE}.tmp"
    tail -n "$MAX_LINES" "$STORE_FILE" > "$tmpfile"
    mv "$tmpfile" "$STORE_FILE"
  fi

  # Release lock
  flock -u 200
  exec 200>&-

  return 0
}

# Generate one unique string; loop until unique found.
generate_unique() {
  local tries=0
  local max_tries=10000
  local cand

  while :; do
    cand=$(generate_string "$LENGTH")
    if [[ -z "${seen[$cand]:-}" ]]; then
      # try to append with lock (other process may have added it concurrently)
      if append_and_rotate "$cand"; then
        # success: record in-memory and print
        seen["$cand"]=1
        if [[ "$VERBOSE" -eq 1 ]]; then
          printf '%s\n' "$cand"
        fi
        return 0
      else
        # append failed because another process added it; mark as seen and retry
        seen["$cand"]=1
      fi
    fi

    tries=$((tries + 1))
    if (( tries >= max_tries )); then
      echo "Too many collisions (tried $tries times). Giving up for now." >&2
      return 1
    fi
  done
}

# Run indefinitely until killed (Ctrl+C)
main_loop() {
  while :; do
    generate_unique || sleep 0.5
    # Sleep a little so the script doesn't spin at 100% CPU
    if (( $(echo "$SLEEP > 0" | bc -l) )); then
      sleep "$SLEEP"
    fi
  done
}

# If script is called with arguments, allow quick one-off generation:
# ./gen_unique_strings.sh 5  -> generate 5 unique strings and exit
if [[ "${1:-}" =~ ^[0-9]+$ ]]; then
  count=$1
  for ((i=0;i<count;i++)); do
    generate_unique || break
  done
  exit 0
fi

# Otherwise run the infinite loop
main_loop

