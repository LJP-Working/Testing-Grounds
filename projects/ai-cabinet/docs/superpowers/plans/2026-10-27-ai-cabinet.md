# AI Cabinet Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Claude Code plugin that automatically convenes a board of independent advisor agents for important decisions and returns a Chair's reasoned verdict.

**Architecture:** A prompt-only plugin. The `cabinet` skill holds the trigger rules and orchestrates the deliberation from the main session. Four agent files define the advisors (Skeptic, Pragmatist, Specialist, Chair). A `/cabinet` command forces a review, and a `SessionStart` hook injects a trigger reminder. Behavior is tested with `claude plugin eval` cases, and structure with `claude plugin validate`.

**Tech Stack:** Claude Code plugin format (markdown with YAML frontmatter, JSON manifests), `claude plugin validate`, `claude plugin eval`.

**Spec:** [`docs/superpowers/specs/2026-10-27-ai-cabinet-design.md`](../specs/2026-10-27-ai-cabinet-design.md)

## Global Constraints

- All paths below are relative to `projects/ai-cabinet/` in the Testing-Grounds repo. Commit to `main` and push at the end of each task (repo convention).
- `claude` is not on PATH. Use `CLAUDE="/c/Users/lukej/AppData/Local/Claude-Data/claude_pzs8sxrjxfjjc/claude-code/2.1.308/c17a819afb40/claude.exe"` and call `"$CLAUDE"`.
- Plugin name `ai-cabinet`, version `0.1.0`. Marketplace name `ai-cabinet`. Install id `ai-cabinet@ai-cabinet`.
- Agent ids as dispatched: `ai-cabinet:skeptic`, `ai-cabinet:pragmatist`, `ai-cabinet:specialist`, `ai-cabinet:chair`. Task 1 confirms the exact id format with `"$CLAUDE" plugin details`. If it differs, use the reported form everywhere.
- The trigger list, the skip list, the advisor output fields and the verdict sections are copied **verbatim from the spec**. Don't paraphrase them into something weaker.
- Advisors and the Chair are read-only. Advisors get `Read, Glob, Grep, WebSearch, WebFetch`. The Chair gets `Read`.
- Every eval case: `runs: 3` (the default), at least one outcome (`llm`) grader, and plugin-fire graders as display only.
- Never commit `evals/results/`. Add it to `.gitignore` in Task 1.

## Review Focus

1. **Borderline "should I" on a trivial choice** ("should I use tabs or spaces?"). The phrasing matches trigger 4, but the choice is trivial, so it must not convene. Test: `evals/no-trigger-trivial-should-i` (Task 4).
2. **User opts out on a big decision** ("no cabinet, just pick Postgres or SQLite for me"). Must skip the board. Test: `evals/no-trigger-opt-out` (Task 4).
3. **Too vague to find options** ("should I change things up?"). Must ask one clarifying question, not invent options and convene. Test: `evals/vague-asks-first` (Task 4).
4. **An advisor is missing.** The Chair must still deliver a verdict and name who was missing. Test: `evals/chair-missing-advisor` (Task 3).
5. **`--save` in a folder without `decisions/`.** The folder must be created and the file written. Test: `evals/command-save` (Task 5) runs in a fresh scaffold dir.

---

### Task 1: Plugin scaffold and marketplace

**Files:**
- Create: `.claude-plugin/marketplace.json`
- Create: `plugins/ai-cabinet/.claude-plugin/plugin.json`
- Create: `.gitignore` (contains `plugins/ai-cabinet/evals/results/`)

**Interfaces:**
- Produces: plugin root `plugins/ai-cabinet/`. The marketplace lists `{ "name": "ai-cabinet", "source": "./plugins/ai-cabinet" }`.

- [ ] **Step 1: Validate before the files exist (expect failure)**
  Run: `"$CLAUDE" plugin validate plugins/ai-cabinet`
  Expected: non-zero exit, missing manifest.
