# AI Cabinet

> A Claude Code plugin that convenes an advisory board of AI agents to weigh the pros and cons of important decisions before choosing.

**Status:** 💡 Planned · **Started:** 2026-10-27 · **Area:** Automation

## Goal
Make Claude reason more carefully about decisions that matter, both coding decisions (architecture, libraries, risky changes) and personal ones (career, school, money). Instead of answering in one pass, Claude convenes a "cabinet" of independent advisors, then a Chair delivers a reasoned verdict. Simple questions skip the cabinet entirely.

## How it works
A Claude Code plugin made of:
- a **skill** with the rules for when a decision is important enough, and the deliberation procedure;
- a **`/cabinet` command** to force a review manually (`--save` writes the verdict to `decisions/`);
- **advisor agents**: a fixed core (Skeptic, Pragmatist), 1–2 specialists picked per decision, and a Chair;
- a **SessionStart hook** that reminds Claude the cabinet exists, so it gets considered every session.

Advisors run in parallel without seeing each other's views; the Chair weighs them all. Full design: [design spec](docs/superpowers/specs/2026-10-27-ai-cabinet-design.md).

## AI's role
Claude is both the builder and the product: it designed the plugin with me through a brainstorming session, and the plugin itself is a set of Claude agents.

## Running it
```bash
# coming once the plugin is built
```

## What I learned
Nothing yet. Filled in as the project goes.
