# AI Cabinet — Design Spec

**Date:** 2026-10-27
**Status:** Draft, awaiting review

## Purpose

A Claude Code plugin that gives Claude an advisory board ("cabinet") for important decisions. Instead of answering a weighty question in one pass, Claude convenes several independent advisors who each weigh the pros and cons of every option, then a Chair delivers a reasoned verdict.

It serves two kinds of decisions with one board:
- **Coding decisions** Claude meets while working (architecture, libraries, data models, risky changes).
- **Personal decisions** the user brings (career, school, money, business).

## Decisions made during brainstorming

| Topic | Decision |
|---|---|
| Scope | One general-purpose board for both coding and personal decisions |
| Trigger | Automatic: Claude judges importance itself and convenes the board without asking. Simple or basic questions never trigger it. `/cabinet` forces a review manually |
| Board makeup | Hybrid: a fixed core (Skeptic, Pragmatist) plus 1–2 specialists chosen per decision, and a Chair |
| Deliberation | Advisors run as independent subagents in parallel without seeing each other's views, then the Chair synthesizes. No rebuttal round (YAGNI; can be added later) |
| Persistence | Verdict shown in chat. Saved to a file only on opt-in (`--save`, or the user asking afterwards) |
| Structure | A skill, a command and separate agent files per advisor, so each personality can be tuned on its own |

## When the cabinet convenes (automatic trigger)

Claude convenes the cabinet **without asking** when a decision meets **at least one** of these:
1. **Hard or costly to reverse.** Examples: a database or framework choice, a schema migration, deleting or restructuring large parts of a codebase, quitting a job, signing a lease.
2. **High stakes.** Meaningful impact on money, career, health, security, user data, or many files or systems.
3. **Real trade-offs.** Two or more genuinely viable options where reasonable people would disagree.
4. **Explicit uncertainty.** The user asks "should I…", "which is better…", or says they're unsure about a significant choice.

Claude does **not** convene it for:
- Factual or how-to questions ("what does this error mean", "how do I center a div").
- Choices with one clearly correct answer.
- Trivial or easily reversed choices (naming, formatting, small refactors, which test to write first).
- Decisions the user has already made, where they want execution, not advice.
- Cases where the user says to skip it ("no cabinet", "just do it").

When it convenes automatically, Claude announces it in one line first, e.g. *"Convening the cabinet: this choice is hard to reverse and has two viable options."* The user sees why time and tokens are being spent and can interrupt.

**Reliability:** skills trigger from their description, which is not guaranteed to fire. To make sure the cabinet is considered every session, the plugin adds a small `SessionStart` hook that injects a short reminder of the trigger rules into context.

## Components

All components live in a plugin directory, `plugins/ai-cabinet/`, in this repository. The repository root also acts as a local plugin marketplace so the plugin can be installed.

| File | Responsibility |
|---|---|
| `.claude-plugin/marketplace.json` (repo root) | Declares a local marketplace containing `ai-cabinet` |
| `plugins/ai-cabinet/.claude-plugin/plugin.json` | Plugin manifest (name, version, description) |
| `plugins/ai-cabinet/skills/cabinet/SKILL.md` | The trigger rules and the full deliberation procedure; the orchestration lives here |
| `plugins/ai-cabinet/commands/cabinet.md` | `/cabinet [--save] <question>`: forces a review and runs the skill's procedure |
| `plugins/ai-cabinet/agents/skeptic.md` | Core seat. Finds risks, failure modes, hidden costs and weak assumptions in every option |
| `plugins/ai-cabinet/agents/pragmatist.md` | Core seat. Weighs effort, time, money, reversibility and fit with the user's real situation |
| `plugins/ai-cabinet/agents/specialist.md` | Domain expert. Its field (e.g. "database engineer", "career coach") is assigned in the prompt for each decision |
| `plugins/ai-cabinet/agents/chair.md` | Reads all opinions and delivers the verdict; does not run its own fresh analysis |
| `plugins/ai-cabinet/hooks/hooks.json` | `SessionStart` hook that injects the trigger reminder |
| `README.md` (repo root) | What it is, how to install, how to use, how to tune advisors |

The advisor agents are read-only. They get no file-editing tools; they may read files and search the web when that helps their analysis.

## Deliberation flow

Orchestration runs in the main Claude session, because subagents cannot spawn other subagents.

1. **Frame.** Claude writes a decision brief:
   - the question, in one sentence;
   - 2–4 real options, including "do nothing / keep current" when that is viable;
   - relevant context (project facts, user's situation, constraints, goals).

   If the question is too vague to identify options, Claude asks the user one clarifying question first.
2. **Seat specialists.** Claude picks 1–2 specialist fields that best fit the decision.
3. **Deliberate in parallel.** In one message, Claude dispatches the Skeptic, the Pragmatist and each specialist with the identical brief. Each returns this structure:
   - per option: pros, cons, key risks;
   - their recommended option;
   - confidence (low / medium / high) and the main reason for it.
4. **Verdict.** Claude dispatches the Chair with the brief and all advisor opinions. The Chair returns:
   - a pros/cons summary table per option;
   - where the advisors agreed and where they disagreed, and why;
   - the recommendation, with a confidence level;
   - what would change the recommendation ("if X turns out true, choose B instead").
5. **Present.** Claude shows the Chair's verdict in chat, then continues the task in line with it. On a coding task, Claude proceeds with the recommended option unless the user objects. On a personal decision, the verdict is the answer.
6. **Save (opt-in).** With `--save`, or if the user asks afterwards, Claude writes the brief, every opinion and the verdict to `decisions/YYYY-MM-DD-<topic-slug>.md` in the current working directory.

## Error handling

- **An advisor fails or returns nothing:** the Chair proceeds with the opinions it has and notes who was missing.
- **All advisors fail:** Claude reports the failure and gives its own single-pass pros/cons analysis, clearly labeled as not a cabinet verdict.
- **Advisors unanimous with low confidence:** the Chair says so explicitly, rather than presenting a weak consensus as strong.
- **`--save` but `decisions/` doesn't exist:** create it.

## Testing

Plugin behavior is prompt-driven, so testing is scenario-based, run with the plugin loaded (`claude --plugin-dir plugins/ai-cabinet`):

1. **Coding decision triggers:** e.g. "Should this app use SQLite or Postgres?" The cabinet convenes, specialists fit (e.g. database engineer), and the verdict has every required section.
2. **Personal decision triggers:** e.g. "Should I take a higher-paying job with a longer commute?" The specialists fit (e.g. career coach, financial planner).
3. **Trivial question does not trigger:** e.g. "What does `git stash` do?" or "Rename this variable." No cabinet.
4. **Manual command:** `/cabinet --save <question>` runs, and a file appears in `decisions/`.
5. **Independence:** each advisor's prompt contains only the brief, never another advisor's opinion.

## Out of scope (for now)

- A rebuttal or debate round between advisors.
- User-configurable board makeup through settings (tuning is done by editing agent files).
- Tracking verdict accuracy over time.
