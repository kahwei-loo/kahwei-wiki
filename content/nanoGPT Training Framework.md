---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "[[30 Resources/Trending AI Repos 2026/08-NanoGPT]]"
tags: [ai, education, karpathy, training]
---

# nanoGPT — Training Framework

> The simplest, fastest repo for training medium-sized GPTs. Entire codebase is ~600 lines across two files. Can reproduce GPT-2 (124M params) on OpenWebText. Legacy but remains the gold standard for learning LLM training.

## Structure

| File | Lines | Purpose |
|------|-------|---------|
| `train.py` | ~300 | The training loop |
| `model.py` | ~300 | The GPT model definition |

## Key Distinction

- **nanoGPT**: Train real models (~600 lines, needs PyTorch + GPU)
- **[[MicroGPT Educational LLM|MicroGPT]]**: Understand the algorithm (~200 lines, zero dependencies)
- **[[llm.c Pure C Training|llm.c]]**: Train at hardware level (~2000 lines C/CUDA)

## Successor

**nanochat** (late 2025): "The best ChatGPT that $100 can buy" — nanoGPT is legacy but remains the best starting point for learning.

## Related Pages

- [[MicroGPT Educational LLM]]
- [[llm.c Pure C Training]]
- [[Autoresearch Autonomous ML]]

## Sources

- [[30 Resources/Trending AI Repos 2026/08-NanoGPT]]
- [GitHub: karpathy/nanoGPT](https://github.com/karpathy/nanoGPT)
