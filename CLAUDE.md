# CLAUDE.md

Context for Claude Code when working in this repo.

## What this repo is
Luke's experimentation workspace for AI/Claude research and side projects. It's a learning sandbox, not production code: favor clarity and explanation over cleverness.

## Layout
- `research/`: notes (`notes/`), prompt experiments (`prompts/`), evals (`evals/`). Files are named `YYYY-MM-DD-topic.md`.
- `projects/<name>/`: one folder per project, started from `templates/project-template/`.
- `experiments/`: throwaway tests.

## Conventions
- When a new project is created, also add it to the Projects table in the root `README.md`.
- Keep each project's README up to date, especially the "What I learned" section.
- Never commit secrets or API keys. Use `.env` files (gitignored) and add a `.env.example`.
