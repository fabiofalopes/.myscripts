# 🧩 gen_unique_strings.sh

### Overview

`gen_unique_strings.sh` is a **Bash-based random string generator** that creates **unique, non-repeating, mixed-case identifiers** similar to:

```
IaGeOMyy
qTnApVdL
RoFtLmYs
```

Each string is composed of **uppercase and lowercase ASCII letters (A–Z, a–z)** with a configurable length (default: 8).

---

### 🔧 Features

* Generates **unique** random strings across runs.
* Stores all generated strings in `generated_strings.txt`.
* Automatically **trims** the file to keep only the most recent entries (`MAX_LINES`, default: 100000).
* **Safe for concurrent use** — uses file locking to prevent data corruption.
* Lightweight and self-contained (pure Bash, no dependencies).
* Configurable behavior through environment variables.

---

### 🧠 Technical Description

| Parameter    | Default                  | Description                                              |
| ------------ | ------------------------ | -------------------------------------------------------- |
| `STORE_FILE` | `generated_strings.txt`  | Persistent file for unique strings                       |
| `LOCK_FILE`  | `generated_strings.lock` | Lock file for safe concurrent access                     |
| `LENGTH`     | `8`                      | Number of characters per string                          |
| `MAX_LINES`  | `100000`                 | Maximum lines stored before truncation                   |
| `SLEEP`      | `0.2`                    | Delay (seconds) between each generation in infinite mode |
| `VERBOSE`    | `1`                      | Whether to print each new string (`1`=yes, `0`=silent)   |

---

### ⚙️ Usage

#### Run indefinitely:

```bash
chmod +x gen_unique_strings.sh
./gen_unique_strings.sh
```

#### Generate a fixed number of strings:

```bash
./gen_unique_strings.sh 10
```

#### Customize behavior:

```bash
LENGTH=10 MAX_LINES=50000 SLEEP=0.1 ./gen_unique_strings.sh
```

---

### 📁 Output Example

Generated strings are stored line-by-line in `generated_strings.txt`:

```
IaGeOMyy
kTnPhRaW
QwLmErTf
oZaPxDqL
```

---

### 💾 Storage Notes

* Each line ≈ 9 bytes (8 chars + newline).
* File growth is capped by `MAX_LINES`.

  * Example: 100,000 strings ≈ 900 KB.
* Older entries are automatically rotated out.

---

### 🧩 String Pattern

Each generated string:

* Uses **only letters [A–Z, a–z]**
* Has **no digits or symbols**
* Length = configurable (`LENGTH`)
* Randomly mixed upper/lowercase (example: `IaGeOMyy`)
* Statistically unique over long runs (collisions auto-resolved)

---

### 🔒 Concurrency & Safety

* Uses `flock`-based file locking (`LOCK_FILE`) to ensure atomic writes.
* Safe to run multiple instances simultaneously — no duplicates or corruption.

---

### 🛠 Requirements

* **Bash 4.0+**
* Standard GNU utilities (`tr`, `head`, `grep`, `tail`, `wc`, `flock`, `mv`, `bc`)

---

