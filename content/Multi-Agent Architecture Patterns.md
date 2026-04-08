---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "Claude Code leak analysis, MorphLLM, OpenAgents comparison"
tags: [ai, agent, multi-agent, architecture]
---

# Multi-Agent Architecture Patterns

> The production multi-agent landscape has consolidated. LangGraph and Claude Agent SDK are what people actually ship with. The key trade-off nobody talks about: model lock-in vs framework maturity.

## Production Framework Comparison

| Framework | Orchestration | State Persistence | Model Lock-in | Production Readiness |
|-----------|--------------|-------------------|---------------|---------------------|
| **LangGraph** | Directed graphs, conditional edges | Built-in checkpointing + time travel | None | Highest (LangSmith observability) |
| **Claude Agent SDK** | Tool-use chains + sub-agents | MCP servers | Claude only | High (safety-first, extended thinking) |
| **OpenAI Agents SDK** | Explicit handoffs | Context variables (ephemeral) | OpenAI only | High (built-in tracing + guardrails) |
| **CrewAI** | Role-based crews | Sequential task output passing | None | Medium (limited checkpointing) |
| **AutoGen/AG2** | Conversational GroupChat | In-memory conversation history | None | Medium (rewrite still maturing) |
| **Google ADK** | Hierarchical agent trees | Session state + pluggable backends | Vertex AI | Early |

### What Actually Ships in Production

**LangGraph** and **Claude Agent SDK** are the two frameworks people deploy. CrewAI is popular for prototypes but lacks durable checkpointing. AutoGen's AG2 rewrite is still maturing.

**The trade-off nobody talks about**: Claude SDK locks you to Claude models. LangGraph/CrewAI/AutoGen are model-agnostic. Model flexibility matters more than you think — you want to swap providers when pricing or quality shifts.

## Claude Code's 3 Subagent Models (Reference Architecture)

The [[Claude Code Architecture Deep Dive|Claude Code leak]] revealed three distinct subagent execution models, each solving a different isolation problem:

### Fork (Process Isolation)
- Child gets curated subset of parent context + scoped tools + allocated budget + read-only memory
- Runs in independent process, results return without polluting parent
- **Use for**: Long-running, high-risk tasks (refactoring, large analysis)

### Teammate (In-Process Isolation)
- Uses Node.js `AsyncLocalStorage` for logical isolation within same process
- Can share session state and scratchpad (`tengu_scratch`)
- **Use for**: Fast parallel subtasks within same session

### Worktree (Git Isolation)
- Creates independent git worktree with separate branch
- Full filesystem isolation for code experiments
- **Use for**: A/B code experiments, parallel approach comparison

### Coordinator Pattern
System prompt enforces: *"Parallelism is your superpower"* and *"Do NOT say 'based on your findings' — specify exactly what to do."*

Workers communicate via XML protocol. Shared scratchpad enables cross-worker knowledge sharing without coordinator bottleneck.

## Key Production Pattern: Model Tiering

The dominant pattern in production multi-agent systems:

```
Cheap/fast model (Haiku, GPT-4o-mini, Gemma 4 E4B)
  → Triage, routing, classification, simple extraction

Capable model (Opus, GPT-4o, Qwen 3.6)
  → Complex reasoning, synthesis, decision-making
```

This reduces cost 60-80% while maintaining quality on the tasks that matter.

## Orchestration Patterns

### 1. Sequential Pipeline (Simplest)
```
Agent A → Agent B → Agent C → Output
```
Each agent has a specialized role. Output of one feeds into the next. Works for well-defined workflows.

### 2. Coordinator + Workers (Claude Code Pattern)
```
Coordinator
  ├→ Worker A (parallel)
  ├→ Worker B (parallel)
  └→ Worker C (parallel)
       ↓
Coordinator synthesizes results
```
Best for tasks with parallelizable subtasks. [[Claude Code Architecture Deep Dive|Claude Code's implementation]] is the reference.

### 3. Hierarchical Delegation
```
Supervisor
  ├→ Manager A
  │   ├→ Worker A1
  │   └→ Worker A2
  └→ Manager B
      └→ Worker B1
```
For complex enterprise scenarios. Google ADK and LangGraph support this natively.

### 4. Conversational Group (AutoGen Pattern)
```
Agent A ←→ Agent B ←→ Agent C
     (shared conversation)
```
All agents participate in a shared conversation. Good for brainstorming/debate but hard to control in production.

## When NOT to Use Multi-Agent

- **Simple tool-calling tasks**: A single agent with tools is simpler and cheaper
- **Latency-sensitive applications**: Agent coordination adds overhead
- **When you can't observe**: Without tracing/observability, debugging multi-agent is a nightmare
- **Prototype stage**: Start with one agent, split when you hit clear boundaries

## Related Pages

- [[Claude Code Architecture Deep Dive]]
- [[Agent Memory Systems]]
- [[AI Agent vs Skills vs Workflow]]
- [[AI Automation Maturity L1-L5]]

## Sources

- [Claude Code source leak architecture analysis](https://read.engineerscodex.com/p/diving-into-claude-codes-source-code)
- [MorphLLM Framework Analysis](https://www.morphllm.com/ai-agent-framework)
- [OpenAgents Comparison](https://openagents.org/blog/posts/2026-02-23-open-source-ai-agent-frameworks-compared)
- [Enterprise Multi-Agent Guide](https://www.adopt.ai/blog/multi-agent-frameworks)
