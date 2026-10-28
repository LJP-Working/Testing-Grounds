---
type: llm
weight: 1
---

The final answer contains the skeptic's opinion in this structure:
- A section for BOTH options (SQLite and Postgres), each listing pros, cons, and key risks.
- Exactly one recommendation naming either SQLite or Postgres.
- A confidence line that is low, medium, or high, with a reason.

Fail if either option is missing its pros, cons, or key risks, if there is no single recommendation, or if the confidence line is missing.
