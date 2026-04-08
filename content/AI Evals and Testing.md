---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "Braintrust, DeepEval, Qdrant RAG eval guide, industry practices"
tags: [ai, testing, evals, production, quality]
---

# AI Evals and Testing

> The hardest problem in production AI: "How do you know your product is working?" Eval-driven development (EDD) is becoming the AI equivalent of TDD. The key insight: optimize retrieval quality, not model selection — when generation hallucinates, the root cause is almost always bad retrieval.

## The Eval Platform Landscape

| Platform | Type | Strength | Notable |
|----------|------|----------|---------|
| **Braintrust** | SaaS | End-to-end eval lifecycle (datasets, scoring, experiments, CI gates) | $80M raise Feb 2026, $800M valuation |
| **Promptfoo** | OSS → acquired | Red-teaming, security testing, CLI-native | Acquired by OpenAI for $86M (March 2026) |
| **LangSmith** | SaaS | LangChain/LangGraph native, full execution tree rendering | Best for LangChain stacks |
| **DeepEval** | OSS (Python) | 50+ metrics, Pytest integration, CI/CD native | v3.0: component-level granularity, agent simulation |
| **Arize Phoenix** | OSS | OpenTelemetry-based, span-level tracing | Best for production observability |
| **Maxim AI** | SaaS | RAG-specific evaluation | Leading RAG eval platform |
| **Evidently** | OSS | 25M+ downloads, regression testing, drift detection | Best for monitoring over time |

## Types of Evals

### LLM-as-Judge
Model scores another model's output. Fast, scalable, cheapest at volume.
- Cost: ~$0.01-0.10 per evaluation
- Use smaller models (GPT-4o-mini, Haiku) for routine evals, larger for calibration
- Requires calibration against human judgments to be trustworthy
- Both DeepEval and Braintrust support this natively

### Human Eval
Gold standard. Expensive. Used for:
- Calibrating automated metrics
- High-stakes decisions
- Subjective quality assessment
- Braintrust and LangSmith provide annotation UIs

### Automated Metrics
BLEU, ROUGE, semantic similarity, faithfulness, hallucination detection. Applied in CI/CD pipelines for regression testing.

### Regression Testing
Fixed test suites on every prompt/model change. Braintrust enforces as a release gate.

## Eval-Driven Development (EDD)

The AI equivalent of TDD. Real and growing practice in 2026:

```
1. Define eval datasets
   (questions + expected outputs + context)

2. Write metric definitions
   (faithfulness, relevance, tool accuracy)

3. Run evals on every change
   (prompt edits, model swaps, retrieval config changes)

4. Gate releases on eval scores
   (thresholds must pass before deploy)

5. Monitor production with the same metrics
   (continuous, not just pre-deploy)
```

Braintrust is the primary platform enabling this end-to-end. DeepEval's Pytest integration makes EDD feel like TDD for AI.

## Testing RAG Systems

Evaluate **retrieval and generation separately** — when generation fails, the root cause is almost always retrieval:

### Retrieval Metrics
| Metric | What It Measures |
|--------|-----------------|
| Context Precision | % of retrieved chunks that are relevant |
| Context Recall | % of relevant chunks that were retrieved |
| NDCG | Precision weighted by position (top results matter more) |

NDCG correlates most strongly with end-to-end quality — better than binary precision/recall.

### Generation Metrics
| Metric | What It Measures |
|--------|-----------------|
| Faithfulness | Every claim grounded in retrieved context? |
| Answer Relevancy | Does the answer address the question? |
| Hallucination Rate | Claims not supported by any retrieved chunk |

### End-to-End
Answer correctness vs ground truth, latency, token usage.

### Anti-Pattern
Optimizing prompts to maximize Ragas scores produces systems that score well on evals but fail on production queries with slight variations. **Metrics should track quality, not be the optimization target.**

## Testing Agents

The hardest unsolved problem. Key approaches:

| Approach | What It Tests |
|----------|--------------|
| **Step-level eval** | Score each step independently — wrong tool call in step 2 corrupts everything |
| **Tool selection accuracy** | Did the agent pick the right tool? |
| **Planning quality** | Was the plan reasonable before execution? |
| **Multi-turn simulation** | Generate realistic branching conversations (DeepEval v3.0) |
| **Trajectory eval** | Compare actual path against ideal trajectories |

The key insight: evaluate the **process** (tool selection, planning, reasoning), not just the final output. A correct answer reached via wrong reasoning is a ticking time bomb.

## Cost and Latency

| Dimension | Typical Range |
|-----------|--------------|
| LLM-as-judge per eval | $0.01-0.10 |
| 500-case eval suite | $5-50 per run |
| Full suite latency | 2-10 minutes (parallelized) |
| Production monitoring | Continuous sampling, ~1-5% of requests |

Cost optimization: Use smaller models (Haiku, GPT-4o-mini) for routine evals, larger models for calibration and edge cases.

## Emerging Standards

- **OpenTelemetry** as the standard for LLM tracing and observability
- **Traceability**: Link every eval score to exact prompt version, model, and dataset
- **CI/CD integration**: Evals as first-class pipeline stages, not afterthoughts
- **Governance hooks**: Audit trails, score history, approval workflows for enterprise

## Practical Starting Guide

**If building from scratch**:
1. Start with DeepEval (free, Pytest integration) for development-time evals
2. Create 50-100 representative test cases covering your key use cases
3. Define 3-5 core metrics (faithfulness, relevance, and domain-specific ones)
4. Add to CI pipeline — fail the build if scores drop below thresholds
5. Add Arize Phoenix for production monitoring

**If using managed tools**:
- Braintrust for the full lifecycle (datasets → evals → experiments → CI → monitoring)
- LangSmith if your stack is LangChain/LangGraph

## Related Pages

- [[RAG Architecture Patterns 2026]]
- [[Multi-Agent Architecture Patterns]]
- [[AI Coding Tools Landscape 2026]]

## Sources

- [DeepEval Alternatives 2026 — Braintrust](https://www.braintrust.dev/articles/deepeval-alternatives-2026)
- [AI Agent Evaluation — DeepEval](https://deepeval.com/guides/guides-ai-agent-evaluation)
- [RAG Evaluation Guide — Qdrant](https://qdrant.tech/blog/rag-evaluation-guide/)
- [RAG Evaluation Metrics 2026 — Prem AI](https://blog.premai.io/rag-evaluation-metrics-frameworks-testing-2026/)
- [Best LLM Eval Tools for Agents — Confident AI](https://www.confident-ai.com/knowledge-base/best-llm-evaluation-tools-for-ai-agents)
- [Top 5 Eval Tools After Promptfoo Exit — DEV](https://dev.to/nebulagg/top-5-ai-agent-eval-tools-after-promptfoos-exit-576i)
