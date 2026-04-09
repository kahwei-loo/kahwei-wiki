---
created: 2026-04-09
updated: 2026-04-09
sources:
  - "Google Cloud GenAI KPIs, Pendo, Statsig, product case studies"
tags: [ai, product, metrics, business, kpi]
---

# AI Product Metrics

> Not model metrics (accuracy, F1) — business metrics. The question isn't "how good is the model?" but "is the AI feature making the product more valuable?"

## Primary Metrics

| Metric | What It Measures | Target Range | How to Measure |
|--------|-----------------|-------------|----------------|
| **Task completion rate** | Did the AI solve the user's problem end-to-end? | 60-80% (support), higher (code) | User feedback + automated detection |
| **Deflection rate** | Queries resolved without human escalation | 20-40% in first 90 days | Track handoff to human |
| **Cost per conversation** | Total LLM + infra cost per interaction | Track trend, not absolute | [[LLM Observability and Monitoring\|Observability]] pipeline |
| **CSAT for AI** | User satisfaction post-AI interaction | Compare to human baseline | Post-interaction survey |
| **Adoption rate** | % of eligible users engaging with AI | 30%+ within 60 days | Feature analytics |
| **Time-to-value** | Time from first interaction to outcome | Seconds/minutes, not hours | Event timing |
| **Hallucination rate** | Factual errors (user-reported + automated) | <5% for production | Feedback + [[AI Evals and Testing\|eval pipeline]] |
| **Retention impact** | Cohort retention: AI users vs non-AI users | Positive delta | A/B cohort analysis |

## How Leading Companies Measure

### Intercom Fin (Customer Support AI)
- **Resolution rate**: Fully resolved without human handoff
- **Handoff rate**: When AI transfers to human (lower = better)
- **CSAT per AI conversation**: Compared against human agent CSAT
- **Time to resolution**: AI vs human baseline

### GitHub Copilot (Code AI)
- **Acceptance rate**: % of suggestions accepted by developer
- **Persistence rate**: Lines of code still present after 30 seconds (not immediately deleted)
- **Developer productivity surveys**: Self-reported impact

### Notion AI (Productivity AI)
- **Feature adoption %**: How many users try AI features
- **Task completion speed improvement**: Before/after AI
- **Retention lift**: AI users vs non-AI users

## Setting AI Product OKRs

**Structure**: "Increase [quality metric] from X to Y, while maintaining [cost metric] below Z."

Always pair quality with cost — optimizing one without the other leads to either expensive perfection or cheap garbage.

**Examples**:
- "Increase task completion rate from 45% to 65% while keeping cost per conversation under $0.15"
- "Achieve 30% deflection rate within 90 days with CSAT ≥ 4.0/5.0"
- "Reach 40% AI feature adoption with <5% hallucination rate"

## Metrics by Product Stage

| Stage | Focus Metrics | Why |
|-------|-------------|-----|
| **MVP** | Adoption rate, task completion, qualitative feedback | Does anyone use it? Does it work? |
| **Growth** | Deflection rate, CSAT, cost per conversation | Is it providing business value? Is it sustainable? |
| **Scale** | Retention impact, revenue attribution, cost optimization | Is it a competitive advantage? |

## Anti-Patterns

| Anti-Pattern | Why It's Bad | Do This Instead |
|-------------|-------------|-----------------|
| Only measuring accuracy/F1 | Model metrics ≠ product metrics | Measure task completion and user satisfaction |
| No cost tracking | AI costs can spike unpredictably | Track cost per interaction from day 1 |
| Comparing AI to perfection | No system is 100% — compare to human baseline | Benchmark against human agents / manual process |
| Measuring adoption without quality | High adoption + low quality = user frustration | Always pair adoption with satisfaction |

## Related Pages

- [[LLM Observability and Monitoring]]
- [[AI Cost Optimization]]
- [[AI Evals and Testing]]
- [[AI Product Architecture]]

## Sources

- [GenAI KPIs — Google Cloud](https://cloud.google.com/transform/gen-ai-kpis-measuring-ai-success-deep-dive)
- [10 Essential KPIs for AI Agents — Pendo](https://www.pendo.io/essential-kpis-measuring-ai-agent-performance/)
- [Top KPIs for AI Products — Statsig](https://www.statsig.com/perspectives/top-kpis-ai-products)
