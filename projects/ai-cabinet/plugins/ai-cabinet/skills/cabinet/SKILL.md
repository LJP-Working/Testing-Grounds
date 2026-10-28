---
name: cabinet
argument-hint: "[--save] <question>"
description: Use whenever the user asks which option to choose on a significant decision ("should I use SQLite or Postgres?", "which job offer should I take?", "should I change things up?"), and before committing to any important decision yourself, coding or personal - hard or costly to reverse, high stakes (money, career, health, security, user data, many files/systems), multiple viable options with real trade-offs, or the user asks "should I / which is better" about a significant choice. Convenes an advisory board of independent agents that weighs pros and cons and returns a verdict. Not for factual questions, obvious answers, trivial or easily reversed choices, decisions already made, or when the user says no cabinet.
---

# AI Cabinet

An advisory board for important decisions. Independent advisors each weigh the pros and cons of every option, then a Chair delivers a reasoned verdict.

## Manual use: `/cabinet [--save] <question>`

When the user runs `/cabinet` themselves, **always convene**: skip the importance check below, even for a small question. Strip `--save` from the arguments; if it was present, save the result (Procedure step 6). The rest of the arguments is the question.

## When to convene

Convene the cabinet **without asking** when a decision meets **at least one** of these:
1. **Hard or costly to reverse.** Examples: a database or framework choice, a schema migration, deleting or restructuring large parts of a codebase, quitting a job, signing a lease.
2. **High stakes.** Meaningful impact on money, career, health, security, user data, or many files or systems.
3. **Real trade-offs.** Two or more genuinely viable options where reasonable people would disagree.
4. **Explicit uncertainty.** The user asks "should I…", "which is better…", or says they're unsure about a significant choice.

Do **not** convene it for:
- Factual or how-to questions ("what does this error mean", "how do I center a div").
- Choices with one clearly correct answer.
- Trivial or easily reversed choices (naming, formatting, small refactors, which test to write first).
- Decisions the user has already made, where they want execution, not advice.
- Cases where the user says to skip it ("no cabinet", "just do it").

"Should I…" phrasing alone is not enough: "should I use tabs or spaces?" is trivial and has a standard answer. When you don't convene, just answer normally and don't mention the cabinet.

When you do convene, first tell the user in one line: `Convening the cabinet: <reason>.` For example: "Convening the cabinet: this choice is hard to reverse and has two viable options."

## Procedure

1. **Frame.** Write a decision brief:
   - `Question:` the decision, in one sentence;
   - `Options:` 2–4 real options, including "do nothing / keep current" when that is viable;
   - `Context:` relevant facts: project details, the user's situation, constraints, goals.

   If the question is too vague to identify real options (e.g. "should I change things up?"), do not convene and do not invent options. Ask the user **exactly one** short clarifying question about what they're deciding, and stop.

2. **Seat specialists.** Pick 1–2 specialist fields that best fit the decision (e.g. "database engineer" for a database choice; "career coach" and "financial planner" for a job offer).

3. **Deliberate in parallel.** In **one message**, dispatch with the Agent tool:
   - `ai-cabinet:skeptic` with the brief;
   - `ai-cabinet:pragmatist` with the brief;
   - `ai-cabinet:specialist` once per specialist, with the first line `Specialist field: <field>` followed by the brief.

   Each advisor gets **only the brief**, never another advisor's opinion.

4. **Verdict.** Dispatch `ai-cabinet:chair` with the brief, then every advisor opinion verbatim. If any advisor failed or returned nothing, add the line `Missing advisors: <names>`.

5. **Present.** Show the Chair's verdict to the user **verbatim**, with every section intact: the pros/cons table, agreed/disagreed, recommendation with confidence, and what would change this. Don't summarize or paraphrase it. Then carry on in line with it:
   - **Coding task:** proceed with the recommended option unless the user objects.
   - **Personal decision:** the verdict is the answer.

6. **Save (opt-in only).** Save only when `--save` was given or the user asks for it afterwards. Write `decisions/YYYY-MM-DD-<topic-slug>.md` in the current working directory (create `decisions/` if missing) containing:
   - `# <question>` and the date;
   - `## Brief`, the full brief;
   - `## Advisor opinions`, every opinion verbatim;
   - `## Verdict`, the Chair's verdict verbatim.

## Error handling

- **An advisor fails or returns nothing:** continue; pass the Chair the opinions you have plus `Missing advisors: <names>`.
- **All advisors fail:** tell the user the cabinet couldn't meet, then give your own single-pass pros/cons analysis, clearly labeled "Not a cabinet verdict".
- **The Chair fails:** show the advisor opinions and your own short summary of them, labeled "Chair unavailable".
