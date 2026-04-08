---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "Trending AI Repos 2026 series"
tags: [ai, education, karpathy, training, transformer]
---

# Karpathy's LLM Education Stack

> A progression of four projects that strip away abstractions layer by layer, from pure Python to bare C/CUDA. Together they form the most complete open-source curriculum for understanding LLMs from algorithm to hardware.

## The Stack (Increasing Depth)

| Project | Language | Lines | Dependencies | Level | What You Learn |
|---------|----------|-------|-------------|-------|----------------|
| **MicroGPT** | Pure Python | ~200 | **Zero** | Beginner | The complete algorithm — autograd, transformer, training, inference |
| **nanoGPT** | Python + PyTorch | ~600 | PyTorch | Intermediate | How to train real models (reproduces GPT-2 124M) |
| **llm.c** | C / CUDA | ~2,000 | None | Advanced | Hardware-level training — what happens on the GPU |
| **Autoresearch** | Python + Agent | Variable | GPU + LLM API | Applied | AI-driven ML research — automated experiment loops |

## MicroGPT: The Algorithm (200 Lines, Zero Dependencies)

A single Python file containing everything needed to build a working language model:
- Dataset (32K names), character-level tokenizer
- Custom autograd engine (backpropagation from scratch)
- GPT-2-like transformer architecture
- Adam optimizer, training loop, inference loop

**Why it exists**: "Strip away everything that isn't essential. What's left is the pure algorithm." The culmination of Karpathy's decade-long simplification: micrograd → makemore → nanoGPT → MicroGPT.

## nanoGPT: Real Training (600 Lines)

Two files: `train.py` (~300 lines) and `model.py` (~300 lines). Can reproduce GPT-2 (124M parameters) on OpenWebText.

**Successor**: nanochat (late 2025) — "The best ChatGPT that $100 can buy." nanoGPT is legacy but remains the gold standard for learning.

## llm.c: The Hardware Level (2,000 Lines C/CUDA)

Trains GPT-2 in pure C/CUDA at speeds matching PyTorch (78ms/iter vs 80ms/iter on A100). No Python, no frameworks — single compiled binary.

**If you want to understand what actually happens when you call `loss.backward()`**, this is the definitive resource.

## Autoresearch: AI Does the Research

The most provocative project. An AI coding agent that:
1. Reads research directions in `program.md` (plain English)
2. Modifies training code autonomously
3. Trains for 5 minutes per experiment
4. Keeps improvements, discards failures
5. Runs ~12 experiments/hour, ~100 overnight

**Real results** (2 days, ~700 autonomous changes): Found ~20 additive improvements, dropped "Time to GPT-2" from 2.02h to 1.80h (11% gain). All discovered by AI.

Represents [[AI Automation Maturity L1-L5|L4-level]] automation for ML research — human sets direction, AI explores the space.

## Related Pages

- [[AI Automation Maturity L1-L5]]
- [[Open Source LLM Landscape 2026]]

## Sources

- [MicroGPT blog post](http://karpathy.github.io/2026/02/12/microgpt/)
- [GitHub: karpathy/nanoGPT](https://github.com/karpathy/nanoGPT)
- [GitHub: karpathy/llm.c](https://github.com/karpathy/llm.c)
- [GitHub: karpathy/autoresearch](https://github.com/karpathy/autoresearch)
- [Fortune: The Karpathy Loop](https://fortune.com/2026/03/17/andrej-karpathy-loop-autonomous-ai-agents-future/)
