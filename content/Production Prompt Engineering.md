---
created: 2026-04-09
updated: 2026-04-09
sources:
  - "Anthropic docs, Claude Code system prompt analysis, DSPy, industry practices"
tags: [ai, prompt-engineering, production, system-prompt]
---

# Production Prompt Engineering

> In 2026, prompt engineering is less about "magic phrases" and more about system prompt architecture, tool schema design, and cache economics. The craft has shifted from writing clever prompts to designing prompt systems.

## System Prompt Architecture

Production system prompts follow a structured pattern. [[Claude Code Architecture Deep Dive|Claude Code's]] system prompt is a reference — thousands of tokens organized as:

```
┌─────────────────────────────────────────────┐
│  1. Identity & Role Definition               │  ← Who the model is
│  2. Behavioral Rules (prioritized)           │  ← Safety > accuracy > helpfulness
│  3. Tool/Function Definitions                │  ← Schemas + descriptions
│  4. Context Injection (dynamic)              │  ← User files, env info, CLAUDE.md
│  5. Output Format Instructions               │  ← Structured response requirements
│  6. Examples (few-shot)                      │  ← Complex behavior demonstrations
└─────────────────────────────────────────────┘
```

**Key insight**: Tool/function schema design is now a core prompt engineering skill. A well-written `description` field in a function schema is effectively a mini-prompt. Clear parameter constraints, examples, and edge case handling in the schema dramatically improve tool use accuracy.

## Prompt Caching Economics

The single biggest cost optimization for apps with stable system prompts.

### Anthropic Prompt Caching
- Cached input tokens: **90% cheaper** than uncached
- Cache write: 25% premium on first call
- TTL: 5 minutes (resets on each cache hit)

### Design Pattern: Cache-Friendly Prompts

```
[STATIC: System prompt + tool definitions + few-shot]     ← Cached (90% savings)
[SEMI-STATIC: User profile, project context]              ← Cached shorter TTL
[DYNAMIC: Current user message]                           ← Never cached
```

**Real numbers**: 10K-token system prompt, 1M calls/month:
- Without caching: ~$30/month
- With caching: ~$3/month + first-call premium
- **Savings: ~90%**

**Design rule**: Put all static content at the beginning of the prompt. Dynamic content at the end. Never interleave — it breaks the cache prefix.

## Extended Thinking vs Manual CoT

| | Native Extended Thinking | Manual CoT ("Let's think step by step") |
|---|---|---|
| Available on | Claude (extended thinking), o1/o3/o4-mini | Any model |
| Quality | Better for math, logic, complex reasoning | Good for smaller models |
| Cost | Thinking tokens are billed | Output tokens are billed |
| Control | Budget-controllable (max thinking tokens) | Unpredictable length |
| When to use | Frontier models with native support | Smaller/cheaper models without native thinking |

**Practical rule**: If using a frontier model with native thinking, **don't add manual CoT** — it's redundant and wastes tokens. If using a smaller model (Haiku, GPT-4o-mini, open-source), manual CoT still helps.

## Structured Outputs / JSON Mode

Now standard across providers. Both a reliability pattern AND cost optimization — eliminates retry loops from malformed output.

- **Anthropic**: Tool use with strict schemas
- **OpenAI**: `response_format: { type: "json_schema", json_schema: {...} }`

**When to use**: Any time the output needs to be machine-parsed. Even for "free text" responses, consider wrapping in a schema with `content` and `metadata` fields.

## Meta-Prompting

Using LLMs to generate and optimize prompts. Standard workflow in 2026:

```
1. Write initial prompt
2. Build eval suite (50-100 test cases)
3. Use LLM to generate prompt variations
4. Score against evals
5. Iterate
```

**Tools**: DSPy (Stanford) automates prompt optimization through compilation. Anthropic's metaprompt generates system prompts from task descriptions.

This connects prompting directly to the [[AI Evals and Testing|eval pipeline]] — prompt engineering and evaluation are no longer separate activities.

## Few-Shot vs Zero-Shot in 2026

| Scenario | Approach | Why |
|----------|----------|-----|
| Frontier model + clear task | Zero-shot + structured output | Models are good enough; examples waste cache space |
| Complex formatting requirements | 2-3 examples | Show, don't tell — especially for unusual formats |
| Domain-specific terminology | 3-5 examples | Calibrate the model's vocabulary |
| Smaller/cheaper models | More examples (5-10) | Compensates for reduced capability |
| Consistency across calls | Few-shot with canonical examples | Anchors the output distribution |

**Cache tip**: Put few-shot examples in the static system prompt prefix (cached) rather than in each user message (uncached).

## Production Anti-Patterns

| Anti-Pattern | Why It's Bad | Do This Instead |
|-------------|-------------|-----------------|
| "Be very careful and thorough" | Vague, increases verbosity and cost | Specific constraints: "max 3 sentences" |
| Repeating instructions in every message | Wastes tokens, breaks cache | Put in system prompt once |
| Manual CoT on frontier models | Redundant with native thinking | Use extended thinking budget |
| Hardcoded examples in user messages | Can't be cached | Move to system prompt |
| No structured output schema | Parsing failures, retries | Always use JSON mode for machine-parsed output |

## Related Pages

- [[LLM Security and Guardrails]]
- [[AI Evals and Testing]]
- [[AI Cost Optimization]]
- [[Claude Code Architecture Deep Dive]]

## Sources

- [Anthropic Prompt Caching](https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching)
- [Anthropic Prompt Engineering Guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering)
- [DSPy — Stanford](https://github.com/stanfordnlp/dspy)
- [OpenAI Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs)
