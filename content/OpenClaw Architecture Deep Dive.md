---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "OpenClaw GitHub repo analysis"
  - "Architecture blog posts and community analysis"
tags: [ai, agent, architecture, open-source, commercial]
---

# OpenClaw Architecture Deep Dive

> Not just a chatbot — a multi-agent operating system with hub-and-spoke messaging, self-evolving markdown skills, file-based layered memory, and a separable PI agent runtime. 247K+ stars, 35K+ forks, 13.7K+ community skills.

## Core Architecture: Two Layers

OpenClaw is actually two systems:

1. **PI (Personal Intelligence)**: The lower-level agent runtime — the actual agent framework that handles LLM interaction, tool execution, and the agent loop
2. **OpenClaw**: The orchestration and integration layer on top — channel adapters, Gateway, skills, memory, cron

This separation is architecturally significant: PI can be extracted and used independently to build other agent products.

## The Agent Loop

Lives in `src/agents/pi-embedded-runner/run.ts`. Standard while-loop with two notable resilience patterns:

```
Message arrives from channel adapter
  → PI createAgentSession()
  → while (true):
      1. Call LLM with messages + tools
      2. Execute returned tool calls
      3. Feed results back
      4. Repeat until completion or error
  → Two resilience mechanisms:
      - Context overflow → automatic session compaction
      - Auth error → API key rotation across providers
```

**Event-driven, not polling**. The loop only spins up when a message arrives. For autonomous/proactive behavior, a separate cron daemon (`src/cron/`) handles scheduled tasks — this is what enables the "heartbeat" where OpenClaw acts without user prompting.

## Multi-Platform Messaging: Hub-and-Spoke

### Gateway (Single Control Plane)

All clients connect via one WebSocket endpoint (`ws://127.0.0.1:18789`). CLI, web UI, macOS app, iOS/Android, headless nodes — all share the same protocol and declare their role at handshake.

### Channel Adapters (`src/channels/`)

One adapter per platform, each normalizing platform-specific APIs into a standard internal message format:

```
WhatsApp API  ─→ ┐
Telegram API  ─→ ├─→ [Normalized Message] ─→ Gateway ─→ Agent Runtime
Slack API     ─→ ┤                                         ↓
Discord API   ─→ ┘                                    [Response]
                                                         ↓
                                              Gateway routes to origin
```

**Commercial pattern**: Adding a new platform = writing one adapter that conforms to the message contract. Agent core never changes. O(1) agent changes for O(n) platforms.

## Self-Evolving Skills

The most architecturally interesting feature. Deceptively simple:

### Skills are Directories with Markdown

```
skills/
├── skill-creator/
│   └── SKILL.md          # Meta-skill: teaches agent how to create new skills
├── web-search/
│   └── SKILL.md          # YAML frontmatter + markdown instructions
├── custom-automation/
│   ├── SKILL.md          # Instructions
│   └── handler.ts        # Optional: code-backed execution
```

Each `SKILL.md` has YAML frontmatter (name, description, triggers) + markdown instructions. **No compiled code required at minimum** — the simplest skill is pure natural language instructions.

### How It Works at Runtime

1. `formatSkillsForPrompt` scans all installed SKILL.md files
2. Builds a compact XML skill index
3. Injects into system prompt
4. LLM selects skills based on task semantics

### The Skill-Creator is a Skill

`skills/skill-creator/SKILL.md` teaches the agent how to write new SKILL.md files. Nothing mechanically special — same format as every other skill. The agent writes new skills to disk, and they're available on the next invocation.

**For code-backed skills**: The LLM generates TypeScript/shell scripts, writes to disk via file operations, then executes them.

**Security boundary**: Skills don't grant permissions. If your tool policy blocks `exec`, a skill requiring shell commands will load but fail at execution time. Skills are instructions, not executable plugins.

### Ecosystem Scale

- **13,700+ skills** on ClawHub
- **35,000+ forks**
- Skill-creator enables non-developers to extend the system via natural language

## Memory System (Local-First, File-Based)

### Layered Architecture

| Layer | File | Loaded When | Purpose |
|-------|------|-------------|---------|
| **Long-term** | `MEMORY.md` | Every DM session start | Durable facts, preferences, decisions |
| **Daily context** | `memory/YYYY-MM-DD.md` | Today + yesterday auto-loaded | Recent context and daily notes |
| **Vector search** | SQLite + `sqlite-vec` | On retrieval query | Semantic search over all content |

