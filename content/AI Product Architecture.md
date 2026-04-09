---
created: 2026-04-09
updated: 2026-04-09
sources:
  - "Vercel AI SDK, Stripe AI billing, Azure multi-tenant guide, production case studies"
tags: [ai, architecture, product, system-design, commercial]
---

# AI Product Architecture

> Beyond the AI component — the complete system: auth, billing, API, frontend, queues, monitoring. This is what separates "I built an AI demo" from "I shipped an AI product."

## Production Stack

```
┌──────────────────────────────────────────┐
│  Client: React + AI SDK useChat          │
│  (streaming, feedback, error handling)    │
└──────────────┬───────────────────────────┘
               │
┌──────────────┴───────────────────────────┐
│  API Gateway / Rate Limiter              │
│  (cost-aware, per-tenant budgets)        │
└──────────────┬───────────────────────────┘
               │
┌──────────────┴───────────────────────────┐
│  App Server (Next.js / FastAPI)          │
│  ┌──────┬──────┬──────┬──────┐          │
│  │ LLM  │ RAG  │ Job  │Auth +│          │
│  │Router│ Svc  │Queue │Billing│         │
│  └──┬───┴──┬───┴──┬───┴──┬───┘          │
└─────┼──────┼──────┼──────┼───────────────┘
      │      │      │      │
   Model   Vector  Redis/  Stripe
   APIs    DB      BullMQ  Billing
```

## Auth + Billing for AI

### Usage-Based Pricing

Stripe (acquired Metronome) now supports native token metering:
- Send granular usage data (tokens, API calls, agent tasks)
- Apply markup percentages automatically
- Generate invoices with line-item breakdown

### Credit System Pattern

```
User signs up → receives 100 free credits
Each AI request → deducts estimated credits
Credits run out → prompt upgrade or purchase
Auto top-up option for paying users
```

### Implementation Options

| Tool | Approach | Best For |
|------|----------|----------|
| **Stripe Metering** | Native usage events → invoice | SaaS with predictable pricing |
| **Orb** | Usage-based billing platform | Complex pricing tiers |
| **Custom** | Track in DB, bill via Stripe | Maximum flexibility |

## API Design for AI

### Streaming Endpoints

Use SSE (not WebSockets) for streaming responses:

```
POST /api/chat
Content-Type: application/json
→ Response: Content-Type: text/event-stream

data: {"type":"text","content":"Hello"}
data: {"type":"text","content":" world"}
data: {"type":"tool_use","name":"search","input":{...}}
data: {"type":"done"}
```

SSE auto-reconnects, works over standard HTTP, simpler infrastructure than WebSockets.

### Long-Running Tasks (>30s)

```
POST /api/process → 202 Accepted, { "job_id": "abc123" }

GET  /api/jobs/abc123 → { "status": "processing", "progress": 45 }
  or
Webhook → POST https://your-app.com/webhooks/job-complete
```

### Rate Limiting

Rate limit by **estimated cost**, not just request count:

```
Traditional: max 100 requests/minute
AI-aware:    max $1.00/minute per user
```

A single agentic conversation can cost $0.20-$0.50 — traditional rate limits don't prevent cost spikes.

## Queue / Async Patterns

BullMQ (Redis) or SQS for job queues.

```
Accept request → return job ID → process async → notify on complete
```

Track progress with phases:
```
"queued" → "processing" → "generating" → "complete"
           (with progress %)
```

Essential for: batch processing, document processing, multi-step agent tasks, anything >30s.

## Multi-Tenant Isolation

Isolate at three levels:

| Level | What to Isolate | Pattern |
|-------|----------------|---------|
| **Data** | Each tenant's documents, embeddings | Row-level security or schema-per-tenant in vector DB |
| **Cost** | Per-tenant budget and usage | Budget caps + usage tracking per tenant ID |
| **Config** | Prompt templates, model, temperature | Per-tenant config table, loaded at request time |

**Key**: Include tenant ID in every LLM call's metadata for cost attribution and debugging.

## Frontend Architecture

### React Patterns for AI

```tsx
// Vercel AI SDK pattern
const { messages, input, handleSubmit, isLoading, error } = useChat({
  api: '/api/chat',
  onError: (err) => showInlineError(err),  // not toast
})
```

### State Management for Streaming

| State | UI |
|-------|-----|
| `idle` | Input focused, ready |
| `submitted` | Skeleton shimmer loading |
| `streaming` | Progressive text rendering + stop button |
| `error` | Inline error + retry button |
| `complete` | Full response + feedback buttons |

See [[AI UX Patterns]] for detailed UI patterns.

## Scaling Trajectory

### MVP (0-1K users)
- Single server, direct LLM API calls
- Stripe basic billing
- Langfuse free tier for monitoring
- SQLite or Postgres for everything

### Growth (1K-10K users)
- Add job queue (BullMQ/Redis)
- Caching layer (Redis for responses, prompt cache for LLM)
- CDN for static assets
- Helicone or Langfuse for cost monitoring
- Per-tenant rate limits

### Scale (10K-100K+ users)
- Multi-region deployment
- Model routing with provider fallback chains
- Dedicated vector DB cluster
- Enterprise observability (Arize/Datadog)
- Cost-aware autoscaling
- Multi-tenant data isolation audit

## Real Architecture References

| Product | Key Architecture Decision |
|---------|------------------------|
| **Vercel v0** | AI SDK + streaming RSC (React Server Components) + generative UI |
| **Cursor** | Custom streaming protocol, aggressive client-side caching, speculative execution |
| **Intercom Fin** | RAG over help center content, human handoff detection, resolution tracking |
| **Jasper** | Multi-model routing, template-based generation, brand voice fine-tuning |

## System Design Interview Checklist

When designing an AI product in an interview:

- [ ] How do users interact with AI? (Chat, inline, background, agent)
- [ ] What model(s) and why? (Cost/quality trade-off, routing)
- [ ] Where does knowledge come from? (RAG, fine-tuning, prompt)
- [ ] How do you handle failure? (Fallback, retry, human escalation)
- [ ] How do you measure success? ([[AI Product Metrics]])
- [ ] How do you control costs? ([[AI Cost Optimization]])
- [ ] How do you monitor quality post-launch? ([[LLM Observability and Monitoring]])
- [ ] How do you handle multi-tenancy? (Data, cost, config isolation)
- [ ] How do you bill for AI usage? (Credits, usage-based, flat rate)
- [ ] How do you handle security? ([[LLM Security and Guardrails]])

## Related Pages

- [[AI UX Patterns]]
- [[AI Product Metrics]]
- [[LLM Observability and Monitoring]]
- [[AI Cost Optimization]]
- [[LLM Security and Guardrails]]
- [[Multi-Agent Architecture Patterns]]

## Sources

- [Vercel AI SDK 5](https://vercel.com/blog/ai-sdk-5)
- [Stripe AI Billing Tools](https://www.pymnts.com/news/artificial-intelligence/2026/stripe-introduces-billing-tools-to-meter-and-charge-ai-usage/)
- [Usage-Based Billing for AI — Flexprice](https://flexprice.io/blog/best-open-source-usage-based-billing-platform-for-an-ai-startup-(2025-guide))
- [Multi-Tenant AI Architecture — Azure](https://azure.github.io/AI-in-Production-Guide/chapters/chapter_13_building_for_everyone_multitenant_architecture)
