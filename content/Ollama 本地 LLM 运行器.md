---
created: 2026-04-07
updated: 2026-04-07
sources:
  - "[[70 Raw/2026-03-18-ollama-local-llm-runner]]"
tags: [ai, local-llm, 工具]
---

# Ollama 本地 LLM 运行器

> 一行命令在本地运行任何开源 LLM，免费、私密、离线可用，兼容 OpenAI API。

## 核心概念

Ollama 是本地 LLM 的 "Docker"——它把模型下载、运行、API 暴露这三件事简化成一条命令：

```bash
ollama run llama3.2
```

**为什么重要**：
- **零成本** — 不需要 API key 或订阅
- **完全私密** — 数据不离开本机
- **离线可用** — 模型下载后不需要网络
- **OpenAI 兼容** — 改一行 `base_url` 就能替换 OpenAI 调用

## 模型选择指南

| 模型 | 参数量 | 最低内存 | 适用场景 |
|------|--------|---------|---------|
| TinyLlama | 1.1B | 4GB | 超轻量，任何机器都能跑 |
| Mistral | 7B | 8GB | 快速、高效、多语言 |
| Llama 3.2 | 3B-90B | 8-64GB | 通用、质量好 |
| DeepSeek | 各种 | 8GB+ | 编程和推理 |
| StarCoder2 | 3B-15B | 8-16GB | 代码生成专用 |
| Llama 3.2 Vision | 11B-90B | 16GB+ | 图像理解 |

**经验法则**：RAM ÷ 2 ≈ 能跑的最大模型参数量（粗略估计）

## API 用法

Ollama 在 `localhost:11434` 暴露 REST API，与 OpenAI SDK 兼容：

```python
# 只需改 base_url，其他代码不变
client = OpenAI(base_url="http://localhost:11434/v1", api_key="ollama")
```

这意味着任何支持 OpenAI API 的工具（[[n8n 工作流引擎]]、LangChain、AutoGen 等）都可以无缝切换到 Ollama。

## 自定义模型

通过 `Modelfile` 创建定制模型：

```dockerfile
FROM llama3.2
SYSTEM "You are a helpful coding assistant specializing in Python."
PARAMETER temperature 0.7
```

```bash
ollama create my-assistant -f Modelfile
ollama run my-assistant
```

## 安装

```bash
# macOS / Linux
curl -fsSL https://ollama.com/install.sh | sh

# Docker
docker run -d -v ollama:/root/.ollama -p 11434:11434 ollama/ollama

# Windows — 从 ollama.com 下载安装包
```

## 实际应用场景

- **开发者**：免费的本地 Copilot、零成本 API 测试
- **隐私场景**：处理敏感文档、本地知识库问答
- **团队/企业**：自托管、合规、无供应商锁定
- **学习**：零成本体验和理解 LLM

## 相关页面

- [[本地 AI 部署方案对比]]
- [[n8n 工作流引擎]]
- [[LLM 应用开发模式]]

## 来源

- [[70 Raw/2026-03-18-ollama-local-llm-runner]] — Trending AI Repos 2026 系列整理
- [GitHub: ollama/ollama](https://github.com/ollama/ollama)
- [官网: ollama.com](https://ollama.com/)