### Vector Search (Zero External Dependencies)

Uses SQLite with `sqlite-vec` extension — no Pinecone, no Qdrant, no external service:
- Content chunked into ~400-token segments with 80-token overlap
- Supports BM25 (keyword), vector similarity, and hybrid search
- **QMD (Query-Memory-Document)**: Runs BM25 + vector channels simultaneously with re-ranking fusion

### Compaction Safeguard

Before summarizing a conversation to free context, OpenClaw runs a silent turn reminding the agent to save important unsaved context to memory files first. Prevents information loss during context window management.

## Cron-Based Autonomy

The proactive behavior differentiator. A separate cron daemon handles scheduled tasks:
- Morning briefing aggregation
- Cross-posting content on schedule
- Periodic monitoring and alerting
- Any user-defined recurring task

This makes OpenClaw a **proactive assistant**, not just a reactive one — a significant UX differentiator.

## OpenClaw vs Claude Code

| Dimension | OpenClaw | [[Claude Code Architecture Deep Dive\|Claude Code]] |
|-----------|----------|------------|
| **Philosophy** | Autonomous general assistant | Developer augmentation tool |
| **Agent model** | Multi-agent native (PI runtime) | Single-agent + external orchestration |
| **Model support** | Any LLM (BYOK), including local Ollama | Anthropic models only |
| **Memory** | Persistent across sessions (file-based) | Session-scoped (CLAUDE.md for soft persistence) |
| **Extension model** | SKILL.md (markdown-first, non-dev friendly) | MCP servers (code-first, developer-focused) |
| **Multi-platform** | 50+ channels via adapters | IDE-focused (VS Code, JetBrains, CLI) |
| **Autonomy** | Proactive (cron daemon) | Reactive (user-initiated) |
| **Strength** | Breadth of integrations, accessibility | Depth of codebase understanding, precision |

**Key insight**: OpenClaw optimizes for **breadth and autonomy** (many platforms, proactive behavior, non-developer users). Claude Code optimizes for **depth and precision** (deep repo understanding, multi-file refactoring, developer workflows). They solve fundamentally different problems.

## Commercial Patterns to Extract

| Pattern | Implementation | Applicable To |
|---------|---------------|---------------|
| **Hub-and-spoke Gateway** | Single WS endpoint, adapters per platform | Any multi-channel AI product |
| **Markdown-first skills** | SKILL.md = YAML frontmatter + instructions | Low-code automation platforms |
| **Separable agent runtime** | PI runtime extracted from orchestration | Licensing the core as SDK |
| **File-based memory** | MEMORY.md + daily files + SQLite vector | Portable, inspectable, no DB dependency |
| **Cron autonomy** | Background daemon for proactive behavior | Differentiator vs reactive-only products |
| **Adapter normalization** | One message contract, many platforms | Scale platform support without touching core |

## Notable Forks

- **NanoClaw**: Security-first fork with mandatory Docker/Apple container isolation (enterprise target)
- **ZeroClaw**: Rust rewrite achieving 99% RAM reduction
- **openclaw-mission-control**: Multi-agent orchestration dashboard

## Related Pages

- [[Claude Code Architecture Deep Dive]]
- [[Multi-Agent Architecture Patterns]]
- [[Agent Memory Systems]]
- [[AI Agent vs Skills vs Workflow]]

## Sources

- [GitHub: openclaw/openclaw](https://github.com/openclaw/openclaw)
- [Architecture Overview (Substack)](https://ppaolo.substack.com/p/openclaw-system-architecture-overview)
- [Inside the Agent Loop (Medium)](https://tomaszs2.medium.com/how-does-openclaw-work-inside-the-agent-loop-that-powers-200-000-github-stars-e61db2bbfcbb)
- [Memory System Deep Dive (Gitbook)](https://snowan.gitbook.io/study-notes/ai-blogs/openclaw-memory-system-deep-dive)
- [Skills Documentation](https://docs.openclaw.ai/tools/skills)
- [OpenClaw vs Claude Code (DataCamp)](https://www.datacamp.com/blog/openclaw-vs-claude-code)
- [Complete Guide (Milvus)](https://milvus.io/blog/openclaw-formerly-clawdbot-moltbot-explained-a-complete-guide-to-the-autonomous-ai-agent.md)
