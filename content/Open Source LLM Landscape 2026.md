---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "Google Gemma 4 blog, Qwen GitHub, AI benchmark sites"
tags: [ai, llm, open-source, models]
---

# Open Source LLM Landscape 2026

> The open-source LLM field has matured dramatically. Gemma 4, Qwen 3.5/3.6, and DeepSeek now trade blows with frontier closed models on many benchmarks. The choice is no longer "open vs closed" but "which open model for which task."

## Current Leaders (April 2026)

### Gemma 4 (Google, April 2, 2026)

Four variants with different compute profiles:

| Variant | Params | Active Params | Context | Key Strength |
|---------|--------|---------------|---------|-------------|
| E2B | 2B | 2B | 128K | Edge/mobile deployment |
| E4B | 4B | 4B | 128K | Best quality-per-watt for edge |
| 26B MoE | 26B | **3.8B** | 256K | Sweet spot — near-frontier at fraction of compute |
| 31B Dense | 31B | 31B | 256K | #3 globally on Arena AI text leaderboard |

**Benchmarks**: MMLU Pro 85.2%, AIME 2026 89.2%, Codeforces ELO 2150 (20x leap from Gemma 3). Configurable thinking modes, native function calling.

**Why the 26B MoE matters**: Activates only 3.8B params per token — dramatically less compute than Llama 4 Maverick's 17B active params — while achieving near-frontier quality. **Apache 2.0** license removes all commercial friction.

**[[Ollama Local LLM Runner|Ollama]]**: Day-one support. `ollama pull gemma4`

### Qwen 3.5 / 3.6 Ecosystem (Alibaba)

The most prolific open-source model family. Rapid evolution:

| Version | Release | Key Feature |
|---------|---------|-------------|
| Qwen3 | April 2025 | Apache 2.0, thinking mode toggle |
| Qwen3-Coder | 2025 | 30B MoE (3.3B active), SWE-Bench leader |
| Qwen3-Omni | Sept 2025 | Unified audio+video+text |
| Qwen 3.5 | Early 2026 | 201 languages, native audio/video all sizes |
| **Qwen 3.6 Plus Preview** | March 31, 2026 | 1M context, 65K output, always-on CoT |

**Qwen 3.6 Plus Preview**: Beats Claude 4.5 Opus on Terminal-Bench 2.0 (61.6 vs 59.3). Leads OmniDocBench v1.5 (91.2). Free during preview. 1M token context.

**Qwen3-Coder**: The strongest open-source coding model for agentic workflows. 30B MoE with only 3.3B activated. Trained with long-horizon RL specifically for agent coding scenarios.

**Ollama caveat**: Qwen3 and Qwen3-Coder work. Qwen 3.5 GGUF doesn't work in Ollama due to separate mmproj vision files — use llama.cpp compatible backends instead.

### Llama 4 (Meta)

| Variant | Active Params | Context | License |
|---------|---------------|---------|---------|
| Scout | 17B (109B total) | **10M tokens** | Community (700M MAU cap) |
| Maverick | 17B (400B total) | 1M tokens | Community (700M MAU cap) |

**10M token context** is unique but the **restrictive license** (700M monthly active user cap) limits commercial use for scale products. Apache 2.0 alternatives (Gemma 4, Qwen) are preferable for most commercial scenarios.

### DeepSeek

Strong on reasoning and coding. DeepSeek-V3 and DeepSeek-Coder remain competitive. MoE architecture with efficient inference. Chinese-origin model with strong multilingual capabilities.

## Head-to-Head Comparison

| Dimension | Gemma 4 26B | Qwen 3.5 | Llama 4 Maverick | DeepSeek-V3 |
|-----------|-------------|----------|-----------------|-------------|
| Active params/token | 3.8B | Varies | 17B | ~37B |
| Max context | 256K | 128K+ | 1M | 128K |
| MMLU Pro | 85.2% | ~87% | ~84% | ~83% |
| Coding (SWE-bench) | Good | **Best** (Coder) | Good | Strong |
| Multimodal | Vision (frames) | **Audio+Video+Text** | Vision | Vision |
| License | **Apache 2.0** | **Apache 2.0** | Community (restricted) | MIT-ish |
| Ollama support | Day 1 | Partial (no 3.5 vision) | Yes | Yes |

## Practical Selection Guide

| Use Case | Best Choice | Why |
|----------|-------------|-----|
| Edge/mobile | Gemma 4 E4B | 4B params, excellent quality-per-watt |
| Production API (cost-sensitive) | Gemma 4 26B MoE | 3.8B active = lowest inference cost |
| Agentic coding | Qwen3-Coder | Purpose-built for long-horizon agent coding |
| Multimodal (audio+video) | Qwen 3.5 | Only open model with native audio+video |
| Long context (1M+) | Llama 4 Maverick | 1M context, but check license restrictions |
| General quality ceiling | Qwen 3.6 Plus | Beats Claude 4.5 Opus on some benchmarks |
| Maximum commercial freedom | Gemma 4 or Qwen 3.x | Apache 2.0, no usage caps |

## The Bigger Picture

The open-source LLM gap with frontier models has closed to **1-2%** on most benchmarks. The remaining advantages of closed models are:
- **Longer context** reliability at scale
- **RLHF quality** on subjective tasks (creative writing, nuanced reasoning)
- **Enterprise support** and SLAs

For most production use cases — especially cost-sensitive ones — an open model running on [[Ollama Local LLM Runner|Ollama]] or a cloud inference provider is now a viable primary choice, not just a fallback.

## Related Pages

- [[Ollama Local LLM Runner]]
- [[RAG Architecture Patterns 2026]]
- [[AI Agent vs Skills vs Workflow]]

## Sources

- [Google Gemma 4 Blog](https://blog.google/innovation-and-ai/technology/developers-tools/gemma-4/)
- [Gemma 4 vs Qwen 3.5 vs Llama 4](https://ai.rs/ai-developer/gemma-4-vs-qwen-3-5-vs-llama-4-compared)
- [Qwen3 GitHub](https://github.com/QwenLM/Qwen3)
- [Qwen 3.6 Plus Review](https://www.buildfastwithai.com/blogs/qwen-3-6-plus-preview-review)
- [Latent Space: Gemma 4 Analysis](https://www.latent.space/p/ainews-gemma-4-the-best-small-multimodal)
