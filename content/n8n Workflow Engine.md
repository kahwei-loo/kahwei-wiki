---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "Trending AI Repos 2026 — n8n"
tags: [ai, automation, workflow, no-code, tools]
---

# n8n Workflow Engine

> Open-source, AI-native visual workflow automation. Think "Zapier, but self-hosted and with built-in AI agents." 400+ integrations, human-in-the-loop AI, full audit trail.

## Core Concept

Visual drag-and-drop workflow builder that connects apps, automates tasks, and builds AI agents — without writing code.

```
New email → AI reads & categorizes → Creates Trello task
                                    → Sends Slack notification
                                    → Updates spreadsheet
```

## Key Features

- **400+ integrations**: Slack, Notion, PostgreSQL, OpenAI, GitHub, and more
- **AI-native**: Chat nodes, natural language workflows, autonomous agents, human-in-the-loop
- **Self-hosted or cloud**: Docker, npm, or managed n8n Cloud
- **AI safety**: Inspect every prompt/response, approval checkpoints, full audit trail

## How It Compares

| Feature | n8n | Zapier | Make |
|---------|-----|--------|------|
| Open source | Yes | No | No |
| Self-hosted | Yes | No | No |
| AI-native | Yes | Limited | Limited |
| Custom code | Yes | Limited | Limited |
| Human-in-the-loop AI | Yes | No | No |

## Quick Start

```bash
# Docker (self-hosted)
docker run -it --rm --name n8n -p 5678:5678 \
  -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n
# Then open http://localhost:5678
```

## Use Cases

- **Individuals**: Email autopilot, RSS → AI → Notion pipeline, social media scheduling
- **Teams**: AI ticket triage, lead scoring, resume screening
- **Developers**: CI/CD notifications, error log → AI categorization → ticket creation

## Related Pages

- [[AI Agent vs Skills vs Workflow]]
- [[AI Automation Maturity L1-L5]]
- [[Ollama Local LLM Runner]]

## Sources

- Trending AI Repos 2026 — n8n
- [GitHub: n8n-io/n8n](https://github.com/n8n-io/n8n)
- [Official site: n8n.io](https://n8n.io/)
