---
created: 2026-04-09
updated: 2026-04-09
sources:
  - "NAACL 2025 chunking benchmark, PremAI, production RAG guides"
tags: [ai, data, pipeline, rag, engineering]
---

# Data Engineering for AI

> The quality of your AI product is bounded by the quality of your data. Fine-tuning, RAG, and evals all depend on data pipelines. This page covers the engineering — not the AI, but the plumbing that makes AI work.

## RAG Data Pipeline (Production)

```
Sources (docs, APIs, DBs)
  → Ingest (webhook/CDC/scheduled)
  → Clean & Parse (extract text, strip formatting)
  → Chunk (strategy depends on content type)
  → Embed (batch, with caching)
  → Vector Store (upsert, with metadata)
  → Freshness Monitor (staleness alerts)
```

### Incremental Ingestion (Not One-Time Bulk)

Production RAG requires change detection:

| Pattern | How It Works | Best For |
|---------|-------------|----------|
| **Content hash comparison** | Hash content on ingest, skip if unchanged | Document repos, knowledge bases |
| **CDC (Change Data Capture)** | Database triggers push changes | Structured data sources |
| **Webhook-driven** | Source system notifies on change | SaaS integrations (Notion, Confluence) |
| **Scheduled re-scan** | Cron job checks for updates | Sources without change notifications |

Always track **last-updated timestamp per source** on a freshness dashboard.

## Chunking Strategies

A NAACL 2025 study (Vectara) across 25 chunking configs and 48 embedding models found: **chunking strategy matters as much as embedding model choice**.

| Strategy | Chunk Size | Best For | Complexity |
|----------|-----------|----------|-----------|
| **Fixed-size** | 512-1024 tokens, 10-20% overlap | Reliable baseline for most content | Low |
| **Recursive character** | Split on `\n\n` → `\n` → `. ` → ` ` | Code, mixed-format documents | Low |
| **Markdown header** | Split on `#`, `##`, `###` | Documentation, wikis | Low |
| **Semantic** | Split on topic boundaries (embedding similarity) | Heterogeneous corpora | High |

**Practical advice**: Start with fixed-size (512 tokens, 50-token overlap). Only move to semantic chunking if eval metrics show retrieval quality issues with fixed-size.

## Embedding Models (April 2026)

| Model | Dimensions | Max Context | Best For |
|-------|-----------|-------------|----------|
| **Voyage AI voyage-3-large** | 1024 | 32K tokens | Highest MTEB score, long documents |
| **OpenAI text-embedding-3-small** | 1536 | 8K tokens | Cost-effective, good enough for most |
| **OpenAI text-embedding-3-large** | 3072 | 8K tokens | Higher precision when small isn't enough |

**Always evaluate on your domain before choosing.** MTEB leaderboard rankings don't transfer perfectly to every use case.

### Embedding Pipeline Pattern

```python
# Batch embedding with caching
for chunk in chunks:
    cache_key = hash(chunk.content + model_version)
    if cache_key in embedding_cache:
        embedding = embedding_cache[cache_key]
    else:
        embedding = embed(chunk.content)  # batch these
        embedding_cache[cache_key] = embedding
    vector_store.upsert(chunk.id, embedding, chunk.metadata)
```

## Data Quality Monitoring

| Metric | What to Monitor | Alert When |
|--------|----------------|-----------|
| **Embedding drift** | Cosine similarity distribution shift over time | Distribution diverges >10% from baseline |
| **Retrieval relevance** | Average relevance score of retrieved chunks | Drops below threshold |
| **Chunk hit rate** | % of stored chunks that actually get retrieved | <5% of chunks ever retrieved (over-indexing) |
| **Source freshness** | Last-updated timestamp per source | Any source >7 days stale |
| **Ingestion errors** | Failed parses, encoding issues, timeout | >1% failure rate |

## Synthetic Data Generation

The dominant pattern for [[Fine-tuning vs Prompting vs RAG|fine-tuning cost optimization]]:

```
1. Define task and format (classification, QA, generation)
2. Write 10-20 high-quality examples manually (golden set)
3. Use frontier model (Opus, GPT-4o) to generate 10K-100K variations
4. Filter: remove low-quality, deduplicate, validate format
5. Fine-tune smaller model on synthetic dataset
6. Evaluate against golden set + held-out real data
```

**Pitfalls**:
- Model collapse: synthetic data amplifies frontier model's biases
- Distribution mismatch: synthetic != real user queries
- **Mitigation**: Always mix 10-20% real data into synthetic training set

## Data Labeling

| Tool | Type | Best For |
|------|------|----------|
| **Label Studio** | Open source, self-hosted | Full control, custom workflows |
| **Argilla** | Open source, HuggingFace integrated | ML-focused labeling, active learning |
| **Scale AI** | Managed service | Volume labeling, enterprise |

**Active learning pattern**: Use model confidence to prioritize what to label. Label the examples the model is most uncertain about — maximum information gain per label.

## PII Handling

Strip PII **before** embedding, not after retrieval:

```
Ingestion pipeline:
  → Entity recognition (spaCy, Microsoft Presidio)
  → Redact or tokenize PII
  → Embed redacted content
  → Store PII mapping separately (if needed for reconstruction)

Retrieval:
  → Access control at chunk level
  → Tag chunks with permission scopes
  → Filter at retrieval time, not after generation
```

## Minimum Viable Datasets

| Task | Minimum for Few-Shot | Minimum for Fine-Tuning |
|------|---------------------|------------------------|
| Classification | 50-100 examples per class | 500+ per class |
| QA / RAG | 10-20 high-quality documents | 1K+ Q&A pairs |
| Generation | 5-10 examples in prompt | 5K-10K examples |
| Extraction | 20-30 annotated examples | 500+ annotated documents |

**Starting advice**: Even 10-20 high-quality documents can power effective RAG if chunking and retrieval are solid. Data quality >>> data quantity.

## Related Pages

- [[RAG Architecture Patterns 2026]]
- [[Fine-tuning vs Prompting vs RAG]]
- [[AI Evals and Testing]]
- [[AI Product Architecture]]

## Sources

- [RAG Chunking Strategies 2026 Benchmark — PremAI](https://blog.premai.io/rag-chunking-strategies-the-2026-benchmark-guide/)
- [Production RAG Pipeline — Data Engineer Academy](https://dataengineeracademy.com/blog/production-rag-pipeline/)
- [RAG in Production 2026 — Use Apify](https://use-apify.com/blog/rag-production-architecture-2026)
- [Label Studio](https://labelstud.io/)
- [Argilla](https://argilla.io/)
