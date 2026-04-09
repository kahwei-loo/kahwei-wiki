---
created: 2026-04-09
updated: 2026-04-09
sources:
  - "Mastra AI official blog, GitHub, Observational Memory paper"
tags: [ai, agent, framework, typescript, memory]
---

# Mastra — TypeScript Agent Framework

> The TypeScript-native agent framework with a novel "Observational Memory" system — two background agents compress conversation history into dense observation logs (5-40x smaller, no vector DB needed). 22K+ stars, 300K+ weekly npm downloads. 94.87% on LongMemEval.

## Why Mastra Matters

Fills a critical gap: most agent frameworks are Python-first (LangGraph, CrewAI, AutoGen, Letta). Mastra is **TypeScript-native**, designed for the Next.js / Vercel / Node.js ecosystem.

## Observational Memory (Key Innovation)

Traditional memory: store raw messages → embed → vector search → retrieve.
Mastra's approach: **two background agents compress old messages into dense observation logs**.

### Architecture

```
Messages accumulate during conversation
        ↓ (threshold reached)
┌─────────────────────────┐
│ Observer Agent           │
│ Compresses messages into │
│ dense observation logs   │
│ (5-40x smaller)          │
└──────────┬──────────────┘
           ↓
┌─────────────────────────┐
│ Reflector Agent          │
│ Condenses observations   │
│ into higher-level        │
│ reflections              │
└──────────┬──────────────┘
           ↓
  Observations + Reflections
  injected into system prompt
  (prompt-cacheable!)
```

### Key Design Decisions

| Decision | Why |
|----------|-----|
| **No vector DB** | Observations are text, injected directly into prompt. Simpler infrastructure |
| **Cache-friendly** | Full cache hits on every turn until next observation run. Major cost savings |
| **Two-stage compression** | Observer (raw → observations) + Reflector (observations → reflections). Progressive abstraction |
| **5-40x compression** | A 50-message conversation becomes 2-3 observation paragraphs |

### Benchmark

**94.87% on LongMemEval** — competitive with [[Mem0 Memory Architecture|Mem0]] and [[Agent Memory Systems|Letta]] while requiring zero additional infrastructure (no vector DB, no graph DB).

## Comparison with Other Memory Approaches

| | Mastra | Mem0 | Letta | Claude Code |
|---|---|---|---|---|
| Approach | Background agent compression | LLM extraction → vector + graph | Three-tier (Core/Recall/Archival) | 7-layer + autoDream |
| Infrastructure | None (text in prompt) | Vector DB + optional graph DB | Vector DB + agent runtime | File-based (MEMORY.md) |
| LongMemEval | 94.87% | ~90% | ~92% | N/A |
| Language | TypeScript | Python + JS | Python | TypeScript (internal) |
| Cache-friendly | Yes (designed for it) | No | No | Partially (MEMORY.md) |

## When to Use Mastra

| Scenario | Use Mastra? |
|----------|------------|
| TypeScript / Next.js stack | **Yes** — native ecosystem |
| Need memory without extra infrastructure | **Yes** — no vector DB needed |
| Python stack | No → use LangGraph or Letta |
| Need graph-based memory (entity relationships) | No → use [[Mem0 Memory Architecture|Mem0]] |
| Need maximum framework flexibility | Maybe → LangGraph is more flexible |
| Building a product on Vercel | **Yes** — natural fit |

## Related Pages

- [[Agent Memory Systems]]
- [[Mem0 Memory Architecture]]
- [[Multi-Agent Architecture Patterns]]
- [[AI Product Architecture]]

## Sources

- [Mastra AI](https://mastra.ai/)
- [Observational Memory Blog Post](https://mastra.ai/blog/observational-memory)
- [GitHub: mastra-ai/mastra](https://github.com/mastra-ai/mastra)
