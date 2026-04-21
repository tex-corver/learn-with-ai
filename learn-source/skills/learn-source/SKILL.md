---
name: learn-source
description: "Learn from one local file (PDF, markdown, txt) with full source grounding: ingests into NotebookLM, runs adaptive Bloom's / SOLO teaching with every claim cited, per-source progress in Obsidian. Use when user says \"learn-source\", \"learn from this file\", \"study this PDF\", \"teach me this book\", \"learn document\", \"cited learning\", or passes a file path. Not for /learn <topic> or \"learn codebase <path>\"."
argument-hint: <path-to-file> [resume]
---

# Learn from a Local Source

Take one local file, turn it into a NotebookLM notebook, and learn from it with full citation grounding. This skill is an orchestration layer: it composes the `notebooklm` plugin (for ingestion + cited QA) and the `learn` plugin (for pedagogy), adding a preamble contract and a per-source progress file.

## Prerequisites

| Check | Condition | On failure |
|-------|-----------|------------|
| `nlm` CLI installed | `command -v nlm` | Abort. Hint: `uv tool install notebooklm-mcp-cli` |
| `nlm` authenticated | `nlm login --check` exits 0 (fallback: `nlm auth status` for older CLI builds) | Abort. Point user to `notebooklm/skills/notebooklm/workflows/auth.md` |
| `notebooklm` plugin available | `${CLAUDE_PLUGIN_ROOT}/../notebooklm/skills/notebooklm/workflows/ask.md` exists | Warn (`warnings: ["notebooklm_missing"]`). Consolidation still works, but QA notes will lack resolved citations |
| `learn` skill available | `${CLAUDE_PLUGIN_ROOT}/../learn/skills/learn/SKILL.md` exists | Abort (`missing: ["learn_skill"]`). Hint: install `learn` from the same marketplace |
| Vault writable | cwd is writable, `Notes/` folder exists in cwd or a parent | Warn. Fall back to `~/.claude/learn-source/<slug>-root/` |
| File exists and readable | `[ -r <path> ]`, extension in `{pdf, md, markdown, txt}` | Abort with the offending path |
| File size sane | size under ~50 MB | Warn only |

Run the preflight script once at session start and parse its JSON output:

```text
!`bash ${CLAUDE_PLUGIN_ROOT}/skills/learn-source/scripts/check_prereqs.sh "${1:-}" 2>/dev/null || echo '{"ok":false,"missing":["preflight_failed"]}'`
```

If `ok` is false and `missing` contains any hard-fail key (`nlm`, `nlm_auth`, `learn_skill`, `file_not_readable`, `unsupported_extension`), abort and print the hint. Warnings (including `notebooklm_missing`) are surfaced to the user but do not block. When a file path is given, the script also emits `"slug": "<canonical-slug>"` — use that value directly rather than recomputing.

## Quick Start

```text
# New session, PDF ingest
/learn-source ~/Documents/rich-dad-poor-dad.pdf

# Resume an existing session for the same file
/learn-source ~/Documents/rich-dad-poor-dad.pdf resume

# No path: offer a vault Learning Method index picker
/learn-source resume
```

## Inputs

| Argument | Required | Meaning |
|----------|----------|---------|
| `<path-to-file>` | Yes (unless `resume` alone) | Absolute or relative path to a PDF, markdown, or text file |
| `resume` | Optional | If present, look up an existing notebook for this file's slug before ingesting |

The argument-hint is `<path-to-file> [resume]`. If the user invokes with a path that already has a notebook in NotebookLM (slug match), treat as resume even without the flag — idempotent re-runs must not create duplicate notebooks.

## Workflow

### 1. Preflight check

