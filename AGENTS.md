# .myscripts — Agent Instructions

## Scratchpad Rule (2026 convention)

Use `temp/` for all scratch content — session handoffs, runbooks, session prompts, raw ideas, resume aids. **Don't leave planning docs at repo root.** `temp/` is ignored via `.git/info/exclude` (local-only), so your scratch never pollutes the shared tree. Real documentation belongs in `docs/`; shared agent context stays in `AGENTS.md`.

## Repo Overview

This repo is the **incubator** for personal CLI tools and Fabric AI patterns. Mature projects get extracted to `~/projetos/hub/` as standalone repos.

**Project Status**: Extraction + greenfield campaign **functionally complete** (66/71 tasks, 93% of P1–P3). Builds are on disk and verified. Campaign is now in a **stabilization-required** state (work uncommitted, hub/ unversioned) — see `MASTER_TODO.md` § "⚠️ CAMPAIGN STATE" and `HUMAN.md` for the open human decisions.

> **Scope narrowed (2026-06-29)**: `.myscripts/` is the focused repo going forward. The 9 extracted/built projects in `hub/` are now external to this repo's concerns (their per-project git setup is a human decision, tracked in `HUMAN.md`). Do not start new extraction/greenfield work without explicit user direction.

### What Lives Here (in .myscripts/)
- `mfab` — man-page-aware Fabric REPL (main project, see below)
- `mfab.env` — configuration template for mfab (source of truth)
- `fabric-custom-patterns/` — custom patterns for `fabric-ai`
- `to_note` / `clip.sh` / `concat*` — standalone utilities
- `yta` — audio downloader (yt-dlp wrapper; opus stream-copy = smallest). Quick ref: `docs/yta-quickref.md`
- `wav-to-mp3` — audio conversion utility
- `docs/` — 30+ documentation files (stale `~/.myscripts/` paths cleaned 2026-09-03, S6/C4 done)
- `GREENFIELDS/` — build specs for greenfield projects (now implemented)

### What Was Extracted/Built to hub/ (campaign complete)
**Phase 1 — Extractions (ALL DONE ✅)**
- `hub/ytobs/` — YouTube → Obsidian (from youtube-obsidian/)
- `hub/fabric-graph-agents/` — Fabric orchestration system
- `hub/circuit-extractor/` — OCR/knowledge extraction
- `hub/fabric-image-analysis/` — Image metadata pipeline
- `hub/jumpserver-deploy/` — JumpServer deployment
- `hub/portable-tmux/` — Portable tmux config

**Phase 2 — Greenfields (ALL DONE ✅)**
- `hub/reddit-obsidian/` ✅ — Reddit → Obsidian (G1, HTML scraping via old.reddit.com)
- `hub/obsidian-polish/` ✅ — Obsidian note polish (G2, 9 Python modules)
- `hub/or-bench/` ✅ — OpenRouter benchmark tool (G3, merged or-bench + or-model-select)

**Deferred (low priority)**
- G4 tokcount, G5 slugfile, G6 mfab-Python-rewrite — all work fine as scripts.

### Key Tracking Files
| File | Purpose |
|------|---------|
| `MASTER_TODO.md` | **Single source of truth** — 66/71 tasks done (93%); Phase 4 stabilization deferred to human |
| `HUMAN.md` | Open human decisions (hub/ git, source deletion, junk cleanup) — read before acting on Phase 4 |
| `HANDOFF_INDEX.md` | Thin pointer to per-project handoffs (defers to MASTER_TODO for counts) |
| `MYSCRIPTS_AUDIT_AND_EXTRACTION_PLAN.md` | Full audit of all 77 entries (historical record) |
| `GREENFIELDS/` | Build specs (reddit_obsidian_spec.md, obsidian_polish_spec.md, or_bench_spec.md) |

## mfab — Man-Page Fabric REPL

`mfab` wraps the `fabric-ai` CLI as a persistent, session-aware expert for any Unix/CLI tool.

### Architecture

```
User question
    │
    ▼
man-router pattern (fast model, outputs {"tool":"ssh","confidence":"high"})
    │
    ▼
load_context() — curated .md > man page > --help fallback
    │
    ▼
man-expert pattern + fabric session (--session for history)
    │
    ▼
streamed answer to terminal
    │
    ▼ (on exit)
session-to-note → obsidian_note_polish → $OBSVAULT/mfab/
```

### Key Files

| File | Purpose |
|------|---------|
| `mfab` | Main executable script |
| `mfab.env` | Config template (source of truth — copy to `~/.config/mfab/.env`) |
| `fabric-custom-patterns/man-router/system.md` | JSON router pattern |
| `fabric-custom-patterns/man-expert/system.md` | Agnostic CLI expert persona |
| `fabric-custom-patterns/man-ssh/` | SSH-specific pattern (symlink to man-expert + curated context) |
| `fabric-custom-patterns/man-titler/system.md` | Generates slug filenames from session transcripts |
| `fabric-custom-patterns/session-to-note/system.md` | Converts Q&A transcripts to Obsidian notes |
| `fabric-custom-patterns/ssh/SYSTEM.md` | DO NOT TOUCH — SSHmind persona |
| `fabric-custom-patterns/ssh/USER.md` | DO NOT TOUCH — curated SSH reference |

### Runtime Paths

```
~/.config/mfab/
├── .env                   # live config (created by mfab --setup)
├── man-contexts/          # curated context files (ssh.md, git.md, curl.md, docker.md)
└── archive/               # archived session segments on tool switch or compaction

~/.config/fabric/
├── .env                   # fabric provider API keys — use `fabric-ai --setup` to edit
├── patterns/              # symlinks to fabric-custom-patterns/ subdirs
└── contexts/
    └── mfab-active.md     # written at runtime on each context load
```

### Fabric Binary

- Primary: `fabric-ai` (installed via `brew install fabric-ai`, currently v1.4.415)
- Fallback: `fabric` (if `fabric-ai` not found)
- Script auto-detects with `command -v`

### Critical Rules

- **Always include `-V <vendor>`** on fabric calls. The `fabric-ai` binary requires it for non-default providers.
- **Do not use Groq for `MFAB_MODEL`** — context too small (8K-32K) for man pages. Groq OK for `MFAB_ROUTER` only.
- **Streaming flag is `-s`** (not `--stream`) — `fabric-ai` uses short flag only.
- **`CUSTOM_PATTERNS_DIRECTORY`** is already set in `~/.config/fabric/.env` — patterns are auto-discovered.
- **`$OBSVAULT`** is the vault env var (not `$OBSV`). Script resolves: `MFAB_OBSV > OBSV > OBSVAULT`.

### Connected Providers (as of 2026-02-20)

| Provider | Vendor string | Notes |
|----------|--------------|-------|
| OpenRouter | `"OpenRouter"` | Primary. Many free models. Default. |
| Groq | `"Groq"` | Router only (tiny context). |
| Ollama | `"Ollama"` | Local: deepseek-r1:8b, phi4-mini, gemma3, qwen3-vl:8b |
| GitHub Models | not configured | Free via Copilot PAT — run `fabric-ai --setup` to add |

### Do Not Touch

- `fabric-custom-patterns/ssh/SYSTEM.md` — complete, do not modify
- `fabric-custom-patterns/ssh/USER.md` — complete, do not modify
- `~/.config/fabric/.env` — managed by `fabric-ai --setup`, not by hand
