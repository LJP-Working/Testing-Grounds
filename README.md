# 🧪 LJP Testing Grounds

A workspace for experimenting with AI, mostly Anthropic's **Claude**, and for the side projects that come out of it. Things here are works in progress. Expect rough drafts, failed attempts, and notes on what I learned along the way.

---

## 🔬 Research: AI & Claude

I'm learning how to work *with* AI models in practice: what they're good at, where they break, and how to get dependable results out of them. Right now I'm focused on four areas:

| Area | What I'm exploring |
| --- | --- |
| **Claude Code workflows** | Using Claude Code and agents to plan, build, and automate real projects from start to finish |
| **Prompting & skills** | Prompt engineering, custom skills, `CLAUDE.md` project context, and MCP connectors |
| **Building with the API** | Small apps and agents built on the Claude API and Agent SDK |
| **Model behavior & evals** | Testing how models reason, where they fail, and how outputs compare across prompts and models |

Notes, prompt experiments, and eval results go in [`research/`](research/).

---

## 🛠️ Projects

New projects I want to build, each one also a chance to test the research above:

| Project | Area | Status |
| --- | --- | --- |
| **Hardware / Flipper Zero** | Custom Flipper apps and hardware tinkering, built with AI help | 💡 Planned |
| **Automation tools** | Scripts and agents that handle repetitive personal and school tasks | 💡 Planned |
| **Web apps & games** | Small browser projects built with Claude | 💡 Planned |
| *More coming…* | — | — |

Each project gets its own folder in [`projects/`](projects/), started from the [project template](templates/project-template/).

**Status key:** 💡 Planned · 🚧 In progress · ✅ Working · 🧊 Paused · 🗑️ Abandoned (with notes on why)

---

## 📁 Repo layout

```
Testing-Grounds/
├── research/        # Notes, prompt experiments, eval results
│   ├── notes/
│   ├── prompts/
│   └── evals/
├── projects/        # One folder per real project
├── experiments/     # Quick, throwaway tests. Anything that grows up moves to projects/
├── templates/       # Starter files for new projects
└── CLAUDE.md        # Context for Claude Code when working in this repo
```

---

## 🧭 How I work here

- **Experiment first, clean up later.** Quick ideas start in `experiments/`.
- **Write down what happened.** Every project README has a *What I learned* section, and failures count.
- **Credit the AI.** Commits made with Claude's help are marked as co-authored.

---

*Maintained by [Luke Polich](https://github.com/lukepolich) · [LJP-Working](https://github.com/LJP-Working)*
