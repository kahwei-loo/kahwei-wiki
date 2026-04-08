---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "Claude Code source leak analysis (April 2026)"
  - "Engineer's Codex, WaveSpeedAI, InfoQ analyses"
tags: [ai, agent, architecture, claude, commercial]
---

# Claude Code Architecture Deep Dive

> Not a chat wrapper — a full multi-agent operating system with 3 subagent models, 7-layer memory, 5 context compression strategies, and 88 compile-time feature gates. Leaked via .map sourcemap in npm package, March 31, 2026.

## How It Leaked

Anthropic uses Bun as the build tool. Bun's bundler generates sourcemaps by default. Someone forgot to exclude `*.map` in `.npmignore`, shipping `cli.js.map` (59.8 MB) containing 1,900 TypeScript files and 512K+ lines of original source. Exposed for ~3 hours before takedown.

Irony: Claude Code has an internal "Undercover Mode" to prevent AI from leaking codenames in git commits — but Anthropic itself leaked the entire source, likely via a build process operated by Claude.

## Core Architecture

```
src/
├── main.tsx          # CLI entry · Commander.js + Ink REPL (4,683 lines)
├── query.ts          # Core Agent Loop · largest single file (785 KB)
├── QueryEngine.ts    # SDK/Headless query lifecycle (~1,295 lines)
├── Tool.ts           # Tool interface + buildTool factory (29K lines base)
├── tools/            # ~40 tool implementations
├── commands/         # ~50 slash commands
├── components/       # ~140 React/Ink UI components
├── coordinator/      # Multi-agent Coordinator system
├── memdir/           # Persistent memory directory
├── skills/           # Reusable workflow definitions
├── plugins/          # Plugin system
├── bridge/           # VS Code / JetBrains IDE integration
├── buddy/            # Tamagotchi companion (BUDDY flag)
└── constants/
    └── betas.ts      # All beta API header definitions
```

**Common misconception**: The 785KB file is `query.ts` (the agent loop), NOT `main.tsx`. This error was widely propagated by secondary articles.

## The Agent Loop (query.ts)

The core is a **while loop + streaming + tool injection** pattern:

```
while (true) {
  1. Check token budget → compress if over 85%
  2. Stream request to Claude API
  3. Collect text chunks (yield to user) + tool calls
  4. If no tool calls → break (task complete)
  5. Execute tools in parallel (Promise.all)
  6. Inject tool results back into message history
  7. Continue loop
}
```

Key details:
- **Token budget management**: Each subagent gets an allocated budget. Exceeding triggers compression, not errors.
- **14 cache-break vectors**: Tracks conditions that invalidate prompt cache (model switch, tool schema update, CLAUDE.md change, etc.). Minimizing cache misses is a core cost optimization.
- **Parallel tool execution**: Multiple tool calls in a single response are executed concurrently via `Promise.all`.

## 5 Context Compression Strategies

When context approaches the limit, Claude Code doesn't error — it compresses:

| Strategy | Description | Cost |
|----------|-------------|------|
| **Tool result compression** | Truncate large tool outputs (file contents, etc.) | Zero |
| **Image downscaling** | Reduce screenshot resolution | Zero |
| **Cache-aware pruning** | Delete only messages after cache boundary, preserve cached prefix | Saves cache $ |
| **Summarization** | Call Claude to generate history summary, replace original messages | One API call |
| **Truncation** | Drop oldest messages | Zero (last resort) |

## Tool System (29K Lines)

Each tool is a self-describing, permission-gated plugin unit:

```typescript
interface Tool<TInput, TOutput> {
  name: string
  description: string           // Used in Claude's system prompt
  inputSchema: JSONSchema        // Validated before execution
  permissionLevel: 'always-allow' | 'ask-once' | 'ask-always'
  isReadOnly: boolean
  execute(input: TInput): Promise<TOutput>
}
```

**Permission Gate — three layers**:
1. **Tool-level**: Each tool declares its own permission level
2. **Bash security**: `bashSecurity.ts` has 23 named checks gating every shell command
3. **Coordinator approval**: Dangerous operations from worker agents route to coordinator for human approval

## Three Subagent Execution Models

This is one of the most important architectural innovations:

| Model | Isolation | Context Sharing | Best For |
|-------|-----------|----------------|----------|
| **Fork** | Separate process | Read-only snapshot of parent context | Long-running, high-risk tasks (refactoring) |
| **Teammate** | AsyncLocalStorage (in-process) | Shared session state + scratchpad | Fast parallel subtasks within same session |
| **Worktree** | Git worktree (separate branch) | Independent working directory | Parallel code experiments, A/B comparison |

