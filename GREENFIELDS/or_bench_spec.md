# BUILD SPEC: or-bench

**Status**: Spec complete. Awaiting implementation.
**Estimated time**: 2-3 hours
**Model**: ytobs architecture (V4.0) + reddit-obsidian patterns

---

## What Is It?

A CLI tool that benchmarks OpenRouter free models and recommends the best one for your task. Merges two existing scripts into one pip-installable package.

**Source scripts**:
- `or-bench` (598 lines, Python) — fetches free models, benchmarks them in parallel, ranks by TPS
- `or-model-select` (410 lines, Python) — reads cache, scores models by task type, outputs shell vars

**Target**: `~/projetos/hub/or-bench/` (pip-installable Python package)

**Key optimization**: Both scripts duplicate code (PARAM_OVERRIDES, parse_params, cache helpers, params_str). Merge into shared modules.

---

## Target Architecture

```
hub/or-bench/
├── pyproject.toml              # Package metadata + deps + entry point
├── LICENSE                     # MIT
├── README.md                   # User docs
├── CONTEXT.md                  # Project context
├── HELP.md                     # Extended command reference
│
├── or_bench/                   # Package directory
│   ├── __init__.py             # __version__ = "0.1.0"
│   ├── cli.py                  # Entry point with argparse subcommands
│   ├── config.py               # Config management (~/.or-bench/config.yml)
│   ├── models.py               # PARAM_OVERRIDES, parse_params() (shared)
│   ├── cache.py                # Cache management (deduped from both scripts)
│   ├── benchmark.py            # Fetch free models + benchmark (from or-bench)
│   ├── selector.py             # Model scoring + recommendation (from or-model-select)
│   ├── display.py              # Colored output, table formatting, JSON output
│   └── exceptions.py           # Custom exceptions
│
├── docs/                       # Documentation
├── requirements.txt            # Runtime deps
└── .gitignore
```

---

## pyproject.toml Specification

```toml
[build-system]
requires = ["setuptools>=68.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "or-bench"
version = "0.1.0"
description = "OpenRouter free model benchmark, discovery, and selection"
readme = "README.md"
license = {file = "LICENSE"}
requires-python = ">=3.10"
authors = [
    {name = "Fábio Lopes"}
]
keywords = ["openrouter", "benchmark", "ai", "llm", "model-selection"]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Environment :: Console",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=9.0",
    "mypy>=1.19",
]

[project.scripts]
or-bench = "or_bench.cli:main"
```

**Rationale**: Zero external dependencies. Uses only stdlib (json, urllib, argparse, concurrent.futures, pathlib).

---

## Module Specifications

### 1. or_bench/exceptions.py

```python
class OrBenchError(Exception): ...
class APIError(OrBenchError): ...
class CacheError(OrBenchError): ...
class ConfigError(OrBenchError): ...
```

### 2. or_bench/config.py

Config at `~/.or-bench/config.yml`. Minimal — mostly defaults.

```yaml
cache_dir: ~/.cache/or-bench
default_workers: 8
default_timeout: 30
```

### 3. or_bench/models.py

**Deduped** from both scripts. Shared across benchmark.py and selector.py.

```python
PARAM_OVERRIDES = {
    "stepfun/step-3.5-flash":           (196,  11),
    "arcee-ai/trinity-large-preview":   (400,  13),
    "arcee-ai/trinity-mini":            (26,    3),
    "upstage/solar-pro-3":              (102,  12),
    "z-ai/glm-4.5-air":                (0,     0),
    "qwen/qwen3-coder":                (480,  35),
    "deepseek/deepseek-r1-0528":       (671,  37),
}

def parse_params(slug: str) -> tuple[float | None, float | None]: ...
def color_tps(tps: float) -> str: ...  # green ≥60, cyan ≥25, yellow ≥10, red <10
```

### 4. or_bench/cache.py

**Deduped** from both scripts.

```python
DEFAULT_CACHE_DIR = Path.home() / ".cache" / "or-bench"

class CacheManager:
    def __init__(self, cache_dir: Path = DEFAULT_CACHE_DIR): ...
    def save(self, data: dict) -> Path: ...  # timestamped JSON
    def get_latest(self) -> Path | None: ...
    def get_all(self) -> list[Path]: ...
    def get_age_hours(self, path: Path) -> float: ...
    def load(self, path: Path) -> dict: ...

def get_api_key() -> str | None: ...  # check env, then ~/.config/fabric/.env
```

### 5. or_bench/display.py

**Deduped** from both scripts. All output formatting.

```python
# Colors
def green(t): ...; def red(t): ...; def yellow(t): ...; def cyan(t): ...
def bold(t): ...; def dim(t): ...; def status(msg): ...; def ok(msg): ...

# Tables
def print_list(models: list) -> None: ...  # --list output
def print_results(models, results, top_n) -> None: ...  # benchmark output
def print_candidates(scored, profile) -> None: ...  # selector output
def print_history(cache_dir, model_filter) -> None: ...  # history output

# JSON
def print_json_results(models, results) -> None: ...
def print_json_selection(best, cache_info) -> None: ...
```

### 6. or_bench/benchmark.py

