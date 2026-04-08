---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "Trending AI Repos 2026 — LLM-C"
tags: [ai, training, karpathy, systems, advanced]
---

# llm.c — LLM Training in Pure C/CUDA

> Karpathy's ~2000-line C/CUDA implementation that trains GPT-2 at speeds matching PyTorch. No Python, no frameworks — just raw metal. The definitive resource for understanding LLM training at the hardware level.

## Performance

```
PyTorch GPT-2 training: 80ms/iter
llm.c GPT-2 training:   78ms/iter (on A100)
```

Same results. No 245MB PyTorch. No 107MB Python runtime. Single compiled binary.

## Why It Exists

Strips away every abstraction until only the essential math and GPU operations remain. If you want to understand how training works at the **hardware level**, this is it.

## Karpathy's Educational Stack

| Project | Language | Lines | Level | Purpose |
|---------|----------|-------|-------|---------|
| [[MicroGPT Educational LLM\|MicroGPT]] | Pure Python | ~200 | Beginner | Understand the algorithm |
| [[nanoGPT Training Framework\|nanoGPT]] | Python + PyTorch | ~600 | Intermediate | Train real models |
| **llm.c** | C/CUDA | ~2000 | Advanced | Hardware-level understanding |

## Related Pages

- [[MicroGPT Educational LLM]]
- [[nanoGPT Training Framework]]
- [[Autoresearch Autonomous ML]]

## Sources

- Trending AI Repos 2026 — LLM-C
- [GitHub: karpathy/llm.c](https://github.com/karpathy/llm.c)