**Fork model**: Child gets a curated subset of parent context, scoped tools, allocated budget, and read-only memory snapshot. Results return to parent without polluting parent context.

**Coordinator mode**: When activated, Claude becomes a "director" — dispatches Workers in parallel. The system prompt explicitly states: *"Parallelism is your superpower. Don't serialize work that can run simultaneously."* and *"Do NOT say 'based on your findings' — read the actual findings and specify exactly what to do."*

**Worker communication**: XML-based protocol with structured task notifications including status, results, and suggested next actions. Workers share persistent findings via a shared scratchpad directory (`tengu_scratch` feature gate).

## 7-Layer Memory Architecture

| Layer | Name | Persistence | Description |
|-------|------|-------------|-------------|
| L1 | In-context | Session only | Current messages array |
| L2 | Working Memory | Project-level | CLAUDE.md + pinned context, injected at session start |
| L3 | Episodic | Log-level | Append-only logs maintained by KAIROS daemon |
| L4 | Semantic | Core knowledge | Solidified facts in memdir/ (autoDream output) |
| L5 | Procedural | Skill-level | Reusable workflows in skills/ directory |
| L6 | Contact | Relationship | Known people and roles across sessions |
| L7 | Team | Cross-user | Shared remote state with SHA-256 delta sync + git-leaks protection |

## autoDream: Background Memory Consolidation

When user is idle for 5+ minutes, KAIROS spawns a background subagent that "dreams":

```
Phase 1: Scan    — Extract observations from daily log
Phase 2: Merge   — Combine similar observations, find patterns
Phase 3: Refine  — Remove contradictions against existing semantic memory
Phase 4: Commit  — Convert vague observations → absolute facts
```

Example: "User keeps editing auth.ts" → "JWT token expiry changed from 1h to 24h"

This is the same pattern as [[Agent Memory Systems|Letta/MemGPT's]] memory consolidation, but implemented as an idle-triggered subagent rather than an always-on process.

## 10 Reusable Engineering Patterns

Patterns extracted from Claude Code that apply to any LLM agent product:

| # | Pattern | Key Idea |
|---|---------|----------|
| 1 | **Permission-gated Tool Interface** | Tools self-declare permission level, not the caller |
| 2 | **Startup Parallel Prefetch** | All startup IO in Promise.all, heavy modules lazy-loaded |
| 3 | **5-level Context Compression** | Graceful degradation, not hard failure on context overflow |
| 4 | **3 Subagent Execution Models** | Fork/Teammate/Worktree — match isolation to task risk |
| 5 | **autoDream Idle Consolidation** | Batch memory processing during idle, don't pollute main context |
| 6 | **Cache-break Vector Tracking** | Actively minimize prompt cache misses for cost control |
| 7 | **Task Budget Management** | Per-subagent token budgets; compress on exceed, don't error |
| 8 | **Coordinator "Parallel Superpower"** | System prompt enforces parallelism, bans lazy delegation |
| 9 | **Compile-time Feature Flags** | Dead code elimination per tier, not runtime if/else |
| 10 | **Frustration Detection** | Regex-based emotion detection triggers mode switches |

## Commercial Application Map

| Priority | What to Build | Pattern Source |
|----------|--------------|----------------|
| P0 | Token budget per tenant | Task Budget Management |
| P0 | Permission-gated tools | Permission Gate 3-layer |
| P1 | Coordinator + Workers replacing linear workflows | Coordinator mode |
| P1 | Post-conversation memory consolidation | autoDream |
| P1 | Startup parallel prefetch (Redis/DB/vector) | Parallel Prefetch |
| P2 | Frustrated customer detection + human handoff | Frustration Detection |
| P2 | Tier-based feature flags (Basic/Pro/Enterprise) | Compile-time Flags |

## Related Pages

- [[Multi-Agent Architecture Patterns]]
- [[Agent Memory Systems]]
- [[AI Agent vs Skills vs Workflow]]
- [[AI Automation Maturity L1-L5]]

## Sources

- Claude Code source leak analysis (cli.js.map, npm @anthropic-ai/claude-code v2.1.88)
- [Engineer's Codex Deep Dive](https://read.engineerscodex.com/p/diving-into-claude-codes-source-code)
- [WaveSpeedAI Architecture Analysis](https://wavespeed.ai/blog/posts/claude-code-architecture-leaked-source-deep-dive/)
- [VentureBeat Coverage](https://venturebeat.com/technology/claude-codes-source-code-appears-to-have-leaked-heres-what-we-know)
- [Straiker Security Analysis](https://www.straiker.ai/blog/claude-code-source-leak-with-great-agency-comes-great-responsibility)
