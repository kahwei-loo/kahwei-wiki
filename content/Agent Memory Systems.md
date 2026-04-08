---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "Claude Code leak, Letta/MemGPT docs, Mem0 paper, Zep docs"
tags: [ai, agent, memory, architecture]
---

# Agent Memory Systems

> The dominant production pattern: structured memory blocks always in-context (like RAM) + vector-searchable archival store + offline consolidation pipeline. Claude Code's leak confirmed this is exactly how Anthropic does it.

## The Problem

Without persistent memory, AI agents start every session from scratch — "a brilliant employee with amnesia." The challenge is balancing:
- **Relevance**: Only load what matters for this task
- **Cost**: Don't burn tokens on irrelevant history
- **Freshness**: Resolve contradictions between old and new information
- **Privacy**: Control what persists and what's forgotten

## Claude Code's 7-Layer Memory (Production Reference)

From the [[Claude Code Architecture Deep Dive|source leak]]:

| Layer | Name | Persistence | What It Stores |
|-------|------|-------------|----------------|
| L1 | In-context | Session only | Current messages array |
| L2 | Working Memory | Project-level | CLAUDE.md + pinned context (injected at session start) |
| L3 | Episodic | Log-level | Append-only session logs (KAIROS daemon) |
| L4 | Semantic | Core knowledge | Solidified facts from autoDream consolidation |
| L5 | Procedural | Skill-level | Reusable workflows in skills/ directory |
| L6 | Contact | Relationship | Known people and roles |
| L7 | Team | Cross-user | Shared remote state with delta sync |

**Key insight**: MEMORY.md acts as a lightweight pointer index (~150 chars/line) that's always loaded. Actual knowledge is distributed across topic files, fetched on-demand. This is the **pointer-based architecture** — cheap persistent index + deep retrieval.

### autoDream: Idle-Time Consolidation

When user is idle 5+ minutes, KAIROS spawns a background subagent:
1. **Scan**: Extract observations from daily log
2. **Merge**: Combine similar observations, find patterns
3. **Refine**: Remove contradictions against existing semantic memory
4. **Commit**: Convert vague observations → absolute facts

This batch processing approach is more efficient than real-time consolidation and doesn't pollute the main context.

## Major Memory Frameworks

### Letta (formerly MemGPT)

**Philosophy**: LLM-as-OS — the agent manages its own memory via explicit function calls, like an operating system managing RAM, disk, and swap.

**Three-tier architecture**:
- **Core Memory** (always in-context, like RAM): Goals, user persona, current task state. ~2-4K tokens.
- **Archival Memory** (vector store, like disk): Long-term knowledge queried via explicit `archival_memory_search` tool calls.
- **Recall Memory** (conversation history, searchable): Past interactions indexed for retrieval.

**Key innovation**: The agent *decides* what to promote from archival to core, and what to archive from core. Memory management is a first-class tool, not a background process.

**Results**: 18% accuracy gains, 2.5x cost reduction per query (vs. full history in context). $10M funding, production-ready.

### Mem0 (Managed Memory Layer)

More opinionated than Letta. Automatic extraction and retrieval of memories from conversations. Less flexible but easier to integrate. The Mem0 paper (arxiv 2504.19413) formalizes the architecture.

**Best for**: Teams that want memory without building the infrastructure. Drop-in integration with existing agent systems.

### Zep

Focuses specifically on conversation memory with automatic fact extraction, entity tracking, and temporal awareness.

**Best for**: Customer-facing agents where conversation history is the primary memory source.

## Pattern Comparison

| Aspect | Claude Code | Letta/MemGPT | Mem0 | Zep |
|--------|------------|-------------|------|-----|
| Architecture | 7-layer hierarchy | 3-tier (core/archival/recall) | Managed extraction | Conversation-focused |
| Who manages memory | Background daemon (autoDream) | Agent itself (via tools) | Automatic pipeline | Automatic pipeline |
| Consolidation | Batch (idle-triggered) | Real-time (agent decides) | Background | Background |
| Conflict resolution | autoDream Phase 3 (Refine) | Agent reasoning | Automatic | Temporal ordering |
| Open source | No (leaked) | Yes | Yes | Yes |
| Maturity | Production ($25B ARR product) | Production | Production | Production |

## The Dominant Production Pattern

Across all implementations, the winning pattern is:

```
1. Structured memory blocks always in context
   (user profile, session state, key facts — like Claude Code's L2)

2. Vector-searchable archival store for long-tail knowledge
   (RAG over past conversations/documents — like Letta's archival)

3. Offline consolidation pipeline
   (batch processing to extract, deduplicate, solidify — like autoDream)
```

**VentureBeat predicts contextual memory will surpass RAG for agentic AI in 2026** — meaning the memory layer becomes more important than the retrieval layer for agent performance.

## Implementation Guidance

**If building from scratch**: Start with the pointer-based architecture (MEMORY.md pattern). A JSON/markdown index file always in context, pointing to topic-specific files loaded on demand. Add autoDream-style consolidation when you have enough session data.

**If using a framework**: Letta for maximum control (agent self-manages memory). Mem0 for quickest integration. Zep if conversation history is your primary concern.

## Related Pages

- [[Claude Code Architecture Deep Dive]]
- [[Multi-Agent Architecture Patterns]]
- [[RAG Architecture Patterns 2026]]

## Sources

- [Claude Code source leak — 7-layer memory analysis](https://read.engineerscodex.com/p/diving-into-claude-codes-source-code)
- [Letta/MemGPT Deep Dive](https://medium.com/@piyush.jhamb4u/stateful-ai-agents-a-deep-dive-into-letta-memgpt-memory-models-a2ffc01a7ea1)
- [Mem0 Paper](https://arxiv.org/abs/2504.19413)
- [Letta Benchmarking](https://www.letta.com/blog/benchmarking-ai-agent-memory)
- [Top 10 AI Memory Products 2026](https://medium.com/@bumurzaqov2/top-10-ai-memory-products-2026-09d7900b5ab1)
