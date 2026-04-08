---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "[[20 Areas/AI-Learning/ClaudeCode/业界在向量索引和相似度阈值方面的最佳实践]]"
tags: [ai, rag, vector-db, engineering]
---

# Vector Indexing and Similarity Threshold Best Practices

> Production RAG systems need three things right: the correct index type, adaptive thresholds, and hybrid retrieval with reranking. Fixed thresholds and pure vector search are the two most common mistakes.

## Vector Index Selection

| Index | Technique | Best For | Products |
|-------|-----------|----------|----------|
| **HNSW** | Hierarchical graph | High accuracy + fast query (any scale) | Pinecone, Weaviate, Qdrant |
| **IVF** | Inverted index | Large-scale (1M+), but unstable at small scale | Faiss, Milvus |
| **Flat** | Brute force | Small datasets (<100K) | All (fallback) |
| **Hybrid** | HNSW + IVF | Ultra-large scale (100M+) | Qdrant, pgvector 0.5+ |

**HNSW is the industry standard** — works at any data size with ~99% accuracy and 15ms query time (vs IVF's 65% accuracy at small scale).

### pgvector Configuration by Scale

```sql
-- Small (<10K): No index, sequential scan is fine (<100ms)
-- Medium (10K-100K): HNSW with balanced params
CREATE INDEX ON embeddings USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- Large (>100K): HNSW with aggressive params
CREATE INDEX ON embeddings USING hnsw (embedding vector_cosine_ops)
WITH (m = 32, ef_construction = 128);
```

## Similarity Threshold Strategies

### Problem: Fixed Thresholds Don't Work

A fixed `0.7` threshold fails across different query types and data distributions.

### Solution 1: Gap-Based Method (Google Research)

Find the "cliff" in similarity scores — there's usually a natural gap between relevant and irrelevant results:

```
Doc A: 0.85 ┐
Doc B: 0.82 ├─ Relevant group
Doc C: 0.78 ┘
─── Gap ───── ← Natural breakpoint
Doc D: 0.45 ┐
Doc E: 0.42 ├─ Irrelevant group
```

Set threshold at the midpoint of the largest gap.

### Solution 2: Adaptive Threshold

Combine statistical analysis (mean - 1 std dev) with query-type-specific thresholds:

| Query Type | Threshold | Rationale |
|-----------|-----------|-----------|
| Definition ("What is X") | 0.6 | Needs precision |
| Enumeration ("List all X") | 0.4 | Needs recall |
| How-to ("How to do X") | 0.7 | Needs accuracy |
| Exploratory ("About X") | 0.3 | Needs breadth |

## Hybrid Retrieval (Industry Consensus)

Pure vector search is insufficient. The production standard is a three-stage pipeline:

### Stage 1: Recall (Broad)
- Vector search (semantic similarity, threshold 0.3)
- BM25 keyword search (exact matching)
- Merge and deduplicate

### Stage 2: Rerank (Precise)
- Cross-encoder model re-scores all candidates
- Much more accurate than bi-encoder similarity

### Stage 3: Select (Strict)
- Gap-based dynamic threshold on rerank scores
- Return only top results above threshold

### Performance Impact (Cohere data)

| Method | Recall | Accuracy | User Satisfaction |
|--------|--------|----------|-------------------|
| Vector only | 65% | 78% | 3.2/5 |
| Vector + keyword | 82% | 81% | 3.8/5 |
| Vector + keyword + rerank | **89%** | **91%** | **4.3/5** |

## Production Configuration Reference

```python
RETRIEVAL = {
    "stages": [
        {"name": "recall", "method": "hybrid", "top_k": 50, "threshold": 0.25},
        {"name": "rerank", "model": "cross-encoder/ms-marco-MiniLM-L-12-v2", "top_k": 20},
        {"name": "select", "method": "gap_based", "min_score": 0.6, "max_k": 10},
    ]
}
```

## Cost Guide

| Service | Monthly Cost | Best For |
|---------|-------------|----------|
| pgvector (self-hosted) | ~$60 | <1M vectors |
| Qdrant Cloud | $25-115 | Mid-scale, cost-sensitive |
| Pinecone | $70-300 | Quick start, zero ops |

## Implementation Roadmap

1. **Week 1**: Switch to HNSW index, lower default threshold to 0.5, add similarity score logging
2. **Week 2-4**: Implement gap-based threshold, add BM25 keyword search
3. **Week 5-8**: Cross-encoder reranking, question type classification, A/B testing
4. **Week 9+**: Migrate to dedicated vector DB, auto-tuning, user feedback loop

## Related Pages

- [[AI Automation Maturity L1-L5]]
- [[AI Agent vs Skills vs Workflow]]

## Sources

- [[20 Areas/AI-Learning/ClaudeCode/业界在向量索引和相似度阈值方面的最佳实践]] — RAG system optimization research
