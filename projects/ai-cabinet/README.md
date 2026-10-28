# AI Cabinet

> A Claude Code plugin that convenes an advisory board of AI agents to weigh the pros and cons of important decisions before choosing.

**Status:** ✅ Working · **Started:** 2026-10-27 · **Area:** Automation

## Goal
Make Claude reason more carefully about decisions that matter, both coding decisions (architecture, rewrites, risky changes) and personal ones (career, school, money). Instead of answering in one pass, Claude convenes a "cabinet" of independent advisors, then a Chair delivers a reasoned verdict. Simple questions skip the cabinet entirely.

## How it works
Everything lives in [`plugins/ai-cabinet/`](plugins/ai-cabinet/):

| Piece | File | Job |
|---|---|---|
| Skill | `skills/cabinet/SKILL.md` | Decides when a decision is important enough, and runs the deliberation. Also the `/cabinet` command |
| Skeptic | `agents/skeptic.md` | Always sits. Hunts for risks, failure modes and hidden costs |
| Pragmatist | `agents/pragmatist.md` | Always sits. Weighs effort, time, money and reversibility |
| Specialist | `agents/specialist.md` | 1–2 per decision, with the field picked to fit (e.g. career coach, database engineer) |
| Chair | `agents/chair.md` | Reads every opinion and writes the verdict |
| Reminder hook | `hooks/` | At session start, reminds Claude of the rules so the cabinet actually gets considered |

A session goes: **brief** (question, 2–4 options, context) → **advisors in parallel**, each seeing only the brief → **Chair's verdict** (a pros/cons table, where advisors agreed and disagreed, a recommendation with confidence, what would change it). Full design: [design spec](docs/superpowers/specs/2026-10-27-ai-cabinet-design.md) · [build plan](docs/superpowers/plans/2026-10-27-ai-cabinet.md).

## Using it
- **Automatic:** just work normally. When a decision is hard to reverse, high-stakes, or a real trade-off, Claude says "Convening the cabinet: …" and runs it. Simple questions get a normal answer. Say "no cabinet" to skip it.
- **Manual:** `/cabinet <question>` always convenes, even for small questions.
- **Save it:** `/cabinet --save <question>` also writes the full record to `decisions/YYYY-MM-DD-<topic>.md` in the current folder. Nothing is saved otherwise.
- **Tune an advisor:** edit its file in `plugins/ai-cabinet/agents/`. Add a permanent seat by copying `skeptic.md` and changing the lens, then add it to step 3 of the skill.

## Running it
Install (once), from a terminal:
```bash
claude plugin marketplace add "C:/Users/lukej/OneDrive/Desktop/claude code/LJP_Working/Testing-Grounds/projects/ai-cabinet"
```
```bash
claude plugin install ai-cabinet@ai-cabinet
```
Run the eval suite (it uses your Claude usage: 10 cases, each run 3 times with the plugin and 2 without):
```bash
claude plugin eval projects/ai-cabinet/plugins/ai-cabinet -j 4 --allow-tools Write
```

## AI's role
Claude is both the builder and the product. It designed the plugin with me in a brainstorming session, wrote a spec and a test-first plan, then built it task by task, using `claude plugin eval` to prove each piece. The plugin itself is a set of Claude agents.

## What I learned
- **A skill's description doesn't reliably trigger it.** On its own, the skill never fired on a coding decision. A small SessionStart hook that reminds Claude of the rules fixed that.
- **"Important" is a judgment call, and Claude makes it.** It treated "SQLite or Postgres for a class todo app" and "monolith or microservices for a 3-person startup" as settled and answered directly, and only convened on a real dilemma (rewriting an 8-year-old app versus improving it). That's the behavior I asked for, but it means the board is pickier than the spec's examples suggest.
- **Paraphrasing loses information.** Claude summarized the Chair's verdict and dropped sections until the skill said to show it verbatim.
- **Tests that pass before the code exists are telling you something.** The `/cabinet --save` test passed with no command file, which revealed that skills are already slash commands, so the planned command file wasn't needed.