Core benchmarking logic from `or-bench`. Uses models.py and cache.py.

```python
BENCH_PROMPT = "Explain what a reverse proxy is in exactly 3 sentences."
BENCH_MAX_TOKENS = 150
FRONTEND_API = "https://openrouter.ai/api/frontend/models"
COMPLETIONS_API = "https://openrouter.ai/api/v1/chat/completions"

def fetch_free_models(args) -> list[dict]: ...
def benchmark_model(model, api_key, timeout) -> dict: ...
def run_benchmark(models, api_key, workers, timeout) -> list[dict]: ...
```

**Filters applied during fetch**: free, text, chat completions, not disabled, no dupes.
**CLI filters**: --min-context, --min-params, --no-training, --exclude-provider.

### 7. or_bench/selector.py

Model scoring from `or-model-select`. Uses models.py and cache.py.

```python
FALLBACK_MODEL = "stepfun/step-3.5-flash:free"
FALLBACK_VENDOR = "OpenRouter"

TASK_PROFILES = {
    "fast":     {"tps_weight": 1.0, "params_weight": 0.1, "ctx_weight": 0.0, "min_params": 7,  "prefer_no_training": False},
    "general":  {"tps_weight": 0.5, "params_weight": 0.5, "ctx_weight": 0.2, "min_params": 7,  "prefer_no_training": False},
    "analysis": {"tps_weight": 0.3, "params_weight": 1.0, "ctx_weight": 0.4, "min_params": 10, "prefer_no_training": True},
    "creative": {"tps_weight": 0.4, "params_weight": 0.8, "ctx_weight": 0.5, "min_params": 10, "prefer_no_training": True},
    "coding":   {"tps_weight": 0.4, "params_weight": 1.0, "ctx_weight": 0.3, "min_params": 14, "prefer_no_training": True},
}

def build_candidates(data, args, profile) -> list[dict]: ...
def score_candidates(candidates, profile) -> list[dict]: ...
def select_best(data, args, profile) -> dict | None: ...
def emit_shell(model_slug, vendor="OpenRouter") -> str: ...
```

### 8. or_bench/cli.py

Main entry point. Merges both scripts' CLIs into subcommands.

```
or-bench bench                         # Full benchmark (was: or-bench)
or-bench bench --workers 16 --timeout 45
or-bench list                          # List free models (was: or-bench --list)
or-bench list --json
or-bench select                        # Pick best model (was: or-model-select)
or-bench select --for coding --show
or-bench select --for fast --model-only
or-bench history                       # Show history (was: or-bench --history)
or-bench history [MODEL_FILTER]
or-bench last                          # Show last cached result (was: or-bench --last)
or-bench stats                         # Cache statistics (new)
or-bench --version                     # Show version
```

**Subcommands**:
- `bench` — run benchmark. Args: --list, --json, --top N, --workers N, --timeout N, --cache-dir, --last, --if-stale N, --no-cache, --min-context N, --min-params N, --no-training, --exclude-provider NAME
- `list` — just list models. Args: --json, --min-context N, --min-params N, --no-training, --exclude-provider NAME
- `select` — pick best model from cache. Args: --for TASK, --show, --json, --model-only, --min-params N, --min-context N, --no-training, --exclude-provider NAME, --max-age N, --cache-dir
- `history` — show history. Args: MODEL_FILTER (optional positional), --cache-dir
- `last` — show last cached result. Args: --json, --top N, --cache-dir
- `stats` — cache statistics: number of runs, age of newest/oldest, total models benchmarked. Args: --cache-dir

---

## Implementation Order (8 items)

```
PHASE 1: Scaffold
[ ] 1. Create ~/projetos/hub/or-bench/ with pyproject.toml, .gitignore, LICENSE
[ ] 2. Create or_bench/ package dir with __init__.py

PHASE 2: Core Modules
[ ] 3. Implement exceptions.py, config.py, models.py, cache.py
[ ] 4. Implement display.py (all formatting, tables, colors)
[ ] 5. Implement benchmark.py (fetch + benchmark)
[ ] 6. Implement selector.py (scoring + recommendation)

PHASE 3: CLI & Integration
[ ] 7. Implement cli.py with all subcommands (bench, list, select, history, last, stats)

PHASE 4: Packaging & Docs
[ ] 8. Write README.md, CONTEXT.md, HELP.md + pip install -e . + verify all commands
```

---

## What NOT To Do

- Don't add external dependencies — use stdlib only (urllib, json, concurrent.futures, argparse, pathlib)
- Don't use pydantic — use dataclasses
- Don't use requests/httpx — urllib is sufficient and already works
- Don't change the benchmark prompt or scoring weights — match existing scripts exactly
- Don't change the OpenRouter API endpoints or auth flow
- Don't use setup.py (pyproject.toml only)

---

## References

- Source scripts: `~/projetos/hub/.myscripts/or-bench` (598 lines) + `or-model-select` (410 lines)
- Model package: `~/projetos/hub/ytobs/` (V4.0 architecture)
- OpenRouter API: `https://openrouter.ai/api/frontend/models` + `https://openrouter.ai/api/v1/chat/completions`
