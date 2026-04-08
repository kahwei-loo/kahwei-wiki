---
created: 2026-04-07
updated: 2026-04-08
sources:
  - "Trending AI Repos 2026 — Ollama"
  - "ollama.com official docs"
tags: [ai, local-llm, tools, infrastructure]
---

# Ollama Local LLM Runner

> The standard tool for running open-source LLMs locally. One command to download and run any model. OpenAI-compatible API on localhost:11434. Free, private, offline.

## Core Concept

Ollama is the "Docker for LLMs" — model download, execution, and API exposure in a single command:

```bash
ollama run gemma4        # Google's latest (April 2026)
ollama run qwen3-coder   # Best open-source coding model
ollama run llama3.2      # Meta's general-purpose
ollama run deepseek-v3   # Strong reasoning
```

## Why It Matters for Production

- **Zero cost** after hardware — no API key, no subscription, no per-token billing
- **Fully private** — data never leaves the machine
- **OpenAI-compatible API** — drop-in replacement for any OpenAI SDK integration
- **Model switching** — swap models without code changes

```python
# Switch from OpenAI to local — one line change
client = OpenAI(base_url="http://localhost:11434/v1", api_key="ollama")
```

## Model Availability (April 2026)

See [[Open Source LLM Landscape 2026]] for detailed model comparison. Key Ollama-supported models:

| Model | Command | Active Params | Best For |
|-------|---------|--------------|----------|
| **Gemma 4 26B** | `ollama pull gemma4` | 3.8B (MoE) | Best cost/quality ratio |
| **Gemma 4 E4B** | `ollama pull gemma4:e4b` | 4B | Edge/mobile |
| **Qwen3-Coder** | `ollama pull qwen3-coder` | 3.3B (MoE) | Agentic coding |
| Llama 3.2 | `ollama pull llama3.2` | 3B-90B | General purpose |
| DeepSeek-V3 | `ollama pull deepseek-v3` | ~37B | Reasoning |

**Caveat**: Qwen 3.5 vision GGUF doesn't work in Ollama (mmproj file issue). Use llama.cpp backends for Qwen 3.5 multimodal.

## Hardware Guide

| RAM | What You Can Run |
|-----|-----------------|
| 4GB | Gemma 4 E2B, TinyLlama |
| 8GB | Gemma 4 E4B, Mistral 7B, Qwen3-Coder (3.3B active) |
| 16GB | Gemma 4 26B MoE, Llama 3.2 8B |
| 32GB+ | Larger dense models (13B-30B) |
| 64GB+ | 70B+ models |

**Rule of thumb**: RAM ÷ 2 ≈ max model parameter size. GPU optional but dramatically faster (NVIDIA, AMD, Apple Silicon).

## Custom Models (Modelfile)

```dockerfile
FROM gemma4
SYSTEM "You are a Python coding assistant. Be concise."
PARAMETER temperature 0.3
PARAMETER num_ctx 8192
```

```bash
ollama create my-coder -f Modelfile
ollama run my-coder
```

## Integration Points

- **[[n8n Workflow Engine]]**: HTTP Request node → `localhost:11434/api/generate`
- **LangChain/LangGraph**: `ChatOllama` provider
- **Any OpenAI SDK**: Change `base_url` only
- **Docker compose**: Sidecar container alongside your app

## Installation

```bash
# macOS / Linux
curl -fsSL https://ollama.com/install.sh | sh

# Docker
docker run -d -v ollama:/root/.ollama -p 11434:11434 ollama/ollama

# Windows — installer from ollama.com
```

## Related Pages

- [[Open Source LLM Landscape 2026]]
- [[n8n Workflow Engine]]
- [[RAG Architecture Patterns 2026]]

## Sources

- [GitHub: ollama/ollama](https://github.com/ollama/ollama)
- [Official model library](https://ollama.com/library)
- [Gemma 4 on Ollama](https://ollama.com/library/gemma4)
