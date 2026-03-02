# OpenRouter Model Management — Master Plan

**Project**: Data-driven model selection and monitoring for OpenRouter free models  
**Status**: Phase 2 complete (or-bench with caching/history/filters), Phase 3 planning  
**Created**: 2026-02-24  
**Updated**: 2026-02-24  
**Repo**: `.myscripts/`  
**Key Tool**: `or-bench` (Python, stdlib-only, on PATH)

---

## Problem Statement

All fabric-based tools (`txrefine`, `obsidian-polish`, `mfab`, future scripts) rely on OpenRouter free models. The free model landscape is:

- **Volatile**: ~30 free models at any time, ~half are 429'd at any given moment
- **Shifting**: Models appear and disappear without notice
- **Undocumented for speed**: OpenRouter provides no latency/throughput metrics
- **Rate-limited unevenly**: Venice-hosted = 8 rpm, StepFun = 50, NVIDIA = 50, many = unlimited
- **Variable in capability**: A "480B" MoE model activates only 35B; a 1.2B model is fast but useless

Currently: `fabric-ai` defaults to `stepfun/step-3.5-flash:free`. No fallback, no intelligence, no monitoring. If that model goes down, everything breaks silently.

Previously: A `model-pool.sh` / `model-pool.conf` system was built and wired into `txrefine` but failed — it hardcoded models that were frequently 429'd, with no health checking. It was reverted.

---

## Vision

A multi-phase system that grows from benchmarking tool into intelligent model routing:

```
Phase 1: Know what's fast right now            → or-bench (DONE)
Phase 2: Cache results, track over time         → or-bench + history
Phase 3: Data-Driven Model Selection  → or-model-select (DONE)
Phase 4: Smart Routing                → or-router (maybe)
Phase 5: Standalone service                     → own repo (maybe)
```

The guiding principle: **don't hardcode what you can measure. Don't guess what you can benchmark.**

---

## Current State

### What Exists

| File | Status | Description |
|------|--------|-------------|
| `or-bench` | Working | Python CLI. Queries frontend API, benchmarks all free models in parallel, ranked color table. 375 lines, stdlib only. |
| `model-pool.sh` | Unwired, stale | Bash library. `pick_model()`, `fabric_model_flags_array()`. Bash 3.2 compatible. **Needs rename or deletion.** |
| `~/.config/myscripts/model-pool.conf` | Unwired, stale | Pool config with 4 pools (FAST/ANALYSIS/CREATIVE/GENERAL). Contains models that frequently 429. **Needs cleanup.** |
| `txrefine` | Working | Fixed. Uses fabric defaults only. No model override. 178 lines. |

### What `or-bench` Can Do Today

```bash
or-bench              # Full benchmark (query API + call each model)
or-bench --list       # Just list free models from API (no calls)
or-bench --json       # Output results as JSON (pipeable)
or-bench --top 5      # Top N results only
or-bench --workers 12 # Parallel workers
or-bench --timeout 20 # Per-model timeout
```

### What `or-bench` Cannot Do Yet

