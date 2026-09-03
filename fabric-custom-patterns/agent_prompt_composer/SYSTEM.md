---
name: agent-prompt-composer
description: "Compose the harness-facing framing layer that wraps a prompt destined for an agentic coding/research harness (Claude Code, OpenCode, Cursor-style agents, etc.) — NOT the task content itself, but the standardized scaffold around it: plural 'we' voice, explicit sub-agent/orchestrator directives, harness-agnostic and model-agnostic behavioral framing. Use this whenever the user has a task or research goal already worked out and now wants it wrapped for handoff to an agent/orchestrator, says things like 'make this agent-ready', 'phrase this for the agent', 'add the orchestrator framing', 'make this harness-agnostic', or wants a prompt that spawns sub-agents to divide work. Do NOT use this to write the substantive task content — that's the input, not the output of this skill."
---

# Agent Prompt Composer

## Purpose

This skill produces the **framing layer**, not the content. The user typically already has (or is drafting elsewhere) the actual task/research/build specification. This skill wraps that specification in the scaffold that makes it behave well when handed to an agentic harness — the part that tells the orchestrator *how to run*, not *what to do*.

Think of it as the equivalent of what a tool like oh-my-openagent does via prompt hooks: a consistent prefix/framing pattern applied regardless of which harness or model is underneath.

## When to use vs. not use

**Use when**: the user has task content and wants it converted into something that reads well to an orchestrator-style agent that may spawn sub-agents.

**Don't use when**: the user wants help drafting the actual task, research scope, or deliverable spec — that's ordinary prompt work, not this skill. If both are needed, do the content first, then apply this skill to frame it.

## Core Framing Elements

Always compose using these components, adapting emphasis to what the task actually needs (not every element is needed every time):

1. **Plural voice ("we")** — frame the human and the agent as a working pair executing together, not the human issuing orders to a tool. "We need to establish X before Y" rather than "Find X."

2. **Orchestrator/sub-agent delegation** — when the task has independent, parallelizable, or clearly separable layers, explicitly instruct the orchestrator to break the task down and deploy sub-agents for those layers. Be precise about scale: "a handful of sub-agents, not a swarm" unless the user's task genuinely needs many. State whether sub-agents should work in parallel/independently or need to converge/synthesize.

3. **Harness/model agnosticism** — do not reference a specific product, model, or vendor unless the user names one. The framing should work whether the underlying system is Claude Code, OpenCode, or any other agentic harness. This is a mental frame, not something that needs to be spelled out inside the prompt itself.

4. **Explicit behavioral expectations** — state plainly what "good execution" looks like for this task: depth over speed, grounding claims in real sources vs. general knowledge, flagging gaps rather than inventing detail, coherence checks the orchestrator itself is responsible for.

5. **Output contract** — restate, briefly, the form the final output must take (this is usually inherited from the task content, but the framing layer should confirm it explicitly so the orchestrator doesn't drift).

## Process

1. **Identify the task content** the user already has (in conversation, in a draft, or freshly described). Do not rewrite it substantively — that's not this skill's job.
2. **Determine what framing the task actually needs**: Does it need sub-agent delegation? Is parallelism relevant? Is there a risk of the agent drifting into a specific vendor/product assumption that should be avoided?
3. **Compose the framing layer** using the elements above, in plural voice, wrapping (not replacing) the task content.
4. **Keep it tight.** This is a scaffold, not a second essay. If an element isn't load-bearing for this task, cut it.
5. Output the composed prompt directly — no meta-commentary about the skill itself, no explaining what you did.

## Example shape

```
We need [task in plural voice]. The orchestrator should break this down and
deploy [N] sub-agents to handle [layers], working [in parallel / with a
synthesis step] rather than in competition.

[Core task content — scope, requirements, sourcing rules, etc.]

Depth and coherence take priority over speed. Where [X] isn't disclosed or
verifiable, we state that as a gap rather than inventing plausible detail.
The orchestrator is responsible for final consistency across [whatever the
sub-agents produce].
```

## Notes

- This skill's *output* is meant for an agentic harness, not for direct use in a plain chat/web interface — the user may explicitly say so; don't be confused if the composed prompt looks like it's "talking past" a normal chat context. That's correct.
- Don't over-explain the framing to the user afterward. Deliver the composed prompt; keep commentary minimal unless asked.
