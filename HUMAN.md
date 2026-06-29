# HUMAN.md — Open Decisions for the Human

**Created**: 2026-06-29
**Context**: Stabilization review of the `.myscripts → hub/` reorganization campaign (session `ses_185473a13ffe02gDMwSS6rpoda`).
**Companion file**: `MASTER_TODO.md` (single source of truth for task state) — read its "⚠️ CAMPAIGN STATE" header first.

---

## Why this file exists

The campaign built everything well (extractions E1–E6, greenfields G1–G3 — all on disk, high quality). But it left behind **governance gaps** that require a human decision, not an agent action. This file lists each open question with the context you need to decide. An agent should **not** execute any of these without your explicit call — they involve preference, risk tolerance, or future-direction choices only you can make.

The agent's job in this session was to **document** these accurately so the campaign sits in a stable, healthy, known state. That's done. What remains here is yours.

---

## ✅ Decisions — resolved 2026-06-29

All 5 decisions captured. Phase 4 (S1–S6) unblocked for execution.

| # | Decision | Resolution |
|---|----------|------------|
| **D4** | Commit `.myscripts/` working tree | **Snapshot now, deletions later.** One commit capturing current state (incl. greenfield sources + junk dirs), then S3/S4 deletions as a follow-up commit. Protects 12 days of work before any destructive action. |
| **D1** | Version `hub/` projects | **Per-project repos, Python only (4):** `ytobs`, `reddit-obsidian`, `obsidian-polish`, `or-bench`. The 5 shell/config projects (`fabric-graph-agents`, `circuit-extractor`, `fabric-image-analysis`, `jumpserver-deploy`, `portable-tmux`) remain **unversioned** — logged in Obsidian vault for future attention. |
| **D2** | Greenfield source scripts | **Delete all 5** (`obsidian-polish`, `obsidian-polish-v3`, `or-bench`, `or-model-select`, `reddit_to_markdown.sh`, 2,237 lines). After S1 snapshot. |
| **D3** | Junk dirs | **Delete `.mysscripts/` + `dockerfiles/`.** Inspect `temp-sorry-…` contents (30 entries) before deleting — relocate anything precious. |
| **D5** | Stale doc references (C4/S6) | **Defer** — low severity, paths still resolve on disk. S6 skipped. |

---

## Decision 1 — Version control the `hub/` projects (S2)

**The situation**: 9 projects live in `~/projetos/hub/`, extracted/built during the campaign. **None have git.** `hub/` itself is not a repo. Meanwhile the entire campaign also sits **uncommitted** in `.myscripts/`'s working tree (last commit `70aebd0`, pre-campaign).

**Your stated direction**: "Ultimately a mix — per-project git repos, but we haven't dug into each of the 9 yet. The human needs to come in and do that work."

**The 9 projects** (build state verified on disk 2026-06-29):

| Project | Type | Package | Modules | Notes |
|---------|------|---------|---------|-------|
| `hub/ytobs/` | Python | ✅ pyproject | (lib → ytobs pkg) | Mature, 76 cached videos |
| `hub/reddit-obsidian/` | Python | ✅ pyproject | 9 .py | HTML scraping (G1) |
| `hub/obsidian-polish/` | Python | ✅ pyproject | 9 .py | (G2) |
| `hub/or-bench/` | Python | ✅ pyproject | 9 .py | (G3), live test pending |
| `hub/fabric-graph-agents/` | Shell | — | 89 files | |
| `hub/circuit-extractor/` | Shell | — | 14 files | |
| `hub/fabric-image-analysis/` | Shell | — | 9 files | |
| `hub/jumpserver-deploy/` | Docker/shell | — | 16 files | |
| `hub/portable-tmux/` | Config | — | 21 files | |