- No caching (every run re-benchmarks everything)
- No history (results vanish after display)
- No quality/intelligence assessment (only speed)
- No minimum-capability filtering (1.2B models rank high but are useless)
- No context window validation (256k on paper != 256k in practice)
- No periodic/scheduled mode
- No machine-readable persistent output (--json goes to stdout but isn't saved)

---

## API Landscape

### Two APIs Exist

**Public API** — `GET https://openrouter.ai/api/v1/models`
- No auth required
- 337 models, basic metadata
- Fields: pricing, context_length, architecture, supported_parameters
- Free models: `pricing.prompt == "0" AND pricing.completion == "0"`

**Frontend API** — `GET https://openrouter.ai/api/frontend/models` (what or-bench uses)
- No auth required
- 627 entries (models x providers — one entry per model-provider pair)
- Much richer data per endpoint:

| Field | Type | Notes |
|-------|------|-------|
| `is_free` | bool | Direct filter |
| `is_disabled` / `is_deranked` | bool | Health indicators |
| `limit_rpm` / `limit_rpd` | int/null | Rate limits (null = unlimited) |
| `provider_display_name` | string | Who hosts it (Venice, NVIDIA, Google AI Studio, etc.) |
| `context_length` | int | Claimed context window |
| `max_completion_tokens` | int | Max output length |
| `quantization` | string | fp4, fp8, fp16, bf16, int8, unknown |
| `has_chat_completions` | bool | Capability flag |
| `supports_tool_parameters` | bool | Function calling support |
| `supports_reasoning` | bool | Reasoning/thinking support |
| `supports_multipart` | bool | Multimodal input |
| `data_policy` | object | `{training: bool, retainsPrompts: bool, retentionDays: int}` |
| `hf_slug` | string | HuggingFace model link (most models have this) |
| `adapter_name` | string | How OpenRouter connects (OpenAIAdapter, VeniceAdapter, etc.) |
| `provider_model_id` | string | Actual model ID at the provider |
| `deprecation_date` | string/null | When endpoint expires |
| `features` | object | Detailed feature support (tool_choice, reasoning mechanisms) |

**What's NOT in any API:**
- No latency/throughput/TPS metrics — must benchmark ourselves
- No historical availability/uptime data
- No aggregate model health statistics
- The generation stats endpoint (`/api/v1/generation?id=<id>`) only returns per-request stats after a call, not aggregates

### External Speed Data Sources

- **lmspeed.net** — Crowd-sourced OpenRouter speed tests (187 tests, 21 models as of 2026-02-23). Data sparse and stale.
- **artificialanalysis.ai** — Broader model comparison. Not OpenRouter-specific.
- Neither is programmatically usable as a reliable data source.

---

## Benchmark Results (2026-02-23)

Last `or-bench` run, 26 models tested:

### Succeeded (14 models)

| # | Model | Active Params | TPS | TTFB | Provider | RPM | Ctx | Notes |
|---|-------|--------------|-----|------|----------|-----|-----|-------|
| 1 | liquid/lfm-2.5-1.2b-instruct | 1.2B | 344 | 1701ms | Liquid | -- | 32k | Too small for real tasks |
| 2 | liquid/lfm-2.5-1.2b-thinking | 1.2B | 322 | 956ms | Liquid | -- | 32k | Too small, thinking model |
| 3 | arcee-ai/trinity-mini | 3B active (26B total) | 199 | 1148ms | Arcee AI | -- | 131k | Mandatory reasoning traces |
| 4 | nvidia/nemotron-3-nano-30b-a3b | 3B active (30B total) | 178 | 1508ms | NVIDIA | -- | 256k | Data used for training |
| 5 | openai/gpt-oss-20b | 3.6B active (21B total) | 130 | 983ms | OpenInference | -- | 131k | Mandatory reasoning, data for training |
| 6 | **stepfun/step-3.5-flash** | 11B active (196B total) | 110 | 1617ms | StepFun | 50 | 256k | **Current fabric default** |
| 7 | upstage/solar-pro-3 | 12B active (102B total) | 100 | 2844ms | Upstage | -- | 128k | Korean-optimized |
| 8 | nvidia/nemotron-nano-12b-v2-vl | 12B | 88 | 1462ms | NVIDIA | -- | 128k | Vision model |
| 9 | google/gemma-3n-e4b-it | 4B | 87 | 723ms | Google AI Studio | -- | 8k | Tiny context, data retained 55 days |
| 10 | meta-llama/llama-3.3-70b-instruct | 70B | 49 | 806ms | OpenInference | -- | 128k | Largest non-MoE, data for training |
| 11 | z-ai/glm-4.5-air | MoE (unknown) | 32 | 5581ms | Z.ai | -- | 131k | Very slow TTFB |
| 12 | openai/gpt-oss-120b | 5.1B active (117B total) | 18 | 1061ms | OpenInference | -- | 131k | Mandatory reasoning, int8 |
| 13 | arcee-ai/trinity-large-preview | 13B active (400B total) | 16 | 984ms | Arcee (Modal) | 10 | 131k | Huge model, creative/agentic |
| 14 | google/gemma-3-4b-it | 4B | 0 | 1123ms | Google AI Studio | -- | 32k | Returned 0 tokens |

### Failed — 429'd (12 models)

qwen3-next-80b, qwen3-coder, dolphin-mistral-24b, gemma-3n-e2b, mistral-small-3.1-24b, qwen3-4b, gemma-3-12b, llama-3.2-3b, gemma-3-27b, hermes-3-405b, deepseek-r1-0528, nemotron-nano-9b-v2

### Key Patterns

- Almost every modern free model is **MoE** — total params != active params
- Venice-hosted models (8 rpm) almost always 429
- Google AI Studio models frequently 429
- Models with **mandatory reasoning** (gpt-oss-*, trinity-*, deepseek-r1) always produce reasoning traces, inflating token counts
- **Data policy matters**: NVIDIA/OpenInference train on your data. Venice/Arcee/Liquid/StepFun do not.
- `hf_slug` field links to HuggingFace for most models — can fetch model cards, architecture, exact param counts

### Usability Tiers (subjective, based on benchmark + descriptions)

| Tier | Models | Rationale |
|------|--------|-----------|
| **Production-grade** | step-3.5-flash, llama-3.3-70b | Fast enough, large enough, reliable |
| **Promising** | nemotron-3-nano-30b, gpt-oss-20b, solar-pro-3 | Good speed, decent size, but training data concerns or niche optimization |
| **Niche/Experimental** | trinity-large-preview, gpt-oss-120b, nemotron-nano-12b-v2-vl | Interesting capabilities (creative, vision) but slow or rate-limited |
| **Too small** | lfm-2.5-1.2b-*, gemma-3n-e4b, gemma-3-4b | Fast but insufficient reasoning/instruction following |
| **Unreliable** | All 429'd models | May work sometimes, can't depend on them |

---

## Development Phases

### Phase 1: Benchmark & Discovery -- DONE

- [x] Query OpenRouter API for free models
- [x] Benchmark all free text models in parallel
- [x] Measure TTFB and TPS per model
- [x] Color-coded ranked table output
- [x] --list, --json, --top, --workers, --timeout flags
- [x] API key from env or fabric config
- [x] Pipe-compatible (status to stderr, data to stdout)

**Deliverable**: `or-bench` (375 lines, Python, stdlib only)

---

### Phase 2: Persistence & History -- DONE

**Goal**: Benchmark results survive beyond a single run. Track model availability and performance over time.

- [x] **JSON result caching**
  - Save each benchmark run to `~/.cache/or-bench/YYYY-MM-DD_HHMMSS.json`
  - `or-bench --last` shows most recent cached result without re-running
  - `or-bench --cache-dir` to customize location
  - `or-bench --no-cache` to disable caching

- [x] **History mode**
  - `or-bench --history` shows performance over time for all models
  - `or-bench --history model-slug` filters to specific model
  - Reads all cached JSON files and aggregates availability/TPS

- [x] **Staleness awareness**
  - `or-bench --if-stale N` only benchmarks if last run is older than N hours
  - Useful for cron: `0 */6 * * * or-bench --if-stale 5 --json > /dev/null`

- [x] **Minimum capability filters**
  - `or-bench --min-context N` exclude models with <Nk context
  - `or-bench --exclude-provider NAME` exclude specific provider
  - `or-bench --no-training` exclude models that train on data (uses data_policy.training)

- [x] **Param size parsing**
  - `parse_params(slug)` extracts (total_B, active_B) from model slug name via regex
  - `PARAM_OVERRIDES` dict covers 7 models whose slugs don't encode param counts
  - Params column in `--list` and benchmark output (format: `3B/30B` for MoE, `70B` for dense, `?` if unknown)
  - Sorted by active params in `--list`
  - `or-bench --min-params N` filters models below N active-B (e.g. `--min-params 7`)

**Deliverable**: `or-bench` (592 lines, Python, stdlib only)

---

### Phase 3: Data-Driven Model Selection — DONE

**Goal**: Replace the dead `model-pool.sh` system with one backed by real benchmark data.

- [x] **or-model-select CLI**
  - Reads most recent `or-bench` cache from `~/.cache/or-bench/`
  - Task profiles: `fast`, `analysis`, `creative`, `coding`, `general`
  - Ranking: weighted score of TPS, active params, context window + privacy bonus
  - Filters: `--min-params N`, `--min-context N`, `--no-training`, `--exclude-provider`
  - Output modes: shell-eval (`export FABRIC_MODEL=... FABRIC_VENDOR=...`), `--model-only`, `--json`, `--show` (ranked table)
  - Fallback: if no cache / stale / no models pass filters → emits fabric default silently
  - Standalone (no import of or-bench — PARAM_OVERRIDES inlined)

- [x] **Integration into txrefine** (opt-in via env vars)
  - `OR_MODEL_SELECT=1` enables dynamic selection
  - `OR_MODEL_TASK=analysis|fast|creative|coding|general` picks task profile
  - `OR_MODEL_NO_TRAINING=1` adds `--no-training` filter
  - `OR_MODEL_MIN_PARAMS=N` sets minimum active params
  - Falls back silently to fabric defaults if selection fails

**Deliverables**:
- `or-model-select` (190 lines, Python, stdlib only)
- txrefine opt-in integration (24-line block, zero breaking changes)

**Validation**:
- `eval $(or-model-select)` → emits correct shell exports
- `OR_MODEL_SELECT=1 OR_MODEL_NO_TRAINING=1 txrefine` → picks `stepfun/step-3.5-flash:free`
- `or-model-select --show --for analysis --no-training` → ranked table, top = deepseek-r1-0528
- Fallback tested: `--max-age 1` on 4h-old cache → emits fabric default

---

### Phase 4: Smart Routing (Future, Maybe)

**Goal**: A local proxy that adds intelligence between your tools and OpenRouter.

This is speculative. Only pursue if Phase 3 proves model selection needs to be real-time (per-request) rather than periodic (per-benchmark-run).

- [ ] Local HTTP proxy on localhost:PORT
- [ ] Intercepts OpenRouter API calls
- [ ] Adds automatic fallback (if model returns 429, try next best)
- [ ] Rate-limit awareness (track remaining RPM per model)
- [ ] Request logging and analytics
- [ ] Could be Python (Flask/FastAPI) or Go

**Open questions**:
- Is per-request routing actually needed, or is periodic benchmarking enough?
- How do fabric scripts interact with a proxy? (Change base URL? Env var?)
- Should this be in `.myscripts` or its own repo?

---

### Phase 5: Standalone Service (Future, Maybe)

**Goal**: If this grows beyond personal CLI tools, extract into deployable service.

Not planning this now. Just noting the possibility. Triggers:
- Multiple machines need the same model intelligence
- Other people want to use it
- The proxy from Phase 4 needs persistence/database

---

## Technical Decisions

### Language: Python (stdlib only) for or-bench

**Rationale**: Complex enough to need real data structures (JSON parsing, threading, HTTP), but must stay zero-dependency for PATH tools. Python stdlib has everything needed: `urllib`, `concurrent.futures`, `json`, `argparse`.

**Rule**: No pip dependencies. If we need something pip-only, it becomes a separate project.

### Shell integration via eval/env vars

**Rationale**: Fabric scripts are bash. The bridge between Python benchmarking and bash model selection is:
```bash
# In a fabric script:
eval $(or-model-select --for analysis)
$FABRIC_CMD -V "$FABRIC_VENDOR" -m "$FABRIC_MODEL" -p my-pattern
```

### Cache location: `~/.cache/or-bench/`

**Rationale**: XDG convention. Not in the repo (benchmark results are machine-specific). Config in `~/.config/or-bench/` if needed later.

### Naming: `or-bench`, `or-model-select`

**Rationale**: `or-` prefix = OpenRouter. Specific, not generic. You read the name and know what it's about.

---

## Cleanup Required

### model-pool.sh — DELETED (2026-02-24)

Removed in cleanup. The hardcoded pool approach was wrong.

### model-pool.conf — DELETED (2026-02-24)

Removed in cleanup. Will be replaced by cache-backed selection in Phase 3.

---

## Open Questions

1. **Quality benchmarking**: How do you measure "is this model smart enough" without a full eval suite? Ideas:
   - Short instruction-following test (give format, check compliance)
   - Known-answer factual question
   - Simple code generation test
   - Or: just filter by active param count as proxy for capability

2. **Context window validation**: Models claim 256k but may degrade or fail at large inputs. How to test?
   - Send progressively larger prompts until failure
   - Expensive (uses tokens), slow — maybe a separate `or-bench --test-context` mode

3. **Cron vs. on-demand**: Should benchmarks run on a schedule, or only when a tool needs fresh data?
   - Cron is simpler (crontab one-liner), but wastes API calls when you're not working
   - On-demand with staleness check (`--if-stale`) is more efficient
   - **Leaning toward**: `--if-stale` for individual use, cron for when it matters more

4. **HuggingFace API integration**: Most models have `hf_slug`. Could programmatically fetch:
   - Exact parameter counts (active + total for MoE)
   - Architecture details
   - Model card (training data, limitations)
   - Worth exploring in Phase 2 or 3

5. **Provider health tracking**: Frontend API has `is_disabled` and `is_deranked` flags. Could poll periodically to track which providers are healthy without benchmarking. Cheap (no API key needed, no completions calls).

---

## File Map

```
.myscripts/
  or-bench                              # Phase 1-2: benchmark tool with caching (DONE, ~560 lines)
  or-model-select                               # Phase 3: model selection for scripts (DONE, ~190 lines)
  txrefine                              # Consumer — uses fabric defaults (FIXED)
  obsidian-polish                       # Consumer — future Phase 3 integration
  mfab                                  # Consumer — future Phase 3 integration
  docs/plans/
    OPENROUTER_MODEL_MANAGEMENT_MASTERPLAN.md  # This file

~/.cache/or-bench/                      # Phase 2: benchmark history (LIVE)
  2026-02-24_HHMMSS.json
  ...

~/.config/myscripts/                    # Empty (model-pool.conf deleted)
```

---

## Development Log

### Session 1 (2026-02-22): txrefine fix + or-bench creation

- Diagnosed txrefine failures: model-pool integration was forcing 429'd free models
- Reverted model-pool wiring from txrefine (removed sourcing + flag calls)
- Verified txrefine works end-to-end with fabric defaults
- Built `or-bench` from scratch: API query, parallel benchmarking, ranked output
- Benchmarked 26 free models (14 succeeded, 12 got 429'd)
- Full audit of both OpenRouter APIs (public + frontend)
- Mapped all fields available in frontend API
- Researched lmspeed.net and artificialanalysis.ai for external data
- Captured user's multi-phase vision

### Session 2 (2026-02-24): Masterplan

- Reviewed all existing state on disk
- Wrote this masterplan document
- Persisted all research, benchmarks, API findings, and decisions to disk

### Session 3 (2026-02-24): Phase 2 Implementation + Cleanup

- Fixed obsidian pattern symlinks (`obsidian_note_title`, `obsidian_frontmatter_gen`)
- Deleted `model-pool.sh` and `model-pool.conf` (already gone from disk)
- Implemented Phase 2 of or-bench:
  - JSON caching to `~/.cache/or-bench/YYYY-MM-DD_HHMMSS.json`
  - `--last` flag to show most recent cached result
  - `--if-stale N` for conditional benchmarking
  - `--history [model]` to show performance over time
  - `--min-context N` filter (exclude <Nk context models)
  - `--exclude-provider NAME` filter
  - `--no-training` filter (uses data_policy.training from API)
  - `--no-cache` to disable caching
- Updated masterplan to reflect Phase 2 completion

### Session 4 (2026-02-24): Param size support + bug fixes

- Added `PARAM_OVERRIDES` dict with 7 models that can't be parsed from slug
- Added `parse_params(slug)` regex to extract total/active params from slug name
- Added `params_total` / `params_active` to model objects in `fetch_free_models`
- Added `_params_str()` display helper (MoE: `3B/30B`, dense: `70B`, unknown: `?`)
- Updated `print_list()` with Params column, sorted by active params desc
- Updated `print_results()` header and rows with Params column
- Added `--min-params N` argparse arg (filter models below N active-B)
- Fixed missing `--min-params` in argparse (was causing AttributeError on every run)
- Verified: `or-bench --list` shows all 26 models with correct param labels

### Session 5 (2026-02-24): Phase 3 — or-model-select + txrefine integration

- Built `or-model-select` (190 lines, Python, stdlib only):
  - 5 task profiles (fast/analysis/creative/coding/general) with tuned scoring weights
  - Reads or-bench cache, merges model metadata + results, scores + ranks
  - Inline PARAM_OVERRIDES (standalone, no import of or-bench)
  - Shell-eval output (`export FABRIC_MODEL=... FABRIC_VENDOR=...`)
  - `--model-only`, `--json`, `--show` output modes
  - Graceful fallback to fabric default on missing/stale cache or no-passing filters
- Added opt-in model selection block to txrefine (env vars: `OR_MODEL_SELECT`, `OR_MODEL_TASK`, `OR_MODEL_NO_TRAINING`, `OR_MODEL_MIN_PARAMS`)
- Tested all task profiles, filters, fallback, and shell integration
- Updated masterplan Phase 3 to DONE

### Next Session: Phase 3 extensions or Phase 4

Priority order:
1. Design `or-model-select` CLI interface
2. Implement model recommendation logic (`--recommend fast/analysis/creative`)
3. Create shell-friendly output format for fabric scripts
4. Integrate into `txrefine` (opt-in via env var or flag)

---

**Last Updated**: 2026-02-24 (Session 5)  
**Next Review**: After Phase 3 completion
