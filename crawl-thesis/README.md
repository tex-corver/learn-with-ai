# learn-with-ai

Claude Code plugin — a calibrated, evidence-backed **web-crawling thesis** packaged as a skill + agent + slash command. Distilled from 9 benchmark rounds in the sibling research repo at [`tex-corver/crawl-thesis-share-n-learn`](https://github.com/tex-corver/crawl-thesis-share-n-learn).

## The thesis in one line

> **Free/local tools clear everything up to Cloudflare-managed challenges. DataDome / Kasada / Akamai / application-layer require paid Tier-C infrastructure.**

Full reasoning + evidence: [`essay_deep_dive.md`](https://github.com/tex-corver/crawl-thesis-share-n-learn/blob/master/essay_deep_dive.md) + [`evaluation_r*/`](https://github.com/tex-corver/crawl-thesis-share-n-learn/tree/master) in the research repo. This plugin is just the reusable packaging.

---

## What's in here

| Component | Path | Purpose |
|---|---|---|
| **Skill** — crawl-thesis | `skills/crawl-thesis/` | Our calibrated methodology (4 files) — protection classes, tool stack, calibrated ceiling |
| **Skill** — web-scraper | `skills/web-scraper/` | Upstream phased reconnaissance from [yfe404/web-scraper](https://github.com/yfe404) (MIT, vendored) — the phases `crawl-thesis` composes on top of |
| **Agent** — crawl-specialist | `agents/crawl-specialist.md` | Spawnable sub-agent that runs the thesis end-to-end on any URL |
| **Command** — `/crawl <URL>` | `commands/crawl.md` | One-liner orchestration: probe → classify → extract → validate → report |

---

## Installation — three ways

### 1. As a Claude Code plugin (recommended)

```bash
# From a Claude Code session:
/plugin install tex-corver/learn-with-ai
```

The skill + agent + `/crawl` command auto-register. Works across all your projects.

### 2. Drop into a single project

```bash
cd your-project
mkdir -p .claude
git clone https://github.com/tex-corver/learn-with-ai .claude-tmp
cp -r .claude-tmp/{skills,agents,commands} .claude/
rm -rf .claude-tmp
```

Claude Code auto-discovers `.claude/{skills,agents,commands}` when opened in that directory.

### 3. User-level (every project)

```bash
mkdir -p ~/.claude
git clone https://github.com/tex-corver/learn-with-ai ~/.claude/plugins/learn-with-ai
```

---

## Prerequisites (tool stack)

The thesis assumes a specific tool set on your machine. The `crawl-thesis` skill will fail fast with an installation hint if anything's missing. Required:

- **Scrapling 0.4+** — primary crawling engine (Tier A/B)
- **Scrapy 2.15+** — recurring pipelines
- **Playwright (Node)** + **Chrome DevTools MCP** — JS rendering, network inspection

The research repo has a `make venvs` one-liner that installs all of the above in project-local venvs. For this plugin, you bring your own environment. See [`skills/crawl-thesis/reference/tool-stack.md`](skills/crawl-thesis/reference/tool-stack.md) for the full list and pinned versions.

---

## Calibrated scope

Based on 9 rounds of evidence (see sibling research repo), this thesis works for:

- ✅ Polite public data / documented APIs / SSR blobs
- ✅ Cloudflare Turnstile / managed-challenge sites (verified on real production targets)

This thesis does **not** work (free-tier) for:

- ❌ DataDome-protected sites
- ❌ Kasada v3
- ❌ Akamai Bot Manager
- ❌ Application-layer session signature

For those, the `crawl-specialist` agent will produce an honest Tier-C recommendation (Scrapfly / ZenRows / Bright Data + residential proxies) rather than flailing.

---

## Usage — after install

Inside Claude Code, either say:

```
crawl 30 posts from https://news.ycombinator.com/
```

or use the slash command:

```
/crawl https://news.ycombinator.com/ 30 title,url,score,by,descendants
```

The `crawl-specialist` sub-agent will run Phase 0 (curl probe) → classify protection → execute the right tier → validate → write a mechanism.md report.

---

## License

MIT for original components (`skills/crawl-thesis/`, `agents/`, `commands/`).

`skills/web-scraper/` is redistributed verbatim under yfe404's MIT license. Its original LICENSE + README are preserved in place.

See [LICENSE](LICENSE) for the full notice.

---

## Related

- **Research repo** — [`tex-corver/crawl-thesis-share-n-learn`](https://github.com/tex-corver/crawl-thesis-share-n-learn) — full essay, 9 rounds of benchmark evidence, presenter deck, Makefile installer
- **Live deck** — https://crawl-thesis.urieljsc.com
- **Upstream web-scraper skill** — https://github.com/yfe404
