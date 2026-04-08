---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "Trending AI Repos 2026 — MicroGPT"
tags: [ai, education, karpathy, transformer]
---

# MicroGPT — A Complete GPT in 200 Lines

> Karpathy's ~200-line pure Python implementation of a complete GPT. Zero dependencies — no PyTorch, no NumPy. The "culmination of a decade-long obsession" to simplify LLMs to their essence.

## What's Inside (All in 200 Lines)

| Component | Purpose |
|-----------|---------|
| Dataset | 32,000 names for training |
| Tokenizer | Character-level (each letter = one token) |
| Autograd Engine | Automatic differentiation (backpropagation) |
| Neural Network | GPT-2-like transformer architecture |
| Adam Optimizer | Weight update algorithm |
| Training Loop | Teaches the model |
| Inference Loop | Generates new text |

## Why It Matters

Strips away every abstraction to reveal the pure algorithm. Part of Karpathy's educational lineage: micrograd → makemore → [[nanoGPT Training Framework|nanoGPT]] → MicroGPT (final form).

## Related Pages

- [[nanoGPT Training Framework]]
- [[llm.c Pure C Training]]
- [[Autoresearch Autonomous ML]]

## Sources

- Trending AI Repos 2026 — MicroGPT
- [Karpathy's blog post](http://karpathy.github.io/2026/02/12/microgpt/)
