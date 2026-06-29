# Stabilization Ops Runbook — `.myscripts → hub/` Campaign

**File**: `prompt_2026-06-29_0157_stabilization-ops.md`
**Created**: 2026-06-29 01:57 WEST
**Authoring session**: consulting review of `ses_185473a13ffe02gDMwSS6rpoda`
**Purpose**: The forward execution plan for Phase 4 (Stabilization & Hardening). Human-in-the-loop: agent executes the safe work, pauses at every decision gate.

---

## How to use this file

This is a **runbook**, not a status report. A future agent session (or the human) loads it to execute Phase 4 step by step. It is designed to be resumable — if interrupted at any step, the "Resume protocol" at the bottom tells you how to pick up.

**Load order for any executing session:**
1. `MASTER_TODO.md` (read the "⚠️ CAMPAIGN STATE" header — single source of truth)
2. `HUMAN.md` (the 5 open decisions)
3. This file (the execution sequence)

**Golden rule**: every step tagged `🛑 HUMAN GATE` requires an explicit human "go" before the agent acts. Steps tagged `🤖 AGENT-SAFE` can be executed/delegated without further permission. Do not blur the line.

---

## Context snapshot (where we are)

The extraction + greenfield campaign is **functionally complete**: 6 extractions (E1–E6) and 3 greenfields (G1–G3) are built and on disk in `hub/`. Build quality verified good (proper packaging, module splits, docs). **66/71 tasks done (93% of P1–P3).**

What's unfinished is **governance**, not engineering. Three gaps remain:

| Gap | Status |
|-----|--------|
| Campaign uncommitted; `hub/` unversioned (0/9 git) | 🔴 unresolved — highest risk |
| Greenfield source scripts not deleted (2,237 lines) | 🟠 unresolved |
| Tracker drift | ✅ resolved (2026-06-29 reconciliation pass) |

These map to **Phase 4 tasks S1–S6** in `MASTER_TODO.md`.

---

## Guiding principles (do not violate)

1. **Narrowed scope.** `.myscripts/` is the focused repo going forward. The 9 `hub/` projects are extracted/external. Do **not** start new extraction or greenfield work without explicit user direction.
2. **No direction-chasing.** Execute Phase 4 only. Resist scope creep ("while I'm here, let me also…"). The prior campaign's drift came from chasing too many directions.
3. **Human-in-the-loop.** The `hub/` per-project git setup, source deletions, and commit granularity are **human decisions** (the user stated this explicitly). Agent proposes; human disposes.
4. **Commit before you change.** The working tree is currently the only record of 12 days of work. Snapshot it **before** any destructive action (deletions).
5. **Verify, don't assume.** Every package gets a smoke test (S5). No task is "done" until verified against its success criteria.

---

## The two lanes

| Lane | Owner | Tasks | Can agent start without human? |
|------|-------|-------|-------------------------------|
| **Decisions** | 🛑 Human | S1-strategy, S2-strategy, S3, S4-confirm | ❌ No — wait for explicit go |
| **Execution** | 🤖 Agent (may delegate to subagents) | S1-commit, S2-gitinit, S5-verify, S6-docfix | ✅ Yes, once the upstream decision is made |

The workflow is **decision → execute → verify → next**. Never execute a gated task before its decision is recorded.

---

## Execution waves

### Wave 0 — Human decisions (blocking; do first)

Open `HUMAN.md`. The human makes 5 calls. The agent's job here is only to **present options and answer questions** — not to decide. Capture each decision inline (a checklist the human ticks).

- [ ] **D1** — `hub/` versioning strategy (per-project repos confirmed? any project excluded?)
- [ ] **D2** — greenfield source scripts: delete all 5 / retain some / archive first?
- [ ] **D3** — junk dirs (`.mysscripts/`, `temp-sorry-…`, empty `dockerfiles/`): delete confirmed?
- [ ] **D4** — `.myscripts/` commit granularity (one snapshot vs split commits)? **Commit before or after deletions?**
- [ ] **D5** — C4 stale doc refs: bulk-fix now / defer / restructure docs?

> 🛑 **GATE**: Do not proceed to Wave 1 until D4 is decided. D4 is the safety snapshot.

### Wave 1 — Commit & version (after D1, D4)

**S1 — Commit the `.myscripts/` working tree** 🤖 (executes D4)
- *Prereq*: D4 decided.
- *Action*: stage + commit per the human's chosen granularity. Recommended: one snapshot commit first ("campaign: E1–E6, G1–G3, C1–C3 complete"), then deletions as a follow-up.
- *Verify*: `git log --oneline -3` shows the new commit; `git status` clean.
- *Resume*: if commit fails (hooks), fix and re-commit — do not amend a failed commit.

**S2 — Version the `hub/` projects** 🛑+🤖 (executes D1)
- *Prereq*: D1 decided (per-project repos).
- *Action per project*: `git init`, verify `.gitignore` covers `venv/`, `*.egg-info/`, `__pycache__/` (all 4 Python projects already have a `.gitignore` — confirm it lists these), `git add .`, initial commit.
- *Verify*: each `hub/<project>/` has `.git/`; `git -C hub/<project> status` clean.
- *Scope*: 9 projects (4 Python + 5 shell/config). Can fan out to subagents — one per project, or batched.
- *⚠️ Build-artifact warning*: before `git add`, each Python project has loose `venv/`, `*.egg-info/`, 50–88 `__pycache__/` dirs. The `.gitignore` must exclude them or they get committed.

