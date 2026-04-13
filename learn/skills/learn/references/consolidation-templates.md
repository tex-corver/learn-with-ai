# Consolidation Templates

Templates for QA notes, progress tracking, and mistake tracking. Read this file when the learner asks to "consolidate" or when a topic session completes.

---

## QA Note Template

Every completed topic gets a QA note. The value is in the **reasoning chain**, not the conclusion — never summarize scenarios as one-liners.

```markdown
---
type: qa-capture
status: active
date: YYYY-MM-DD
session: [Topic/Ring name]
solo-level: [Assessed level]
related:
  - "[[Learning Method file]]"
  - "[[Related QA notes]]"
---

# [Topic Title]

## Key Concepts
[Concise reference table or list of what was taught]

## Key Insights
[Principles that emerged from the session — formalized versions of "aha" moments]

## Scenario Q&As

### Q: "[The question that was asked]"

> Context: [scenario setup if applicable]

**My answer:** [What the learner actually said — verbatim or close paraphrase]

**What was right:** [Specific praise for accurate parts]

**Correction:** [What was wrong and why — include the mechanism, not just "wrong"]

**Locked-in insight:** [The principle to remember going forward]

[Repeat for each scenario worked through]

## Mistakes To Not Repeat
[List of specific misconceptions that were corrected, with the correction]
```

### Rules for QA Notes

1. **Every scenario must include the full chain:** my answer → what was right → correction → locked-in insight
2. **Include the learner's original words** — sanitized misconceptions lose their teaching value
3. **Explain WHY the correction matters** — "you said X, but actually Y because Z"
4. **Cross-reference related QA notes** via wikilinks when insights connect

---

## Learning Method / Progress File Template

One per learning journey. Maintains the map of what's been covered, at what level, and what mistakes were corrected.

```markdown
---
type: learning-method
status: active
date: YYYY-MM-DD
related:
  - "[[Primary learning guide or source material]]"
---

# Learning Method — [Subject]

## Framework
[Brief description of learning approach — taxonomies used, rhythm, tools]

## Approach
[Mental model used to organize the subject — e.g., rings, layers, spectrum]

## Key Terms
[10-20 essential vocabulary items with one-liners]

## Learning Path

| Phase | Focus | Status |
|-------|-------|--------|
| 1. [Phase name] | [Description] | [Status] |
| ... | ... | ... |

## Progress by Topic

| Topic | Date | SOLO Level | Key Scenarios |
|-------|------|------------|---------------|
| [Topic 1] | YYYY-MM-DD | [Level] | [Brief scenario names] |
| ... | ... | ... | ... |

## QA Notes Index

| File | Topic | Key Insight |
|------|-------|-------------|
| `[filename].md` | [Topic] | [One-liner] |
| ... | ... | ... |

## Cross-Session Mistake Tracker

| Mistake | Correction | Topic |
|---------|-----------|-------|
| "[What learner said wrong]" | [The correct understanding] | [Which topic] |
| ... | ... | ... |
```

### Rules for Progress Tracking

1. **Update after every consolidation** — don't let it go stale
2. **SOLO levels are per-topic** — the learner can be Relational in one area and Unistructural in another
3. **Mistake tracker is cumulative** — mistakes from all sessions go here
4. **Track scenarios by name** — so the learner can quickly recall what they worked through

---

## Mistake Tracker Guidelines

The mistake tracker serves two purposes:
1. **Prevents repeated errors** — check it before teaching a topic where prior mistakes might resurface
2. **Shows growth** — the learner can see patterns in their misconceptions

### What to track

- Misconceptions that were corrected (e.g., "thought small team → Data Mesh")
- Category confusions (e.g., "confused monitoring with ownership")
- Missing variables (e.g., "forgot regulation as a decision factor")
- Inverted logic (e.g., "got the scaling direction backwards")

### What NOT to track

- Simple factual gaps ("didn't know what DuckDB is") — these are just knowledge, not mistakes
- Correct answers that could be deeper — track growth areas in the session summary instead
