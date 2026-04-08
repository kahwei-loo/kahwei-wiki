---
created: 2026-04-09
updated: 2026-04-09
sources:
  - "vLLM docs, HuggingFace TGI, quantization benchmarks, cloud provider pricing"
tags: [ai, inference, serving, deployment, production]
---

# LLM Inference & Serving

> vLLM with PagedAttention is the production standard for self-hosted serving. AWQ is the default quantization for GPU; GGUF for CPU/Apple Silicon. The self-hosted crossover point is roughly $15-20K/month API spend.

## Serving Frameworks

### vLLM (Dominant)

The standard for self-hosted LLM serving. Key innovations:

- **PagedAttention**: Manages KV cache like OS virtual memory — pages allocated on demand, near-zero waste. 2-4x throughput over naive implementations
- **Continuous batching**: New requests join without waiting for the longest sequence to finish. Critical for production latency
- **Speculative decoding**: Draft model generates candidates, target model verifies in parallel. Real speedup: 1.5-2.5x for code/structured output
- **Tensor parallelism**: Split model across GPUs for large models

**Production deployment**: Load balancer with autoscaling based on **queue depth**, not CPU/GPU utilization.

### Text Generation Inference (TGI, HuggingFace)

Alternative to vLLM. Strengths: tighter HuggingFace Hub integration, flash attention, watermarking. Generally similar performance to vLLM; choose based on ecosystem preference.

### Ollama

For development and low-QPS internal tools. Not designed for production throughput. See [[Ollama Local LLM Runner]].

## Quantization Methods

| Method | Bits | Quality Loss | Memory Reduction | Best For |
|--------|------|-------------|-----------------|----------|
| **FP16** | 16 | None (baseline) | 1x | Maximum quality |
| **AWQ** | 4 | ~1-2% on benchmarks | 2-3x | **GPU production serving** |
| **GPTQ** | 4 | ~1-3% | 2-3x | Batch processing, less latency-sensitive |
| **GGUF** | 2-8 (mixed) | Varies by quant level | 2-6x | **CPU/Apple Silicon** (llama.cpp/Ollama) |

**AWQ** has emerged as the default for GPU serving. **GGUF Q4_K_M** (4-bit mixed precision) gives surprisingly good quality — often within 2-3% of FP16 on practical tasks.

**Rule of thumb**: AWQ for production GPU serving, GGUF for everything else (dev, edge, Mac).

## Hardware Guide

| GPU | VRAM | Cloud Cost (approx) | Sweet Spot |
|-----|------|-------------------|------------|
| **H100 SXM** | 80GB | $2-3/hr | Frontier serving, training |
| **A100 80GB** | 80GB | $1.5-2/hr | **Production workhorse**, best price/perf |
| **L40S** | 48GB | $1-1.5/hr | 70B quantized, inference-focused |
| **RTX 4090** | 24GB | $0.3-0.5/hr | 7B-13B models, development |
| **Apple M-series** | 32-192GB unified | One-time | Local dev, viable for 70B with GGUF |

**CPU inference**: Viable for small models (7B quantized) at ~10-30 tok/s via llama.cpp. Not competitive for production throughput but fine for low-QPS internal tools.

## Cloud Inference Providers

| Provider | Differentiator | Best For |
|----------|---------------|----------|
| **Groq** | LPU hardware, ultra-low latency (~100-200 tok/s) | Latency-sensitive, interactive apps |
| **Cerebras** | Wafer-scale, massive throughput | High-throughput batch processing |
| **Together AI** | Wide model selection, competitive pricing | General-purpose open model hosting |
| **Fireworks AI** | Fast function calling | Tool-use heavy applications |

## Self-Hosted vs API Decision

```
Monthly API spend < $5K    → API (always)
$5K - $15K                 → API (unless latency/privacy requirements)
$15K - $50K                → Evaluate self-hosted (crossover zone)
> $50K                     → Self-hosted likely wins
```

**Hidden costs of self-hosted**: 1-2 FTE-months upfront engineering, 0.25 FTE ongoing maintenance, GPU procurement/reservation, monitoring infrastructure.

**When to self-host regardless of cost**: Data privacy requirements (healthcare, finance), latency requirements (<50ms), model customization needs, or regulatory compliance.

## Speculative Decoding

Draft model (small, fast) generates N candidate tokens. Target model (large, accurate) verifies all N in a single forward pass. Accepted tokens are free — only rejected tokens cost a re-generation.

**Real speedup**: 1.5-2.5x for structured/predictable output (code, JSON). Less benefit for creative/unpredictable text. Works best when draft model is a good predictor of the target.

## Serving Architecture Patterns

### Single Model
Simplest. One model behind a load balancer. Good for single-purpose applications.

### Model Router
Cheap classifier directs requests to different models based on complexity. See [[AI Cost Optimization]] for the tiering pattern.

### A/B Serving
Two model versions behind a router with traffic splitting. Essential for eval-driven model upgrades.

## Related Pages

- [[AI Cost Optimization]]
- [[Open Source LLM Landscape 2026]]
- [[Ollama Local LLM Runner]]
- [[Fine-tuning vs Prompting vs RAG]]

## Sources

- [vLLM Documentation](https://docs.vllm.ai/)
- [HuggingFace TGI](https://huggingface.co/docs/text-generation-inference)
- [llama.cpp Benchmarks](https://github.com/ggerganov/llama.cpp)
- [Together AI Pricing](https://www.together.ai/pricing)
- [Groq](https://groq.com/)
