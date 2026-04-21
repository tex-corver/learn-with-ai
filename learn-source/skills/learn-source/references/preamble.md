# Preamble Template for `/learn` Handoff

This file is read by `learn-source` and passed to the `learn` skill as a prompt-level context injection. Substitute the placeholders before handoff. All four placeholders are required.

## Placeholders

| Token | Meaning |
|-------|---------|
| `{notebook_id}` | Full NotebookLM notebook UUID (e.g. `2a18a53d-be60-4951-af17-8b7303dc097e`) |
| `{notebook_slug}` | Kebab-case slug used for vault folder naming (e.g. `rich-dad-poor-dad-a1b2c3`) |
| `{learning_method_path}` | Absolute or vault-relative path to `Learning Method.md` for this source |
| `{source_title}` | Display title of the source, as written on the vault source file and notebook index |

## Template

```text
You are running the `/learn` adaptive learning workflow, invoked via `/learn-source` with a specific local file as the subject. Follow these binding rules for this session, then run your standard SKILL.md flow.

Source of truth
  - The NotebookLM notebook with ID `{notebook_id}` (slug: `{notebook_slug}`) is the ONLY authoritative source for factual claims about {source_title}.
  - Before asserting a non-obvious factual claim about this source, call:
      nlm notebook query {notebook_id} "<question>" --json
    and ground the assertion in the returned citations.
  - Batch 3-5 related claims per query to control cost. Example: "What does the source say about (a) the Cashflow Quadrant, (b) asset/liability definitions, and (c) tax-strategy differences?" — one query, three claims cited together.
  - If you already called `nlm notebook query` with question Q this session, reuse the answer from context; do NOT re-query the same phrasing.
  - Obvious arithmetic, standard definitions, and personal learner context do not need verification. Domain-specific facts, named concepts introduced in the source, numerical examples, and chapter-specific arguments do.

Progress file
  - The Learning Method / progress file for this source is at `{learning_method_path}`.
  - At session start: read this file. It contains the progress table, mistake tracker, QA notes index, and last-session pointer. Use them to avoid re-teaching covered material and to pick up at the right SOLO level.
  - On consolidate: update this file. Append to the Progress by Topic table (with SOLO level and QA note link), append any new mistakes to the Cross-Session Mistake Tracker, and update Last Session and QA Notes Index.

Cited QA persistence
  - When a topic consolidates or the learner has an aha moment you want to preserve as a vault QA note, delegate to the `notebooklm` plugin's `ask` workflow with:
      notebook-slug = {notebook_slug}
      notebook-id   = {notebook_id}
    That workflow runs `nlm notebook query` and then `resolve_citations.py`, producing a QA note with `[N]` citations resolved to block references in the source transcript. Do NOT reimplement citation resolution inline.

Phase 1 is mandatory
  - Run your Phase 1 diagnose step first, even on resume. Prior progress in `{learning_method_path}` tells you what has been covered; the diagnostic confirms what has been retained. Skipping Phase 1 on resume is not permitted, even if the learner says "just continue." One diagnostic question is the contract.

All other behavior
  - Follow `skills/learn/SKILL.md` as written. Your taxonomies, phases, interleaving rhythm, anti-patterns, and consolidation template are unchanged. The only deltas are the four rules above.
```

## Notes on delivery

- When passed via the Skill tool, the whole template (post-substitution) should be the `args` string, optionally followed by a short "Now: begin Phase 1" closer.
- When passed via instructional handoff (fallback), emit the template verbatim in a fenced block so the next-turn model treats it as a binding instruction, not suggestion.
- Keep the preamble under ~500 tokens after substitution. It lives in the `learn` session's context for the full session.
