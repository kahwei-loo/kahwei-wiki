---
created: 2026-04-09
updated: 2026-04-09
sources:
  - "Industry practices, LoRA/QLoRA research, distillation patterns"
tags: [ai, fine-tuning, prompting, rag, decision-framework]
---

# Fine-tuning vs Prompting vs RAG

> Start with prompting. Add RAG if knowledge is the gap. Fine-tune only when you have proven demand and clear eval metrics showing the gap. The 2026 consensus: fine-tuning is alive but narrower — primarily for cost optimization at scale (distillation) and specialized domains.

## Decision Tree

```
What's the problem?
│
├─ Model lacks specific knowledge
│  (your docs, recent data, proprietary info)
│  → RAG
│
├─ Model knows how but doesn't do it consistently
│  (formatting, tone, following rules, tool use patterns)
│  → Prompt Engineering
│
├─ Model fundamentally can't do the task well
│  (domain-specific language, specialized classification,
│   consistent style that prompting can't capture)
│  → Fine-tuning
│
└─ Need to run cheaply at massive scale
   (proven demand, clear cost pressure)
   → Distillation + Fine-tuning
```

## When Fine-tuning Is Worth It (2026)

| Use Case | Why Fine-tune | Example |
|----------|--------------|---------|
| **Classification at scale** | Fine-tuned 8B matches GPT-4 at 1/100th cost | Sentiment, intent, toxicity detection |
| **Domain-specific generation** | Strict terminology requirements | Medical/legal/financial text |
| **Consistent style/format** | Pixel-perfect output consistency at millions of calls | Brand voice, structured reports |
| **Latency-critical** | Fine-tuned small model: 10-50ms vs 500ms+ API | Real-time classification in request path |
| **Distillation** | The dominant cost optimization pattern | Large model → training data → small model |

## When Prompting Is Enough

- Task is well-defined and the model "gets it" with good instructions
- Output format can be enforced via structured outputs / JSON mode
- Volume is low enough that API costs are acceptable
- You need flexibility to iterate quickly (prompt changes deploy instantly; fine-tuning takes hours)

## When RAG Is the Answer

- Model needs access to proprietary/recent information it wasn't trained on
- Knowledge changes frequently (docs, product catalog, policies)
- You need citations / source attribution
- See [[RAG Architecture Patterns 2026]] for implementation details

## When RAG Is Overkill

- The knowledge fits in a system prompt (<10K tokens)
- The knowledge is static and rarely changes → embed in prompt, cache it
- You only need a few facts → just put them in the prompt

## Fine-tuning Methods

| Method | VRAM Required | Quality | Speed | Use When |
|--------|--------------|---------|-------|----------|
| **Full fine-tune** | 8x model size | Best | Slow | Budget unlimited, max quality |
| **LoRA** | ~1.5x model size | 95-99% of full | Fast | **Standard production choice** |
| **QLoRA** | ~0.5x model size | 90-97% of full | Moderate | GPU-constrained, experimentation |

**LoRA on Llama 70B**: ~140GB VRAM (2x A100 80GB)
**QLoRA on Llama 70B**: ~40GB VRAM (1x A100 80GB)

For most production use cases, **LoRA is the default**. QLoRA for prototyping.

## The Distillation Pattern

The dominant cost optimization strategy in 2026:

```
1. Use frontier model (Claude Opus, GPT-4o) to generate
   10K-100K high-quality examples for your specific task

2. Fine-tune open-source model (Llama 8B/70B) on these examples
   using LoRA

3. Serve fine-tuned model with vLLM

4. Result: 10-100x cost reduction for that specific task
```

**Requirements**: Clear eval metrics to validate the fine-tuned model matches the frontier model on your specific task. Without evals, you're flying blind.

## Cost Comparison

| Approach | Upfront Cost | Per-Query Cost | Time to Deploy |
|----------|-------------|----------------|----------------|
| Prompting (Sonnet) | $0 | $3-15/M tokens | Minutes |
| RAG + Prompting | $1-5K setup | $3-15/M tokens + infra | 1-2 weeks |
| Fine-tuning (LoRA) | $50-500 (compute) | $0.02-0.5/M tokens (self-hosted) | 1-3 weeks |
| Distillation pipeline | $500-2K (data gen + training) | $0.02-0.05/M tokens | 2-4 weeks |

## Related Pages

- [[Production Prompt Engineering]]
- [[RAG Architecture Patterns 2026]]
- [[LLM Inference and Serving]]
- [[AI Cost Optimization]]

## Sources

- [LoRA paper](https://arxiv.org/abs/2106.09685)
- [QLoRA paper](https://arxiv.org/abs/2305.14314)
- [Hugging Face Fine-tuning Guide](https://huggingface.co/docs/transformers/training)
- [OpenAI Fine-tuning Docs](https://platform.openai.com/docs/guides/fine-tuning)
