---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "[[20 Areas/AI-Learning/agent-vs-skills]]"
tags: [ai, architecture, agent, skills]
---

# AI Agent vs Skills vs Workflow

> The architecture choice isn't "can AI do this?" but rather "uncertainty × failure cost × token cost" — which determines whether you need an Agent, Skills, or a simple Workflow.

## Definitions

### Agent
A goal-oriented system with state awareness, decision reasoning, and tool execution via ReAct (Reasoning + Acting) loops.

- Agent ≠ must use LLM, but **current mainstream agents are LLM-based**
- "GPT can search the web and write code" is **capability** — "goal-oriented + state + decision loop" is **architecture**

### Skills
Reusable "Expert Execution Templates" — not just tools, but **how to use tools + prompts + standards well**.

- Skills ≠ Tool. Skills = Tool + Prompt + Standards packaged together
- Value is not "smarter" but "more stable deliverable output"
- Can be called by Agents OR directly by Workflows

### Workflow
Fixed steps, predictable, engineering-friendly. Traditional approach with clear input/output at each step.

## When to Use What

```
Is the process fixed?
├─ Yes → Workflow (e.g., daily backup, scheduled reports)
├─ No → Does it need quality-guaranteed specific output?
│   ├─ Yes → Skills (e.g., API docs, marketing copy, presentations)
│   └─ No → Does it need dynamic decisions and tool calls?
│       ├─ Yes → Agent (e.g., smart customer service, code debugging)
│       └─ No → Simple script
```

### When NOT to Use Agents
- Real-time high-frequency tasks (unpredictable latency)
- Simple automation (scripts are cheaper)
- Privacy-sensitive data (unless locally deployed)
- The key question: "Is the uncertainty worth the token cost?"

## Two Types of Skills

| | LLM Skills | Code/System Skills |
|---|---|---|
| Requires model call | Yes | No |
| Cost | High | None |
| Output stability | Medium | High |
| Predictability | Medium | High |
| Debug difficulty | Hard | Easy |
| Best for | Understanding, abstraction, completion | Rules, validation, formatting, delivery |

**Golden rule**: If code can do it 100%, never use LLM. Only use LLM where things are uncertain, ambiguous, or require understanding.

## Real-World Architectures (Always Hybrid)

**Pattern: Workflow → Agent → Skills**

```
Workflow (fixed trigger)
  → Agent (handles dynamic decisions)
    → Skills (produces quality output)
```

Example — Document Processing:
```
Workflow: User selects template → uploads file → preprocessing
  → Agent: Identifies document type → selects schema → calls model → validates
    → Skills: Outputs structured JSON → normalizes dates/amounts → exports
```

## Key Insights

1. **Skills granularity should align with business capability**, not function granularity
2. **In production, Agents are often the "exception handler"**, not the default path — Workflow + Skills is the default
3. **All choices revolve around one core variable**: uncertainty × failure cost × token cost

## Related Pages

- [[AI Automation Maturity L1-L5]]
- [[n8n Workflow Engine]]
- [[Superpowers Agent Framework]]

## Sources

- [[20 Areas/AI-Learning/agent-vs-skills]] — Personal learning notes with corrections
