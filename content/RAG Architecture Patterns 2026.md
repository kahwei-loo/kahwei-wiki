---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "Neo4j, Anthropic Contextual Retrieval, industry RAG analyses"
tags: [ai, rag, architecture, engineering]
---

# RAG Architecture Patterns 2026

> When RAG fails, the failure point is retrieval, not generation. Proper retrieval pipelines reduce hallucinations by 70-90%. Most teams under-invest in retrieval quality relative to model selection.

## The Foundation: Hybrid Search (Table Stakes)

Dense retrieval (semantic similarity) + sparse retrieval (BM25 keyword matching). Combining both consistently outperforms either alone. This is not optional — it's the baseline.

```
Query → [Dense Embedding Search] + [BM25 Keyword Search]
           ↓                            ↓
        Semantic matches          Exact term matches
           ↓                            ↓
        ──────── Merge + Deduplicate ────────
                        ↓
              Reranking (cross-encoder)
                        ↓
                  Final results
```

## The Production Pipeline (Three Stages)

### Stage 1: Recall (Broad, Loose Threshold)
- Vector search with low threshold (0.25-0.3)
- BM25 keyword search in parallel
- Merge via Reciprocal Rank Fusion (RRF)
- Target: 50 candidates

### Stage 2: Rerank (Precise)
- Cross-encoder or ColBERT v2 re-scores all candidates
- ColBERT stores per-token embeddings with late interaction scoring — near cross-encoder accuracy at near bi-encoder speed
- **Highest-ROI improvement** most teams can make
- Target: Top 10-20

### Stage 3: Select (Strict, Dynamic Threshold)
- Gap-based threshold: find natural breakpoint between relevant and irrelevant scores
- Return only results above the gap
- Target: 3-10 final results

### Performance Impact (Cohere Data)

| Method | Recall | Accuracy | User Satisfaction |
|--------|--------|----------|-------------------|
| Vector only | 65% | 78% | 3.2/5 |
| + Keyword (hybrid) | 82% (+26%) | 81% | 3.8/5 |
| + Reranking | **89%** (+37%) | **91%** (+17%) | **4.3/5** (+34%) |

## Advanced Patterns

### Contextual Retrieval (Anthropic)

Prepend chunk-specific context before embedding. Instead of embedding a raw chunk, prepend: "This chunk is from the authentication section of the API docs, discussing JWT token validation."

Simple to implement, meaningful retrieval accuracy gains. Reduces the "lost in the middle" problem.

### Agentic RAG

The dominant new enterprise pattern. Specialized agents handle different retrieval stages:

```
Query Decomposition Agent → breaks complex questions into sub-queries
     ↓
Retrieval Router Agent → directs each sub-query to relevant data subset
     ↓
[Parallel Retrieval Agents] → each searches their assigned data source
     ↓
Validation Agent → checks retrieved chunks for relevance and freshness
     ↓
Synthesis Agent → generates final answer with citations
```

Real and shipping at companies. Particularly effective for multi-source retrieval (docs + code + tickets + conversations).

### GraphRAG

Uses knowledge graphs as the retrieval layer instead of flat vector stores. Enables multi-hop reasoning across entities and relationships.

```
"What projects did the team that built Feature X also work on?"
  → Entity: Feature X → Relationship: built_by → Team A
  → Entity: Team A → Relationship: built → [Project Y, Project Z]
```

**Significantly better** on complex analytical questions requiring relationship reasoning. Neo4j is the primary vendor. Production adoption is real but limited to use cases that genuinely need relationship reasoning (compliance, research, knowledge management).

**Not a replacement for vector search** — typically used alongside it.

### Late Chunking

Instead of chunking documents first then embedding each chunk, embed the full document first (using a long-context embedding model), then extract chunk-level embeddings from the full-document representation. Preserves document-level context in every chunk embedding.

## Threshold Strategies

### Gap-Based (Google Research)

Find the natural "cliff" in similarity scores:

```
Doc A: 0.85 ┐
Doc B: 0.82 ├─ Relevant cluster
Doc C: 0.78 ┘
─── Gap ───── ← Natural breakpoint (0.78 - 0.45 = 0.33)
Doc D: 0.45 ┐
Doc E: 0.42 ├─ Irrelevant cluster
```

Set threshold at midpoint of the largest gap. Far more effective than fixed thresholds.

### Adaptive by Query Type

| Query Type | Threshold | Rationale |
|-----------|-----------|-----------|
| Definition ("What is X") | 0.6 | Needs precision |
| Enumeration ("List all X") | 0.4 | Needs recall |
| How-to ("How to do X") | 0.7 | Needs accuracy |
| Exploratory ("About X") | 0.3 | Needs breadth |

## Index Selection (pgvector)

| Data Scale | Index | Config |
|-----------|-------|--------|
| <10K | None (sequential scan) | <100ms queries |
| 10K-100K | HNSW | `m=16, ef_construction=64` |
| >100K | HNSW aggressive | `m=32, ef_construction=128` |

**HNSW is the industry standard** — 99% accuracy at any scale, 15ms query time.

## The Critical Insight for 2026

Late chunking, contextual embeddings, and hybrid search are **higher-leverage** improvements than swapping to a better LLM. When generation hallucinates, the root cause is almost always bad retrieval, not bad generation.

## Related Pages

- [[Agent Memory Systems]]
- [[Open Source LLM Landscape 2026]]
- [[Claude Code Architecture Deep Dive]]

## Sources

- [RAG Advanced Patterns 2026 (DEV)](https://dev.to/young_gao/rag-is-not-dead-advanced-retrieval-patterns-that-actually-work-in-2026-2gbo)
- [Neo4j Advanced RAG Techniques](https://neo4j.com/blog/genai/advanced-rag-techniques/)
- [Anthropic Contextual Retrieval](https://www.anthropic.com/news/contextual-retrieval)
- [Enterprise RAG 2026-2030](https://nstarxinc.com/blog/the-next-frontier-of-rag-how-enterprise-knowledge-systems-will-evolve-2026-2030/)
