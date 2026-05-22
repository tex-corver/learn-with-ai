# learn-with-ai

A Claude Code marketplace of three composable plugins for AI-assisted learning and knowledge management. Pedagogy, ingestion, and cited verification — wire them together to study any source with a tutor that can't hallucinate past its references.

## Plugins

| Plugin | Version | What it does |
|---|---|---|
| [`learn`](./learn) | 1.0.0 | Interactive learning companion using Bloom's and SOLO taxonomies. Topic learning, breadth-first overviews, codebase exploration, and active recall quizzes with multi-session progress tracking. |
| [`notebooklm`](./notebooklm) | 1.0.0 | Imports NotebookLM notebooks into your Obsidian vault as linked knowledge graphs. Resolves `[N]` citations to passage-level deep links, supports YouTube channel bulk-loading, and runs expert-informed interviews. |
| [`learn-source`](./learn-source) | 0.1.0 | Adaptive learning from a local PDF / markdown / text file. Ingests into NotebookLM and runs `/learn` with cited source-of-truth verification. Progress persists per source. Composes `learn` + `notebooklm`. |

## Install

Add this marketplace to Claude Code, then install the plugins you want:

```text
/plugin marketplace add <git-url-or-path-to-this-repo>
/plugin install notebooklm@learning-with-ai
/plugin install learn@learning-with-ai
/plugin install learn-source@learning-with-ai
```

`learn-source` depends on the other two — install all three if you want the full stack.

## Quick Start

```text
# Pedagogy only — learn any topic from the model's knowledge
/learn binary search trees

# Ingest a NotebookLM notebook into your vault
/notebooklm import <notebook-url>

# Adaptive learning from a local file, with cited verification
/learn-source ~/Documents/rich-dad-poor-dad.pdf
```

## Prerequisites

- **Claude Code** with plugin support
- **Obsidian vault** (recommended) — `notebooklm` and `learn-source` write progress and QA notes into the vault
- **`nlm` CLI** for `notebooklm` / `learn-source`: `uv tool install notebooklm-mcp-cli && nlm auth login`

See each plugin's README and `SKILL.md` for the full preflight matrix.

## Repo Layout

```text
.
├── .claude-plugin/marketplace.json   # marketplace manifest
├── learn/                            # /learn — pedagogy
├── notebooklm/                       # /notebooklm — ingestion + cited QA
└── learn-source/                     # /learn-source — composition of the above
```

## License

MIT
