---
max_turns: 6
allowed_tools: [Agent]
---

Dispatch the ai-cabinet:chair agent with everything below as its prompt, and show me its answer verbatim.

Question: Should my class project use SQLite or Postgres?
Options: SQLite; Postgres
Context: solo student, 3-week project, deployed on one small VPS.

Missing advisors: database engineer

## Skeptic opinion
### Option: SQLite
- Pros: zero setup, single file, easy backups
- Cons: weak concurrent writes
- Key risks: file corruption if the VPS disk fills; migrating later is painful
### Option: Postgres
- Pros: robust concurrency, industry standard
- Cons: more to install and secure
- Key risks: misconfigured auth exposed on a public VPS
### Recommendation: Postgres
### Confidence: medium: SQLite's risks grow if the app gets real users

## Pragmatist opinion
### Option: SQLite
- Pros: works in minutes, nothing to run or patch
- Cons: fewer hosting options later
- Key risks: little for a 3-week solo project
### Option: Postgres
- Pros: scales if the project continues
- Cons: setup and ops eat days of a 3-week timeline
- Key risks: time lost to configuration instead of features
### Recommendation: SQLite
### Confidence: high: the timeline and team size dominate
