---
created: 2026-04-09
updated: 2026-04-09
sources:
  - "Vercel AI SDK docs, TheFrontKit, production product analysis"
tags: [ai, ux, frontend, product, streaming]
---

# AI UX Patterns

> The craft of AI UX is managing unpredictability. LLM responses have variable latency, variable quality, and variable length. Every pattern here exists to make that unpredictability feel smooth to users.

## Streaming UI

SSE (Server-Sent Events) remains the production standard for token streaming. Not WebSockets — SSE auto-reconnects, works over standard HTTP, simpler infrastructure.

### Rendering Rules

| Rule | Why |
|------|-----|
| Buffer incomplete markdown before rendering | Partial code fences and half-formed links break the UI |
| Container grows without shifting surrounding elements | Prevent CLS (Cumulative Layout Shift) |
| Stop button prominent during streaming | Users need control over runaway responses |
| Throttle rendering during fast delivery | Prevent excessive re-renders (Vercel AI SDK: `experimental_throttle`) |

### Accessibility for Streaming

- `aria-live="polite"` on response container
- `aria-atomic="false"` so screen readers announce only new tokens
- Debounce announcements to every few seconds (not every token)

### Framework Reference

Vercel AI SDK `useChat` manages `submitted`, `streaming`, `ready`, and `error` states out of the box. This is the most mature React abstraction for streaming AI UI.

## Loading States

| Latency | Pattern | Example |
|---------|---------|---------|
| <2s | Skeleton shimmer (3-5 lines, decreasing widths) | Standard AI response panel |
| 2-5s | Skeleton + subtle pulse animation | Longer generation tasks |
| 5-15s | Phase indicator ("Searching... Analyzing... Generating...") | RAG + generation pipeline |
| >15s | Progress bar with elapsed time + cancel button | Batch processing, agent tasks |

**Key insight**: Skeleton screens outperform spinners for AI because they communicate "active processing" rather than "waiting."

## Error Handling

### The Rule: Errors at Point of Action

Never use global toasts for AI errors. Show the error where the action happened, with a retry button inline.

| Error Type | User-Facing Pattern |
|-----------|-------------------|
| LLM timeout | "Taking longer than expected. [Retry] or [Try simpler question]" |
| Rate limit | "Busy right now. Try again in ~30 seconds." (show countdown) |
| Model error | "Something went wrong. [Retry with different approach]" |
| Quality concern | Inline disclaimer: "AI-generated — verify important details" |
| AI unavailable | Show manual alternatives with clear CTA |

### Fallback Strategy

```
Primary model (Sonnet) fails
  → Retry once
  → Fall back to cheaper model (Haiku) with quality disclaimer
  → Fall back to cached/template response
  → Show "AI unavailable" with manual alternative
```

## Confidence and Disclaimers

**Don't show numerical confidence scores to end users.** ChatGPT, Claude.ai, and Notion AI all avoid this — numbers create false precision and confuse non-technical users.

**Do use**:
- Inline disclaimers: "AI-generated — verify important details"
- Source citations: "Based on [Document X, page 3]"
- Uncertainty language: "I'm not sure about this, but..."

## Feedback Mechanisms

The production standard:

| Mechanism | Purpose | Implementation |
|-----------|---------|---------------|
| **Thumbs up/down** | Primary quality signal | On every AI response |
| **Regenerate** | Let user retry without changing input | Button below response |
| **Edit response** | User corrects AI output | Inline edit mode |
| **Copy** | Utility | One-click copy button |
| **Report** | Safety/quality escalation | Separate from thumbs down |

Track whether users **accepted, modified, or rejected** AI suggestions — this is more informative than thumbs up/down alone. GitHub Copilot and Intercom Fin use this as their primary quality signal.

## Conversation UX Decisions

| Decision | Pattern | When |
|----------|---------|------|
| Show context usage | Progress bar or "X% context used" | Power users, long conversations |
| "New chat" button | Prominent, always visible | When context staleness is a risk |
| Pin/unpin messages | Let users mark important context | Long multi-turn sessions |
| Auto-summarize history | Background summarization on context pressure | Long conversations (see [[Claude Code Architecture Deep Dive|Claude Code's 5 compression strategies]]) |

## Real Product References

| Product | Key UX Decision |
|---------|----------------|
| **ChatGPT** | Streaming + markdown rendering, model selector, regenerate button |
| **Claude.ai** | Artifact panel (code/docs side-by-side), extended thinking indicator |
| **Notion AI** | Inline AI in existing document, not a separate chat panel |
| **Cursor** | Tab completion (copilot) + side panel (chat) + background agent |
| **Intercom Fin** | AI resolves, shows sources, hands off to human seamlessly |

## Related Pages

- [[Production Prompt Engineering]]
- [[AI Product Metrics]]
- [[AI Product Architecture]]

## Sources

- [AI Chat UI Best Practices — TheFrontKit](https://thefrontkit.com/blogs/ai-chat-ui-best-practices)
- [Streaming LLM Responses Guide — DEV](https://dev.to/pockit_tools/the-complete-guide-to-streaming-llm-responses-in-web-applications-from-sse-to-real-time-ui-3534)
- [Vercel AI SDK useChat](https://ai-sdk.dev/docs/reference/ai-sdk-ui/use-chat)
- [SSE for LLMs in 2026](https://procedure.tech/blogs/the-streaming-backbone-of-llms-why-server-sent-events-(sse)-still-wins-in-2025)