**What to decide per project**:
- [ ] `git init` it as its own repo? (recommended for the 4 Python packages — they're real standalone apps)
- [ ] Initial commit message / scope?
- [ ] License file already present? (Python pkgs have MIT LICENSE; check the 5 shell ones)

**⚠️ Before any `git init`/`git add`**: each Python project has loose build artifacts that must NOT be committed. All 4 already have a `.gitignore` — verify it covers:
- `venv/` (present in all 4)
- `*.egg-info/` (present in reddit-obsidian, obsidian-polish, or-bench)
- `__pycache__/` (53–88 dirs per project)

**Also decide**: does `hub/` get a top-level meta-repo, or stays as a plain directory of independent repos? (You indicated per-project repos — confirm.)

---

## Decision 2 — Greenfield source scripts: delete or retain? (S3)

Unlike extractions E1–E6 (which **deleted** their sources from `.myscripts/`), the greenfield builds G1–G3 **left the original scripts behind**. They still sit in `.myscripts/`:

| Script | Lines | Superseded by | Recommend |
|--------|-------|---------------|-----------|
| `obsidian-polish` | 905 | `hub/obsidian-polish/` (G2, 9 modules) | Delete (logic migrated) |
| `obsidian-polish-v3` | 204 | merged into G2 | Delete (prototype) |
| `or-bench` | 598 | `hub/or-bench/` (G3) | Delete (logic migrated) |
| `or-model-select` | 410 | merged into G3 | Delete (logic migrated) |
| `reddit_to_markdown.sh` | 120 | `hub/reddit-obsidian/` (G1) | Delete (logic migrated) |
| **total** | **2,237** | | |

**To decide**:
- [ ] Delete all 5 (matches E1–E6 policy — single source of truth lives in `hub/`)
- [ ] Or retain any as reference (e.g., keep `reddit_to_markdown.sh` as a quick standalone?)
- [ ] If deleting: back them up to an `archive/` first, or trust git history of `.myscripts/`? (Note: `.myscripts/` itself is uncommitted — see Decision 1.)

---

## Decision 3 — Junk cleanup (S4)

| Path | What | Recommend |
|------|------|-----------|
| `hub/.mysscripts/` | **Typo dir** (note double-s). Contains empty `fabric-graph-agents/`. Created during E2 extraction (2026-05-30). | Delete |
| `hub/temp-sorry-deleleme-or-put-contents-in-projetos-hub-folder/` | Old junk. Contains `mlx-examples/`. Dated Oct 2025. | Delete (or relocate `mlx-examples` if wanted) |
| `.myscripts/dockerfiles/` | **Empty** after jumpserver was extracted (E5). | Delete |

---

## Decision 4 — Commit the `.myscripts/` working tree (S1)

**Critical**: the entire campaign (all extractions, deletions, greenfield specs, doc updates) is **uncommitted**. Last commit `70aebd0` is from *before* the campaign.

**To decide**:
- [ ] Commit as one snapshot ("campaign complete: E1–E6, G1–G3, C1–C3")?
- [ ] Or split into logical commits (extractions / greenfields / cleanup / docs)?
- [ ] Commit *before* or *after* Decisions 2–3 (source deletion + junk)? Recommend: commit the current state **first** (safe snapshot), then do deletions as a follow-up commit.

This protects 12 days of work regardless of the other decisions.

---

## Decision 5 — Stale doc references (C4 / S6)

**31 files** in `.myscripts/docs/` still reference `~/.myscripts/` paths that now point to extracted projects in `hub/`. Low-severity (paths still resolve on disk), but noisy.

**To decide**:
- [ ] Bulk find/replace now (mechanical, low-risk)?
- [ ] Or defer until each doc is touched naturally?
- [ ] Or move project-specific docs into their `hub/<project>/` and shrink `docs/` overall?

---

## Once you've decided

These 5 decisions unblock **Phase 4 (S1–S6)** in `MASTER_TODO.md`. After that:
- S5 (smoke-verify all packages) can be delegated to parallel subagents — that's safe agent work.
- The campaign is then in a truly "done" state: built, committed, versioned, verified, cleaned.

When ready to execute Phase 4, tell the agent:
> Load `~/projetos/hub/.myscripts/MASTER_TODO.md` and `HUMAN.md`. Execute Phase 4 items per my decisions.

---

## Reference — campaign at a glance

- **Built**: 6 extractions (E1–E6) + 3 greenfields (G1–G3) = 9 projects in `hub/`
- **Build quality**: spot-checked good (proper `pyproject.toml`, module splits, docs, LICENSE, `.gitignore`)
- **Task completion**: 66/71 (93%) of P1–P3
- **Remaining P1–P3**: G3.7 (or-bench live test, needs API key), G4–G6 (deferred low-priority), C4 (stale refs)
- **Phase 4 (new)**: 6 stabilization tasks, all deferred to human (this file)
