---
created: 2026-04-09
updated: 2026-04-09
sources:
  - "Helicone, Langfuse, Arize Phoenix, OpenTelemetry GenAI spec"
tags: [ai, observability, monitoring, production, ops]
---

# LLM Observability & Monitoring

> [[AI Evals and Testing|Evals]] are pre-production. This is post-production. The dashboard needs: latency (p50/p95/p99), token usage, error rate, cost per request, and quality drift over time.

## What to Monitor

| Metric | Why | Alert Threshold |
|--------|-----|----------------|
| **Latency** (p50/p95/p99) | User experience, SLA compliance | p95 > 5s |
| **Token usage** per request | Cost control, prompt bloat detection | >2x rolling average |
| **Error rate** by type | Reliability | >1% over 5 minutes |
| **Cost per request/conversation** | Budget management | >$0.50/conversation (adjust per product) |
| **Quality drift** | User feedback ratio degradation over time | Thumbs-down rate >15% |
| **Cache hit rate** | Cost optimization effectiveness | <80% for stable prompts |

## Tool Landscape (April 2026)

| Tool | Approach | Best For | Pricing (~100K req/mo) |
|------|----------|----------|----------------------|
| **Langfuse** | SDK-based, self-hostable | Full-featured, open-source teams | Free (self-hosted) |
| **Helicone** | Proxy-based (one-line setup) | Fast setup, cost visibility | ~$79/mo Pro |
| **LangSmith** | Native LangChain integration | LangChain/LangGraph teams | ~$195+ |
| **Arize Phoenix** | OpenTelemetry-native | Enterprise, data lake integration | Free OSS |
| **Braintrust** | Eval + observability combined | Teams wanting eval + monitoring in one | Usage-based |

**Recommendation**: Start with **Langfuse** (self-hosted) or **Helicone** (managed). Move to Arize for enterprise data lake integration.

## OpenTelemetry for LLM (Emerging Standard)

The `gen_ai.*` semantic conventions are experimental but adoptable now. Datadog supports them natively since OTel v1.37.

Key attributes to instrument:

```
gen_ai.system          = "anthropic" | "openai" | ...
gen_ai.request.model   = "claude-sonnet-4-20250514"
gen_ai.usage.input_tokens  = 1523
gen_ai.usage.output_tokens = 847
gen_ai.response.finish_reason = "end_turn" | "tool_use"
```

**Instrument these early** — they are becoming the standard across the industry.

## Logging Rules

### What to Log
- Model name and version
- Token counts (input, output, thinking)
- Latency (TTFT, total)
- HTTP status code
- Request ID (correlation ID)
- User ID (hashed, not raw)
- Tool calls made and results summary
- Cost per request

### What NOT to Log
- Raw prompts containing PII
- Full response bodies in production (sample instead)
- API keys (obviously)
- User content without consent

**Format**: Structured JSON with correlation IDs that trace from user action → API gateway → app server → LLM call → tool execution → response.

## Cost Monitoring & Denial-of-Wallet

Traditional rate limiting (requests/second) is insufficient for AI — a single agentic conversation with tool calls can cost $0.20-$0.50.

**Production pattern**:
```
Before LLM call:
  1. Check user's remaining budget
  2. Estimate call cost (input tokens × price)
  3. If over budget → reject or downgrade model
  4. After call → deduct actual cost from budget
```

**Alert at**:
- 80% of daily/weekly budget per user
- 150% of expected daily cost (spike detection)
- Any single request >$1 (agent runaway detection)

## Debugging Production AI Issues

Trace a bad response back to root cause:

```
Bad user experience
  → Find request ID in feedback/logs
  → Trace in observability tool (Langfuse/Helicone)
  → Check: Was the prompt correct?
  → Check: Was retrieval quality good? (RAG)
  → Check: Did the model hallucinate despite good context?
  → Check: Was there a tool call failure?
  → Root cause → fix → add to eval suite to prevent regression
```

## A/B Testing Models in Production

Safe model swap pattern:

```
1. Deploy new model behind feature flag (5% traffic)
2. Run same eval suite on both models' production output
3. Monitor: latency, cost, quality (user feedback + automated)
4. Gradually increase traffic: 5% → 25% → 50% → 100%
5. Rollback if any metric degrades beyond threshold
```

## Production Dashboard (What to Display)

| Panel | Metrics |
|-------|---------|
| **Health** | Error rate, latency p50/p95, uptime |
| **Cost** | Daily spend, cost per conversation, top spenders |
| **Quality** | Thumbs up/down ratio, hallucination reports, task completion |
| **Usage** | Requests/day, tokens/day, unique users, feature adoption |
| **Alerts** | Budget spikes, error spikes, quality degradation |

## Related Pages

- [[AI Evals and Testing]]
- [[AI Cost Optimization]]
- [[AI Product Metrics]]
- [[LLM Security and Guardrails]]

## Sources

- [Top 7 LLM Observability Tools 2026 — Confident AI](https://www.confident-ai.com/knowledge-base/top-7-llm-observability-tools)
- [LLM Observability Platforms Guide — Helicone](https://www.helicone.ai/blog/the-complete-guide-to-LLM-observability-platforms)
- [OpenTelemetry GenAI Semantic Conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/)
- [OTel LLM Tracing Standard](https://earezki.com/ai-news/2026-03-21-opentelemetry-just-standardized-llm-tracing-heres-what-it-actually-looks-like-in-code/)
- [Denial-of-Wallet Rate Limiting](https://handsonarchitects.com/blog/2025/denial-of-wallet-cost-aware-rate-limiting-part-1/)
