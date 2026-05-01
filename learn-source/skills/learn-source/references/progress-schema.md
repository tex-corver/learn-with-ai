# Learning Method File Schema

Every source learned via `/learn-source` gets exactly one `Learning Method.md` file, located at:

```text
<vault-root>/Notes/NotebookLM/<notebook_slug>/Learning/Learning Method.md
```

Or, under the vault-less fallback:

```text
~/.claude/learn-source/<notebook_slug>/Learning Method.md
```

The file is markdown with a Dataview-queryable frontmatter block. It extends the `learn` plugin's `consolidation-templates.md` format with three NotebookLM-specific frontmatter fields: `notebook_id`, `notebook_slug`, `source_ref`.

## Required frontmatter

| Field | Type | Purpose |
|-------|------|---------|
| `type` | literal `learning-method` | Dataview filter key — same value the `learn` plugin uses |
| `status` | `active` \| `paused` \| `complete` | Session lifecycle |
| `date` | ISO date (`YYYY-MM-DD`) | Creation date; kept stable across updates |
| `notebook_id` | UUID | Full NotebookLM notebook ID for `nlm notebook query` calls |
| `notebook_slug` | kebab-case string | Slug used in vault folder and `notebooklm` ask workflow |
| `source_ref` | wikilink | Link to the source file under `Notes/NotebookLM/<slug>/Sources/` |
| `source_type` | `pdf` \| `md` \| `markdown` \| `txt` | File extension of the ingested source |
| `related` | list of wikilinks | Must include the notebook index file; may include related topics |

## Required sections

| Section | Role |
|---------|------|
| `## Framework` | One-liner naming the source and the grounding approach ("source-driven adaptive learning via NotebookLM") |
| `## Approach` | The learning-ladder strategy chosen at first diagnose (chapter-by-chapter, conceptual rings, scenario spine, etc.) |
| `## Key Terms` | Glossary — filled during Phase 1, updated as new terms appear |
| `## Learning Path` | Phase table with status per major area |
| `## Progress by Topic` | Per-topic row: date, SOLO level, scenario summary, QA note link |
| `## QA Notes Index` | Index of all QA notes written during this source's sessions |
| `## Cross-Session Mistake Tracker` | Misconceptions caught, the correction, the topic |
| `## Last Session` | Pointer for resume: date, ending phase/topic, recommended next step |

## Example

```markdown
---
type: learning-method
status: active
date: 2026-04-21
notebook_id: 2a18a53d-be60-4951-af17-8b7303dc097e
notebook_slug: rich-dad-poor-dad-a1b2c3
source_ref: "[[Notes/NotebookLM/rich-dad-poor-dad-a1b2c3/Sources/Rich Dad Poor Dad]]"
source_type: pdf
related:
  - "[[Notes/NotebookLM/rich-dad-poor-dad-a1b2c3]]"
---

# Learning Method — Rich Dad Poor Dad

## Framework
Source-driven adaptive learning via NotebookLM. All claims verified with `nlm notebook query`; citations resolve to passages in the source PDF.

## Approach
Conceptual rings. Start with Cashflow Quadrant (core mental model), ring outward to Assets vs Liabilities, then Tax Strategy, then Mindset chapters.

## Key Terms
- Cashflow Quadrant: four income archetypes — E, S, B, I
- Asset: puts money in your pocket (per this source's definition)
- Liability: takes money out of your pocket
- Financial literacy: ability to read financial statements + distinguish asset from liability

## Learning Path
| Phase | Focus | Status |
|-------|-------|--------|
| 1. Diagnose | Prior knowledge of financial literacy | Complete |
| 2. Cashflow Quadrant | Four income categories, tradeoffs | In progress |
| 3. Assets vs Liabilities | Kiyosaki's definition, household examples | Pending |
| 4. Tax Strategy | B and I quadrant advantages | Pending |
| 5. Mindset | Poor-dad vs rich-dad framing | Pending |

## Progress by Topic
| Topic | Date | SOLO Level | Key Scenarios | QA Note |
|-------|------|------------|---------------|---------|
| Cashflow Quadrant | 2026-04-21 | Relational | "Which quadrant is a freelance dev? A W-2 engineer moonlighting on a SaaS?" | [[2026-04-21 Cashflow Quadrant]] |

## QA Notes Index
| File | Topic | Key Insight |
|------|-------|-------------|
| `2026-04-21 Cashflow Quadrant.md` | Cashflow Quadrant | E and S trade time for money; B and I build systems that trade for them |

## Cross-Session Mistake Tracker
| Mistake | Correction | Topic |
|---------|-----------|-------|
| "Assets = things you own" | "Assets put money IN your pocket; liabilities take money OUT — per Kiyosaki's accounting definition" | Assets vs Liabilities |

## Last Session
- **Date:** 2026-04-21
- **Ended at:** Phase 2, Cashflow Quadrant topic, Relational level
- **Next:** Phase 3 — Assets vs Liabilities, starting with diagnose
```

## Why markdown, not JSON

- The `learn` plugin's multi-session continuity check searches for the string `Learning Method` in the learner's vault — this is a markdown-native search, not a JSON traversal
- The `notebooklm` plugin ships with Dataview conventions; frontmatter-typed markdown integrates with the user's existing dashboards
- Users can hand-edit a markdown file if it gets corrupted; JSON is less forgiving and offers no human reading value
- Tables render inline in Obsidian — the learner can see their own progress without running a query

Keep the file append-only for the mistake tracker and progress table. Never delete rows — past mistakes are the point of the tracker.