- [ ] **Step 2: Write `plugin.json`**
  It has `name`, `version`, `description` (one sentence from the spec's Purpose), and `author: {"name": "Luke Polich"}`.
- [ ] **Step 3: Write `marketplace.json`**
  It has `name: "ai-cabinet"`, `owner: {"name": "Luke Polich"}`, and a `plugins` array with the one entry above.
- [ ] **Step 4: Validate both**
  Run: `"$CLAUDE" plugin validate plugins/ai-cabinet && "$CLAUDE" plugin validate .`
  Expected: both exit 0.
- [ ] **Step 5: Commit and push**
  `git add .claude-plugin plugins .gitignore && git commit -m "ai-cabinet: plugin and marketplace manifests"`

### Task 2: Core and specialist advisor agents

**Files:**
- Create: `plugins/ai-cabinet/agents/skeptic.md`, `pragmatist.md`, `specialist.md`
- Create: `plugins/ai-cabinet/evals/advisor-format/prompt.md` and `graders/format.md`

**Interfaces:**
- Consumes: plugin root from Task 1.
- Produces: three agents. Each takes a **decision brief** (question, options, context) and returns exactly this markdown:
  ```
  ## <Role> opinion
  ### Option: <name>
  - Pros: …
  - Cons: …
  - Key risks: …
  (repeat per option)
  ### Recommendation: <option name>
  ### Confidence: low | medium | high: <main reason>
  ```
  `specialist` reads its field from a first line `Specialist field: <field>` in its prompt, and uses `## <field> opinion` as its heading.

- [ ] **Step 1: Write the eval case**
  `prompt.md`: frontmatter `allowed_tools: [Agent]`, `max_turns: 6`. Body: "Dispatch the ai-cabinet:skeptic agent with this brief and show me its answer verbatim: Question: Should my class project use SQLite or Postgres? Options: SQLite; Postgres. Context: solo student, 3-week project, deployed on one small VPS."
  Graders:
  - `tool_used`, tool `Agent`, `input_match: "ai-cabinet:skeptic"`, `min: 1`.
  - `llm`: the answer has a Pros/Cons/Key risks block for **both** options, one Recommendation naming one of them, and a Confidence line of low/medium/high with a reason.
- [ ] **Step 2: Run it (expect failure)**
  Run: `"$CLAUDE" plugin eval plugins/ai-cabinet --case advisor-format --runs 1 --ablation none`
  Expected: FAIL, because the agent doesn't exist.
- [ ] **Step 3: Write the three agent files**
  Frontmatter: `name`, `description` (one line saying it's a cabinet advisor, dispatched by the cabinet skill), `tools: Read, Glob, Grep, WebSearch, WebFetch`. Each body has the role's lens from the spec's Components table, the output format above (verbatim), and the rule "judge every option, including ones you dislike; don't hedge; if the brief lacks a fact you need, state your assumption."
- [ ] **Step 4: Validate and confirm the agent ids**
  Run: `"$CLAUDE" plugin validate plugins/ai-cabinet && "$CLAUDE" plugin details plugins/ai-cabinet`
  Expected: exit 0, and the inventory lists 3 agents. Record the id format they're listed under.
- [ ] **Step 5: Run the eval (expect pass)**
  Same command as Step 2. Expected: score 1.0.
- [ ] **Step 6: Commit and push**

### Task 3: Chair agent

**Files:**
- Create: `plugins/ai-cabinet/agents/chair.md`
- Create: `plugins/ai-cabinet/evals/chair-missing-advisor/prompt.md` and `graders/verdict.md`

**Interfaces:**
- Consumes: the advisor opinion format from Task 2.
- Produces: `ai-cabinet:chair`. It takes the brief, all advisor opinions, and an optional line `Missing advisors: <names>`. It returns:
  ```
  ## Cabinet verdict
  | Option | Pros | Cons |  (one row per option)
  ### Where the cabinet agreed / disagreed
  ### Recommendation: <option> (confidence: low | medium | high)
  ### What would change this
  ```
  When opinions are missing, a line `Missing: <names>` goes directly under the heading. When advisors are unanimous but every confidence is low, the verdict must say the consensus is weak.

- [ ] **Step 1: Write the eval case**
  The prompt dispatches `ai-cabinet:chair` with the SQLite/Postgres brief, two hand-written advisor opinions (Skeptic: Postgres, medium; Pragmatist: SQLite, high), and `Missing advisors: database engineer`.
  Graders:
  - `tool_used` Agent `input_match: "ai-cabinet:chair"`.
  - `llm`: the verdict has all four sections, names the database engineer as missing, explains the Skeptic/Pragmatist disagreement, and gives a single recommendation with confidence.
- [ ] **Step 2: Run it (expect failure)**
  `--case chair-missing-advisor --runs 1 --ablation none`
- [ ] **Step 3: Write `chair.md`**
  Frontmatter `tools: Read`. The body says the Chair weighs the opinions it is given and does not run a fresh analysis, plus the output format and the missing/weak-consensus rules above.
- [ ] **Step 4: Validate and run the eval (expect pass)**
- [ ] **Step 5: Commit and push**

### Task 4: `cabinet` skill (trigger rules and orchestration)

**Files:**
- Create: `plugins/ai-cabinet/skills/cabinet/SKILL.md`
- Create eval cases under `plugins/ai-cabinet/evals/`: `trigger-coding`, `trigger-personal`, `no-trigger-factual`, `no-trigger-trivial-should-i`, `no-trigger-opt-out`, `vague-asks-first`

**Interfaces:**
- Consumes: the 4 agent ids, the brief format (Task 2), the verdict format (Task 3).
- Produces: skill `cabinet`. Task 5's command runs "the cabinet skill's procedure" with an optional save flag.

- [ ] **Step 1: Write the six eval cases**
  All use `allowed_tools: [Skill, Agent, Read, Glob, Grep]` and `max_turns: 20`.

  | Case | Prompt | Graders |
  |---|---|---|
  | `trigger-coding` | "I'm starting a todo web app for my class. Should I use SQLite or Postgres?" | `tool_used` Agent `input_match: "skeptic"` min 1; Agent `input_match: "chair"` min 1; `llm`: answer has a pros/cons per option, a recommendation with confidence, and "what would change this" |
  | `trigger-personal` | "I got two offers: $68k remote, or $80k with a 1-hour commute each way. Which should I take?" | same Agent graders; `llm`: same sections, and the advisors include a career- or finance-type specialist |
  | `no-trigger-factual` | "What does `git stash` do?" | `tool_used` Agent `max: 0`; `llm`: a direct, correct explanation |
  | `no-trigger-trivial-should-i` | "Should I use tabs or spaces in this Python file?" | Agent `max: 0`; `llm`: short direct answer (spaces, PEP 8) |
  | `no-trigger-opt-out` | "No cabinet, just pick for me: SQLite or Postgres for a small class project?" | Agent `max: 0`; `llm`: picks one directly |
  | `vague-asks-first` | "Should I change things up?" | Agent `max: 0`; `llm`: asks exactly one clarifying question and doesn't invent options |

- [ ] **Step 2: Run them (expect failures)**
  Run: `"$CLAUDE" plugin eval plugins/ai-cabinet --case "trigger-*" --runs 1`
  Expected: the trigger cases fail, because no skill exists. The no-trigger cases may already pass, which is fine.
- [ ] **Step 3: Write `SKILL.md`**
  - Frontmatter `description`: "Use before committing to any important decision, coding or personal: hard or costly to reverse, high stakes (money, career, health, security, user data, many files/systems), multiple viable options with real trade-offs, or the user asks 'should I / which is better' about a significant choice. Convenes an advisory board of independent agents. Not for factual questions, obvious answers, trivial or easily reversed choices, decisions already made, or when the user says no cabinet."
  - Body, in this order:
    1. The "convenes" and "does not convene" lists, verbatim from the spec.
    2. The one-line announcement format: "Convening the cabinet: <reason>."
    3. Procedure steps 1–6 from the spec's Deliberation flow. Step 3 says to dispatch every advisor **in one message**, each with only the brief, never another advisor's opinion.
    4. The error-handling rules from the spec.
    5. The save file format: brief, every opinion, verdict, saved to `decisions/YYYY-MM-DD-<topic-slug>.md` (create the folder if missing).
- [ ] **Step 4: Validate and run all six cases (expect pass)**
  Run: `"$CLAUDE" plugin validate plugins/ai-cabinet && "$CLAUDE" plugin eval plugins/ai-cabinet --case "*trigger*" --case "vague-asks-first" -j 3`
  Expected: every case scores 1.0. If a trigger case fails, tighten the skill `description` first, then the body.
- [ ] **Step 5: Commit and push**

### Task 5: `/cabinet` command

**Files:**
- Create: `plugins/ai-cabinet/commands/cabinet.md`
- Create: `plugins/ai-cabinet/evals/command-save/prompt.md` and `graders/`

**Interfaces:**
- Consumes: the `cabinet` skill (Task 4).
- Produces: `/cabinet [--save] <question>`.

- [ ] **Step 1: Write the eval case**
  Prompt: `/cabinet --save Should my class project use SQLite or Postgres?` with `allowed_tools: [Skill, Agent, Read, Glob, Grep, Write]`.
  Graders:
  - `tool_used` Agent `input_match: "chair"` min 1.
  - `tool_used` Write `input_match: "decisions[/\\\\]\\d{4}-\\d{2}-\\d{2}-.+\\.md"` min 1.
  - `llm`: the verdict is shown in chat.
- [ ] **Step 2: Run it (expect failure)**
  `--case command-save --runs 1 --allow-tools Write`
- [ ] **Step 3: Write `cabinet.md`**
  Frontmatter: `description: Convene the AI cabinet on a decision`, `argument-hint: [--save] <question>`. The body says to always convene (skip the importance check), strip `--save` from `$ARGUMENTS`, follow the cabinet skill's procedure, and save only if `--save` was present.
- [ ] **Step 4: Validate and run (expect pass)**
- [ ] **Step 5: Commit and push**

### Task 6: SessionStart reminder hook

**Files:**
- Create: `plugins/ai-cabinet/hooks/hooks.json`
- Create: `plugins/ai-cabinet/hooks/session-reminder.md`

**Interfaces:**
- Produces: on every session start, the reminder text is added to Claude's context.

- [ ] **Step 1: Run the hook command before it exists (expect failure)**
  Run: `CLAUDE_PLUGIN_ROOT="$PWD/plugins/ai-cabinet" bash -c 'cat "${CLAUDE_PLUGIN_ROOT}/hooks/session-reminder.md"'`
  Expected: "No such file".
- [ ] **Step 2: Write `session-reminder.md`**
  At most 8 lines: the cabinet exists; the four convene conditions and the skip list in short form; "use the cabinet skill".
- [ ] **Step 3: Write `hooks.json`**
  `{"hooks": {"SessionStart": [{"hooks": [{"type": "command", "command": "cat \"${CLAUDE_PLUGIN_ROOT}/hooks/session-reminder.md\""}]}]}}`
- [ ] **Step 4: Verify**
  Re-run Step 1 (prints the reminder), then `"$CLAUDE" plugin validate plugins/ai-cabinet` (exit 0), then `"$CLAUDE" plugin details plugins/ai-cabinet` (lists the SessionStart hook).
- [ ] **Step 5: Commit and push**

### Task 7: Full suite, README and status

**Files:**
- Modify: `README.md` (the project README: Status, How it works, Running it)
- Modify: `../../README.md` and `../README.md` (status 💡 → ✅ in both Projects tables)

- [ ] **Step 1: Run the full suite with the baseline**
  Run: `"$CLAUDE" plugin eval plugins/ai-cabinet -j 3 --allow-tools Write --no-publish`
  Expected: every case scores 1.0, and the trigger cases show a positive delta against the no-plugin arm.
- [ ] **Step 2: Fill in the README**
  The "Running it" block gets the install commands (`claude plugin marketplace add <path-to-projects/ai-cabinet>` then `claude plugin install ai-cabinet@ai-cabinet`) and the run-evals command. Add usage examples (automatic and `/cabinet --save …`), how to tune an advisor (edit its file in `agents/`), and first notes in "What I learned".
- [ ] **Step 3: Set the status to ✅ Working in all three READMEs**
- [ ] **Step 4: Commit and push**
