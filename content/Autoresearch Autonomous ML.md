---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "Trending AI Repos 2026 — Autoresearch"
tags: [ai, ml-research, karpathy, automation]
---

# Autoresearch — Autonomous ML Research

> Karpathy's system that runs ~100 ML experiments overnight on a single GPU using an AI coding agent. Found 20 additive improvements and 11% efficiency gain in two days.

## How It Works

1. Human writes research directions in `program.md` (plain English)
2. AI agent modifies training code
3. Trains for 5 minutes per experiment
4. Keeps improvements, discards failures
5. Repeats — ~12 experiments/hour, ~100 overnight

## Real Results

After two days (~700 autonomous changes):
- Found ~20 additive improvements that transferred to larger models
- Dropped "Time to GPT-2" from 2.02 hours to 1.80 hours (11% gain)
- All discovered entirely by AI

## Why It Matters

Shifts ML research from "human runs one experiment at a time" to "human sets direction, AI explores the space." Represents [[AI Automation Maturity L1-L5|L4-level]] automation for ML research.

## Related Pages

- [[AI Automation Maturity L1-L5]]
- [[MicroGPT Educational LLM]]
- [[nanoGPT Training Framework]]
- [[llm.c Pure C Training]]

## Sources

- Trending AI Repos 2026 — Autoresearch
- [GitHub: karpathy/autoresearch](https://github.com/karpathy/autoresearch)