### Wave 2 — Cleanup (after D2, D3; after S1 committed)

> Ordering rule: **S1 (commit) must complete before S3/S4.** Deletions happen on a committed baseline so they're recoverable.

**S3 — Greenfield source scripts** 🛑+🤖 (executes D2)
- *Prereq*: D2 decided; S1 committed.
- *Action*: delete (or archive then delete) the confirmed scripts: `obsidian-polish`, `obsidian-polish-v3`, `or-bench`, `or-model-select`, `reddit_to_markdown.sh`.
- *Verify*: `ls` confirms gone; logic confirmed present in the corresponding `hub/` package.
- *Commit*: as a separate "cleanup: remove superseded greenfield sources" commit.

**S4 — Junk dirs** 🤖 (executes D3)
- *Prereq*: D3 confirmed.
- *Action*: remove `hub/.mysscripts/` (typo), `hub/temp-sorry-deleleme-…/`, `.myscripts/dockerfiles/` (empty).
- *Verify*: `ls hub/.mysscripts` → not found; etc.

### Wave 3 — Verify & fix (agent-safe; parallelize)

**S5 — Smoke-verify all packages** 🤖 (pure verification — ideal subagent fan-out)
- *Prereq*: S2 done (projects versioned).
- *Action*: for each of the 4 Python packages — `import` test + `--help` + `--version`; for the 5 shell/config projects — structure check + README present + executable bit.
- *Fan-out*: one subagent per project (9 parallel), category `quick` or `deep`. Each returns pass/fail + any defect.
- *Verify*: all 9 green; defects logged and triaged.
- *Note*: G3.7 (or-bench live test) needs an API key — skip unless provided; original logic is proven.

**S6 — Fix C4 stale doc refs** 🤖 (executes D5)
- *Prereq*: D5 decided (bulk-fix now).
- *Action*: bulk find/replace `~/.myscripts/` → correct `hub/<project>/` paths across the 31 files in `.myscripts/docs/`. Map each stale path to its extraction destination (see `MYSCRIPTS_AUDIT_AND_EXTRACTION_PLAN.md` for the source→dest map).
- *Verify*: `grep -rl '\.myscripts/' docs/` returns 0 (or only intentionally-valid refs).
- *Caution*: some refs may be legitimately current (patterns that still live in `.myscripts/fabric-custom-patterns/`). Don't blanket-replace — verify each target.

---

## Subagent fan-out plan (for the 🤖 agent-safe work)

When executing S2/S5/S6, delegate rather than serialize:

| Task | Delegation | Count | Category |
|------|-----------|-------|----------|
| S2 git-init per project | one agent per project | up to 9 | `quick` |
| S5 verify per project | one agent per project | 9 parallel | `quick` |
| S6 doc-ref fix | one agent (or split by doc-cluster) | 1–3 | `unspecified-low` |

**Delegation prompt requirements** (for each): goal + success criteria + file paths + the build-artifact gitignore warning + "do not touch other projects." Use `session_id` to continue if a subagent needs a follow-up.

---

## Definition of done (Phase 4 complete when ALL true)

- [ ] `.myscripts/` working tree committed (S1)
- [ ] All 9 `hub/` projects have `.git` with clean initial commits, no build artifacts tracked (S2)
- [ ] Greenfield source scripts handled per D2 (S3)
- [ ] Junk dirs removed (S4)
- [ ] All 9 packages smoke-verified green (S5)
- [ ] `docs/` stale refs resolved per D5 (S6)
- [ ] `MASTER_TODO.md` Phase 4 tasks S1–S6 all marked ✅
- [ ] `HUMAN.md` decisions all ticked off

At that point the campaign is in a truly **done** state: built, committed, versioned, verified, cleaned.

---

## Resume protocol (if interrupted)

1. Re-read `MASTER_TODO.md` § "⚠️ CAMPAIGN STATE" + this file's "Execution waves."
2. Find the first unchecked item in the wave sequence.
3. Check its prereqs are met (e.g., don't run S3 before S1 committed).
4. If a 🛑 HUMAN GATE is next and no decision recorded → **stop and ask the human.** Do not guess.
5. If resuming mid-🤖 task → use the prior subagent's `session_id` to continue with full context.

The state is fully captured in files (`MASTER_TODO.md`, `HUMAN.md`, this runbook). Nothing critical lives only in session context. An interruption costs nothing but time.

---

## What is explicitly OUT of scope for Phase 4

- G4 (tokcount), G5 (slugfile), G6 (mfab Python rewrite) — deferred, work fine as scripts.
- G3.7 or-bench live test — needs API key.
- New extractions or greenfields — none started without user direction.
- Restructuring `.myscripts/` itself — the narrowed scope says leave the incubator layout as-is.

---

*Authored as the closing artifact of the consulting session. Pairs with `MASTER_TODO.md` (truth) and `HUMAN.md` (decisions).*