Run the prereq script (see above). Abort on hard failures with the returned hints. For a vault-writability warning, offer to fall back to `~/.claude/learn-source/<slug>-root/`; see [Vault-less Fallback](#vault-less-fallback).

### 2. Resolve or create notebook

The preflight script emits `"slug"` when a file path is passed — prefer that value. If for any reason you must compute it yourself, use this exact procedure (the ONLY canonical slug; do not deviate, idempotency across sessions depends on byte-for-byte equivalence):

```bash
stem=$(basename "$1" | sed 's/\.[^.]*$//')
kebab=$(printf '%s' "$stem" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
# md5sum on Linux; md5 -q on macOS
if command -v md5sum >/dev/null; then hash=$(md5sum "$1" | cut -c1-6)
elif command -v md5 >/dev/null; then hash=$(md5 -q "$1" | cut -c1-6); fi
slug="${kebab}-${hash}"
display_name=$(printf '%s' "$stem")   # the raw stem; title-case presentation is optional
```

Slug stability matters because it is the join key between the notebook, the vault folder, and the progress file. Two users with the same filename but different content get different slugs; the same user re-running `/learn-source` on the same file gets the same slug and the same notebook every time.

List existing notebooks and look for a match on display_name (NotebookLM's list does not expose a slug field, so we match on title):

```bash
nlm notebook list --json
```

| Found | Action |
|-------|--------|
| Yes | Reuse `notebook_id`. Skip upload. Proceed to step 4 (resume path). |
| No | `nlm notebook create "<display_name>"` — parse `notebook_id` from stdout |

The stdout format of `nlm notebook create` may vary by CLI version. Test once manually at install time; if `--json` is supported on `create`, prefer it for parsing. Example regex parse for the UUID in stdout:

```bash
nb_id=$(nlm notebook create "$display_name" | grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | head -1)
```

### 3. Upload source (only if the notebook is new)

```bash
nlm source add <notebook_id> --file <path> --title "<display_name>" --wait
nlm source list <notebook_id> --json > /tmp/learn-source-sources.json
```

The `--wait` flag blocks until NotebookLM has indexed the file. Large PDFs may take several minutes. If the user wants a fast path, skip `--wait` and poll `source list` before the first query.

### 4. Ensure vault folders and the Learning Method file

Create the co-located folder layout under the vault root (cwd unless overridden):

```text
Notes/NotebookLM/<slug>/
  Sources/       # from notebooklm ingestion — may already exist
  QA/            # from notebooklm ask workflow — may already exist
  Learning/
    Learning Method.md   # THIS plugin writes here
```

On a fresh session, write an initial `Learning Method.md` populated from the schema in `references/progress-schema.md`. On resume, read the existing file and extract the progress tables, mistake tracker, and last-session pointer — pass them into the preamble so `/learn` can skip re-teaching.

### 5. Invoke `/learn` with a binding preamble

Read `references/preamble.md` and substitute the placeholders (`{notebook_id}`, `{notebook_slug}`, `{learning_method_path}`, `{source_title}`). Hand control to the `learn` skill:

| Handoff mechanism | Primary / Fallback |
|-------------------|---------------------|
| Skill tool: `Skill(skill="learn", args="<preamble>\n\n<user intent>")` | **Primary** — clean, structured, namespace-aware |
| Instructional handoff: emit *"Now follow `skills/learn/SKILL.md`, treating the notebook at ID `<id>` as source of truth; progress file at `<path>`"* and let the agent continue | **Fallback** — use if Skill tool fails to resolve `learn` |

If neither the plain name `learn` nor the namespaced forms (`learn-with-ai:learn`, `learn:learn`) resolve, abort with a clear install hint — the pedagogy is not something we inline.

Do NOT inline any of the `/learn` Phase 1-4 content. `/learn` is the source of truth for the workflow; `learn-source` only supplies the preamble.

### 6. During the session: verify claims, persist QA

While `/learn` runs, the preamble directs it to verify non-obvious factual claims against the notebook before asserting them. The verification call is:

```bash
nlm notebook query <notebook_id> "<question>" --json
```

To keep cost and context under control:

- Batch 3-5 related claims per query (one question covering several sub-points)
- Cache results within a session — do not re-query the same phrasing
- Reserve verification for domain-specific facts. Basic vocabulary, arithmetic, and obvious definitions do not need citation
- When the learner asserts something, verify against the notebook before accepting or correcting — source-grounded feedback trumps the tutor's memory

| Claim type | Verify? | Example |
|------------|---------|---------|
| Domain-specific fact from the source | Yes | "What four quadrants does Kiyosaki define in the Cashflow Quadrant chapter?" |
| Concept definition new in this source | Yes | "How does the source define 'asset' vs 'liability'?" |
| Numerical example or case study | Yes | "What is the net worth calculation example on page 42?" |
| General mathematics or logic | No | Arithmetic, standard definitions, obvious syllogisms |
| Learner's personal context | No | Their job, their spending habits, their goals |

For aha-moment QA persistence (when `/learn` wants to save a cited answer as a vault note), delegate to the `notebooklm` plugin's `ask` workflow with `notebook-slug=<slug>`. That workflow writes to `Notes/NotebookLM/<slug>/QA/<date> <title>.md` with citation resolution — `learn-source` does not duplicate that pipeline.

### 7. On consolidate: update the Learning Method file

When `/learn` triggers consolidation (learner says "consolidate" or a topic ends):

1. The `notebooklm` ask workflow writes the QA note to the `QA/` folder
2. `learn-source` updates `Learning Method.md`:
   - Append a row to the Progress by Topic table with SOLO level and QA note link
   - Append new mistakes to the Cross-Session Mistake Tracker
   - Update the QA Notes Index and the Last Session pointer
3. Show the updated progress table to the learner

See `references/progress-schema.md` for required fields and the full table layout.

## Resume Behavior

Resume is the default path once a source has been ingested. `/learn-source` should never re-upload a file that already exists as a source in a matching notebook, and should never overwrite an existing `Learning Method.md` without reading it first.

On `resume` (explicit flag, or detected by slug match):

| Step | Action |
|------|--------|
| 1 | Look up notebook by slug via `nlm notebook list --json` |
| 2 | Read `Learning Method.md` — extract progress tables, mistake tracker, last-session pointer |
| 3 | Inject prior progress into the preamble so `/learn` can show it to the learner |
| 4 | Instruct `/learn` to run Phase 1 diagnose first, even on resume — confirm retained knowledge before re-teaching |
| 5 | Offer the learner: continue where we left off, recall quiz first, or jump to a specific topic |

If the vault has a `Learning Method.md` but no matching notebook (or vice versa), warn the user — the two are meant to be co-located. Recreate the missing side rather than fail hard.

## Preamble Template

The preamble passed to `/learn` lives in [`references/preamble.md`](references/preamble.md). It is a plain markdown instruction block with placeholders. Read the file, substitute, then feed as the first argument (or prepend to args) when invoking the `learn` skill.

## Progress File Schema

The `Learning Method.md` schema lives in [`references/progress-schema.md`](references/progress-schema.md). It extends the `learn` plugin's consolidation template with three NotebookLM-specific frontmatter fields: `notebook_id`, `notebook_slug`, `source_ref`.

## Vault-less Fallback

If the preflight reports no writable vault (`Notes/` not found in any parent of cwd, or cwd not writable), fall back to a root that mirrors the in-vault layout, so `notebooklm`'s `resolve_citations.py` (which hardcodes `Notes/NotebookLM/<slug>/Sources/` relative to `--vault`) still works:

```text
~/.claude/learn-source/<slug>-root/        # pass as --vault
  Notes/NotebookLM/<slug>/
    Sources/                               # notebooklm ingestion writes here
    QA/                                    # cited answers land here
    Learning/Learning Method.md            # THIS plugin writes here
```

Pass `--vault ~/.claude/learn-source/<slug>-root` to the `notebooklm` ask workflow so substring citation resolution against `Sources/` succeeds. Tell the user up front: "no Obsidian vault detected; progress will be stored at `~/.claude/learn-source/<slug>-root/Notes/NotebookLM/<slug>/`."

## Handoff to `/learn`

This is the load-bearing integration point. The preamble must be delivered as structured context to the `learn` skill, not emitted as prose that the next turn's model might ignore.

### Primary: Skill tool invocation

```text
Skill(skill="learn", args="""
<preamble content here — substituted>

---

Now: run your standard Phase 1 diagnose. The user has invoked /learn-source on <source_title>. Treat the NotebookLM notebook ID <notebook_id> as source of truth per the preamble above.
""")
```

The Skill tool carries the args as a prompt-level context injection. The `learn` skill's first turn sees the preamble and proceeds with its standard workflow.

### Fallback: instructional handoff

If Skill-tool invocation fails (skill not found under any resolvable name, argument too long, etc.), emit an explicit instruction:

> "Now read and execute `skills/learn/SKILL.md` from the `learn` plugin. Treat the NotebookLM notebook at ID `<notebook_id>` (slug `<slug>`) as single source of truth. Progress file: `<learning_method_path>`. Verify non-obvious claims with `nlm notebook query <notebook_id> "..." --json` before asserting them."

The fallback depends on the running agent honoring the instruction. It is less robust than the Skill-tool primary, but has no setup requirements.

### Which namespace resolves

`/learn`'s skill name may resolve as bare `learn`, `learn-with-ai:learn`, or something else depending on how the marketplace was installed. Try in order: bare name → marketplace-qualified name. Abort only if both fail.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `nlm: command not found` | CLI not installed | `uv tool install notebooklm-mcp-cli` |
| `nlm login --check` fails | Not authenticated or cookie expired | `nlm login` (or `nlm auth login` on older CLI), then retry |
| `source add --wait` hangs > 10 min | Large PDF, NotebookLM indexing slow | Drop `--wait`, poll `source list` until source shows ready |
| Duplicate notebook created | Slug not stable across runs | Verify md5 hash of the file did not change; check `nlm notebook list --json` for accidental duplicates |
| `/learn` does not pick up the preamble | Skill tool did not resolve `learn` | Use the Fallback handoff — instructional emit |
| QA notes land in wrong folder | `notebooklm` ask workflow called without `--vault` pointing at the right root | Pass `--vault "$(pwd)"` and `--slug <notebook_slug>` explicitly |
| Progress file lost / corrupted | Manual edit or file system issue | The frontmatter is self-describing — recreate by re-running; the notebook is unaffected |

## Non-goals

- Not a replacement for `/learn` on plain topics. If the learner has no file, they should use `/learn` directly.
- Not a bulk loader. For YouTube channels or multi-source notebooks, use `notebooklm/workflows/youtube-channel.md`.
- Not a URL loader. Direct URL ingestion is `nlm source add --url`; this skill is for local files only.
- Not a generic QA tool. For free-form questions against a notebook, use `notebooklm/workflows/ask.md`.
- Not an audio or video ingestion path. Those go through NotebookLM's native channel loading.
- Not a multi-source synthesizer. One file, one notebook, one learner. If you want to learn across several files, load them into a single notebook via `notebooklm` and then invoke `/learn` directly with a manual preamble.

## See Also

- [`references/preamble.md`](references/preamble.md) — the handoff template
- [`references/progress-schema.md`](references/progress-schema.md) — Learning Method file format
- [`scripts/check_prereqs.sh`](scripts/check_prereqs.sh) — preflight checker
- [`../../../../learn/skills/learn/SKILL.md`](../../../learn/skills/learn/SKILL.md) — the pedagogy this skill delegates to
- [`../../../../notebooklm/skills/notebooklm/workflows/ask.md`](../../../notebooklm/skills/notebooklm/workflows/ask.md) — cited QA pipeline
