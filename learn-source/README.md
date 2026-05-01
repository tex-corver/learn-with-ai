# learn-source

Adaptive learning from a local file (PDF, markdown, or plain text). Ingests the file into NotebookLM as a new notebook, then runs the `/learn` adaptive learning workflow with that notebook as the single source of truth. Every non-obvious claim the tutor makes is verified against the source via a cited query. Progress persists per source in your Obsidian vault so sessions resume across days.

This plugin is a composition skill: it orchestrates the sibling plugins `notebooklm` (ingestion + cited QA) and `learn` (pedagogy). Install all three together.

## Prerequisites

- **`nlm` CLI** — `uv tool install notebooklm-mcp-cli`, then `nlm auth login`
- **`notebooklm` plugin** — co-installed from the same marketplace; provides the cited QA pipeline and the vault layout we extend
- **`learn` plugin** — co-installed; provides the Bloom's / SOLO pedagogy we delegate to
- **Obsidian vault with Dataview** — recommended. Without a vault, `learn-source` falls back to `~/.claude/learn-source/<slug>/` for progress files.

See `skills/learn-source/SKILL.md` for the full preflight matrix.

## Quick Start

```text
# New session: ingest a PDF and start learning
/learn-source ~/Documents/rich-dad-poor-dad.pdf

# Resume: pick up where you left off
/learn-source ~/Documents/rich-dad-poor-dad.pdf resume

# Resume with no path: browse your Learning Method index
/learn-source resume
```

On the first invocation for a given file, `learn-source` creates a NotebookLM notebook, uploads the file as a source, and scaffolds `Notes/NotebookLM/<slug>/Learning/Learning Method.md` in your vault. It then hands off to `/learn` with a preamble that names the notebook ID, points to the progress file, and instructs the tutor to verify every factual claim via `nlm notebook query`.

On resume, the notebook lookup is by slug, the progress file is read first, and `/learn` begins with a Phase 1 diagnostic against retained knowledge before picking up the learning ladder.

## What You Get

- A NotebookLM notebook per source, with the file as a cited source
- A vault folder co-located with the notebook index, containing `Sources/`, `QA/`, and `Learning/`
- A `Learning Method.md` progress file with SOLO levels, mistake tracker, and QA note index — all Dataview-queryable
- QA notes with `[N]` citations resolved to block references in the source transcript (via the `notebooklm` plugin's resolver)

## See Also

- [`skills/learn-source/SKILL.md`](skills/learn-source/SKILL.md) — full workflow, preamble template, handoff mechanics
- [`../learn/skills/learn/SKILL.md`](../learn/skills/learn/SKILL.md) — the pedagogy this plugin delegates to
- [`../notebooklm/skills/notebooklm/SKILL.md`](../notebooklm/skills/notebooklm/SKILL.md) — ingestion and cited QA

## License

MIT
