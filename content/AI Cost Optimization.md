---
created: 2026-04-09
updated: 2026-04-09
sources:
  - "Anthropic/OpenAI pricing pages, production case studies"
tags: [ai, cost, optimization, production, economics]
---

# AI Cost Optimization

> The three highest-ROI optimizations: prompt caching (90% input savings), model tiering (60-70% requests on cheap tier), and batch API (50% off). Most teams over-spend on model quality and under-invest in these mechanical optimizations.

## Token Pricing Landscape (April 2026)

Per 1M tokens:

| Model | Input | Output | Notes |
|-------|-------|--------|-------|
| Claude Opus 4 | $15 | $75 | Maximum capability |
| **Claude Sonnet 4** | **$3** | **$15** | **Production workhorse** |
| Claude Haiku 3.5 | $0.80 | $4 | Fast, cheap |
| GPT-4o | $2.50 | $10 | OpenAI flagship |
| **GPT-4o mini** | **$0.15** | **$0.60** | **Cheapest major API** |
| Gemini 2.5 Pro | $1.25-2.50 | $10-15 | Tiered by context |
| Llama 70B (Together) | $0.54 | $0.54 | Open-source hosted |
| Llama 8B (self-hosted) | ~$0.02-0.05 | ~$0.02-0.05 | Amortized GPU |

## Optimization Strategies (Ranked by ROI)

### 1. Prompt Caching (90% Input Savings)

The single biggest optimization. Design prompts with static prefix:

```
[STATIC prefix: system prompt + tools + examples]  ← Cached at 90% discount
[DYNAMIC suffix: user message]                      ← Full price
```

**Real numbers**: 10K-token system prompt, 1M calls/month:
- Without caching: ~$30
- With caching: ~$3
- **Rule**: Never put dynamic content before static content

### 2. Model Tiering / Routing (60-70% Cost Reduction)

Use a cheap model for simple requests, expensive model for complex ones:

```
User request
  → Classifier (Haiku / 4o-mini, ~$0.15/M)
    ├─ Simple (60-70% of requests) → Haiku/4o-mini
    └─ Complex (30-40%) → Sonnet/GPT-4o
```

Production implementations report **60-70%** of requests handled by the cheap tier. Frameworks: Martian, Portkey, LiteLLM, or custom routing logic.

### 3. Batch API (50% Off)

Both Anthropic and OpenAI offer batch endpoints:
- **50% discount** on all tokens
- 24-hour SLA (not real-time)
- Perfect for: eval runs, data processing, content generation pipelines, nightly jobs

### 4. Context Window Economics

Sending 200K tokens of context: **$0.60/call** (Sonnet)
RAG retrieving 2K relevant tokens: **$0.006/call** + embedding cost

**RAG is ~100x cheaper** per query for knowledge retrieval. Use long context only when you need holistic understanding of the full document, not keyword lookup.

### 5. Token Reduction

| Technique | Savings | Quality Impact |
|-----------|---------|----------------|
| Prompt compression (LLMLingua) | 2-5x | Minimal for well-structured content |
| Output constraints (max_tokens) | 20-40% | None if constraints match needs |
| Structured output schemas | 10-20% | Prevents verbose padding |
| Removing redundant instructions | 10-30% | None (these were wasted tokens) |

### 6. Distillation (10-100x for Specific Tasks)

The ultimate optimization — see [[Fine-tuning vs Prompting vs RAG]]:

```
Frontier model → 10K-100K training examples → Fine-tune Llama 8B → Serve with vLLM
```

Requires 2-4 weeks engineering investment and clear eval metrics.

## Real Production Cost Examples

| Application | Scale | Monthly Cost | Key Optimization |
|-------------|-------|-------------|-----------------|
| AI coding assistant | 10K users, 100 req/user/day | $50-150K | Caching + Sonnet/Haiku mix |
| Customer support bot | 50K conversations/day | $5-15K | 80% Haiku / 20% Sonnet routing |
| Document processing | 100K docs/day | $2-8K | Batch API + caching |
| Self-hosted Llama 70B | 5M+ requests/day | $8-12K (4x A100) | Amortized GPU |

## The Self-Hosted Crossover

```
API cost/month > (GPU cost + engineering amortization)
```

Crossover typically at **$15-20K/month** for a single model type. Engineering cost: 1-2 FTE-months upfront, 0.25 FTE ongoing.

See [[LLM Inference and Serving]] for deployment details.

## Cost Monitoring Checklist

- [ ] Track cost per request (not just monthly total)
- [ ] Monitor cache hit rate (should be >80% for stable prompts)
- [ ] Measure routing accuracy (cheap model handling correct % of requests)
- [ ] Alert on cost spikes (denial-of-wallet prevention)
- [ ] Compare model quality vs cost weekly (prices drop frequently)

## Related Pages

- [[Production Prompt Engineering]]
- [[LLM Inference and Serving]]
- [[Fine-tuning vs Prompting vs RAG]]
- [[Open Source LLM Landscape 2026]]

## Sources

- [Anthropic Pricing](https://www.anthropic.com/pricing)
- [OpenAI Pricing](https://openai.com/api/pricing/)
- [Anthropic Prompt Caching](https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching)
- [OpenAI Batch API](https://platform.openai.com/docs/guides/batch)
- [Together AI Pricing](https://www.together.ai/pricing)
