---
created: 2026-04-07
updated: 2026-04-08
sources:
  - "Raw/2026-03-18-ollama-local-llm-runner"
tags: [ai, local-llm, tools]
---

# Ollama Local LLM Runner

> Run any open-source LLM locally with one command. Free, private, offline, OpenAI-compatible API.

## Core Concept

Ollama is the "Docker for LLMs" — it simplifies model download, execution, and API exposure into a single command:

```bash
ollama run llama3.2
```

**Why it matters**:
- **Zero cost** — no API key or subscription needed
- **Fully private** — data never leaves your machine
- **Works offline** — no internet required after model download
- **OpenAI-compatible** — change one line of `base_url` to replace OpenAI calls

## Model Selection Guide

| Model | Params | Min RAM | Best For |
|-------|--------|---------|----------|
| TinyLlama | 1.1B | 4GB | Ultra-lightweight, runs on anything |
| Mistral | 7B | 8GB | Fast, efficient, multilingual |
| Llama 3.2 | 3B-90B | 8-64GB | General purpose, high quality |
| DeepSeek | Various | 8GB+ | Coding and reasoning |
| StarCoder2 | 3B-15B | 8-16GB | Code generation |
| Llama 3.2 Vision | 11B-90B | 16GB+ | Image understanding |

**Rule of thumb**: RAM ÷ 2 ≈ max model parameter size (rough estimate)

## API Usage

Ollama exposes a REST API on `localhost:11434`, drop-in compatible with the OpenAI SDK:

```python
# Just change base_url, everything else stays the same
client = OpenAI(base_url="http://localhost:11434/v1", api_key="ollama")
```

This means any tool supporting the OpenAI API ([[n8n Workflow Engine]], LangChain, AutoGen, etc.) can seamlessly switch to Ollama.

## Custom Models

Create specialized models with a `Modelfile`:

```dockerfile
FROM llama3.2
SYSTEM "You are a helpful coding assistant specializing in Python."
PARAMETER temperature 0.7
```

```bash
ollama create my-assistant -f Modelfile
ollama run my-assistant
```

## Installation

```bash
# macOS / Linux
curl -fsSL https://ollama.com/install.sh | sh

# Docker
docker run -d -v ollama:/root/.ollama -p 11434:11434 ollama/ollama

# Windows — download installer from ollama.com
```

## Use Cases

- **Developers**: Free local Copilot, zero-cost API testing
- **Privacy**: Process sensitive documents, local knowledge base Q&A
- **Teams/Enterprise**: Self-hosted, compliant, no vendor lock-in
- **Learning**: Experience and understand LLMs at zero cost

## Related Pages

- [[Local AI Deployment Comparison]]
- [[n8n Workflow Engine]]

## Sources

- Raw/2026-03-18-ollama-local-llm-runner — Trending AI Repos 2026 series
- [GitHub: ollama/ollama](https://github.com/ollama/ollama)
- [Official site: ollama.com](https://ollama.com/)
