# Scenario Techniques

Advanced questioning techniques for Phase 3 (Question) and Phase 4 (Challenge). Read this file when the learner reaches Multistructural level or above and you need richer exercises than basic Socratic questioning.

---

## Realistic Scenarios

The strongest learning moments come from scenarios with **multiple competing variables** — not clean textbook problems. The learner must weigh tradeoffs and justify their reasoning.

### How to Design a Good Scenario

1. **Include 3-5 real-world constraints** — org size, team skills, regulatory pressure, time, cost, existing infrastructure
2. **Make the answer genuinely debatable** — if there's one obvious right answer, it's not a good scenario
3. **Require justification** — grade on reasoning quality, not conclusion
4. **After they answer, reveal which variable they underweighted** — this creates strong "prediction error" memories

### Scenario Structure

```
> Context: [Set the scene with specific details — company type, team size,
> constraints, existing systems. Make it feel real.]
>
> [The decision-maker] asks: "[A concrete question with real stakes]"

Your task:
1. What's your recommendation?
2. What's the strongest argument AGAINST your recommendation?
3. What concrete condition would make you change your mind?
```

Questions 2 and 3 are where Extended Abstract thinking lives. Most learners answer Q1 and skip the rest — push them to complete all three.

### Example Scenarios by Domain

**Architecture decision:**
> A startup (5 engineers, 2-month deadline) needs dashboards for sales.
> Build a custom lakehouse or use Snowflake?
> Variables: team size, ops burden, time, cost trajectory, vendor lock-in

**Governance decision:**
> A hospital needs a data platform. Patient records (PII), billing,
> research, IoT sensors. Data Mesh or centralized warehouse?
> Variables: team maturity, regulation (HIPAA), engineering capacity, domain count

**Technical decision:**
> E-commerce fraud detection, 24/7 transactions, must block before payment.
> Batch or streaming? Centralized or domain-owned?
> Variables: latency floor, domain expertise, monitoring vs ownership

### Grading Realistic Scenarios

| SOLO Level | What the answer looks like |
|------------|--------------------------|
| Unistructural | Names one option without reasoning |
| Multistructural | Lists pros of chosen option, ignores tradeoffs |
| Relational | Weighs multiple variables, explains WHY this choice for THIS context |
| Extended Abstract | Argues both sides, identifies trigger points for changing the decision, applies to new contexts |

---

## Steelman Exercise

After the learner makes a recommendation, ask them to argue the **opposite side** as convincingly as possible. This builds nuanced thinking and prevents "one right answer" mentality.

### When to Use

- After any architecture/design recommendation
- When the learner seems overly confident in their choice
- When they dismiss alternatives without engaging with them
- At Phase 4 (Challenge) for Relational-level learners pushing toward Extended Abstract

### The Three-Part Steelman

1. **"What's the strongest argument AGAINST your recommendation?"**
   - They must make the opposing case genuinely convincing
   - If they give a weak strawman, push: "That's easy to dismiss. What would a senior architect actually say?"

2. **"What concrete conditions would make you SWITCH your recommendation?"**
   - Forces them to identify the decision boundaries
   - Good answers name specific thresholds: "If the team grew past 20...", "If compliance required..."

3. **"Who in the room would disagree with you, and why?"**
   - Role-based perspective-taking: the CIO, the security lead, the data scientist, the finance team
   - Each role has different priorities that weight the tradeoffs differently

### Common Failure Modes

| Failure | What it reveals | How to probe |
|---------|----------------|-------------|
| Can't steelman at all | Hasn't understood the tradeoffs | Go back to teaching — they need more knowledge before they can weigh |
| Gives a weak strawman | Understands surface but not depth | "That's easy to dismiss. What would a senior [role] actually say?" |
| Steelmans well but can't identify switch conditions | Relational but not yet Extended Abstract | Ask: "At what team size / budget / deadline does your answer flip?" |
| Steelmans AND identifies conditions | Extended Abstract | Celebrate — this is the goal. Push to a new domain to test transfer. |

---

## Cross-Domain Transfer

The ultimate test of understanding: apply concepts from one domain to a completely different one.

### When to Use

- When the learner is solidly Relational and you want to push to Extended Abstract
- After completing a breadth-first overview of multiple areas
- When you want to test whether understanding is genuine or domain-memorized

### How It Works

1. Teach a concept in Domain A (e.g., "batch is a one-way door for latency" in data engineering)
2. Present a scenario in Domain B where the same principle applies (e.g., "microservices: synchronous REST is a one-way door for coupling")
3. Ask: "How does the principle from [Domain A] apply here?"

If they can transfer the principle, they truly own it. If they can't, they've memorized it in one context but haven't abstracted it.

---

## Probe Before Correct

When you detect a misconception, **don't immediately correct it**. Instead, ask questions that lead the learner to discover the error themselves. Corrections that come from self-discovery stick much better than corrections that are handed over.

### The Pattern

1. **Detect** — learner says something that contains a misconception
2. **Probe** — ask 2-3 questions that pressure-test the misconception
3. **Wait** — let them reason through the contradiction
4. **Confirm or guide** — if they self-correct, confirm. If they're stuck after 2 attempts, teach directly.

### Example

```
Learner: "We need centralized data because that's the only way to monitor streams."

DON'T: "That's wrong. Monitoring and ownership are different layers."

DO: "Netflix has thousands of microservices owned by different teams, but they 
all report to one observability stack. Is that centralized or decentralized?"
[Let them reason...]
"So is monitoring the same thing as data ownership?"
[Let them connect the dots...]
```

### When to Skip Probing and Just Teach

- The misconception is about a simple fact, not a conceptual confusion
- The learner is at Prestructural/Unistructural — they don't have enough knowledge to reason through probes
- You've already probed twice and they're going in circles — avoid frustration
