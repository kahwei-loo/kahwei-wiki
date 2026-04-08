---
created: 2026-04-08
updated: 2026-04-08
sources:
  - "MCP official spec, roadmap blog, industry adoption analysis"
tags: [ai, mcp, protocol, infrastructure, tools]
---

# MCP Architecture and Ecosystem

> Model Context Protocol is becoming the USB-C of AI tool integration. Open standard by Anthropic, adopted by OpenAI, Google, Microsoft, and 1,000+ community servers. Defines how LLMs connect to external tools, data, and services.

## Architecture: Host → Client → Server

```
┌─────────────────────────────────────┐
│           HOST APPLICATION           │
│  (Claude Desktop, Cursor, IDE...)    │
│                                      │
│  ┌──────────┐  ┌──────────┐         │
│  │ MCP      │  │ MCP      │         │
│  │ Client A │  │ Client B │  ...    │
│  └────┬─────┘  └────┬─────┘         │
└───────┼──────────────┼───────────────┘
        │ 1:1          │ 1:1
   ┌────┴─────┐   ┌────┴─────┐
   │ MCP      │   │ MCP      │
   │ Server A │   │ Server B │
   │ (GitHub) │   │ (Postgres)│
   └──────────┘   └──────────┘
```

- **Host**: The application (Claude Desktop, an IDE, your app)
- **Client**: Protocol handler maintaining a 1:1 connection with a server
- **Server**: Exposes tools, resources, and prompts to the AI model

Each server is a self-contained unit. Adding a new capability = adding a new server. The host never changes.

## Transport Layers

| Transport | Mechanism | Best For | Status |
|-----------|-----------|----------|--------|
| **stdio** | Local child process | Local tools, CLI environments | Stable, widely supported |
| **Streamable HTTP** | Single HTTP endpoint, bidirectional | Remote servers, cloud deployment | **Recommended** (current standard) |
| ~~HTTP+SSE~~ | Two endpoints (POST + SSE) | — | **Deprecated** (replaced by Streamable HTTP) |

**stdio** is still the only transport Claude Desktop natively supports — a known pain point for remote deployment.

**Streamable HTTP** uses POST requests with optional SSE streaming for server-to-client messages. Criticism: half-duplex on HTTP/1.1 requires workaround POSTs for server-initiated messages. Community has asked for WebSocket/HTTP2 alternatives.

## Adoption (April 2026)

**1,000+ community-built MCP servers**. Industry-wide adoption:

| Adopter | Integration |
|---------|-------------|
| **Anthropic** | Claude Desktop, Claude Code, Claude.ai — native |
| **OpenAI** | ChatGPT, Agents SDK — adopted competitor's protocol |
| **Google** | Gemini, ADK |
| **Microsoft** | VS Code, GitHub Copilot agent mode, Azure AD for MCP OAuth |
| **JetBrains** | All IntelliJ-based IDEs |
| **Cursor, Windsurf** | Native MCP client support |
| **Cloudflare** | First-class MCP hosting on Workers |

## Server Ecosystem Categories

| Category | Examples |
|----------|---------|
| Databases | Postgres, Redis, ClickHouse, SQLite |
| SaaS | Slack, Google Drive, Jira, Sentry, Stripe, Linear |
| Developer tools | Git, Docker, Playwright, GitHub |
| Knowledge bases | Notion, Confluence, file systems |
| AI/ML | Hugging Face, model registries |
| Custom | Enterprise internal tools, proprietary APIs |

## Authentication

The spec mandates **OAuth 2.1 + PKCE** for public remote servers:

- Servers implement RFC 9728 (OAuth 2.0 Protected Resource Metadata) for automatic authorization server discovery
- **Dynamic Client Registration** (RFC 7591) lets AI agents self-register without manual admin setup
- Supported identity providers: Keycloak, Entra ID, Auth0, Okta, GitHub OAuth, Google OAuth2
- Enterprise pattern: centralized `mcp-gateway-registry` manages auth across multiple servers

## Discovery and Registries

No single official marketplace yet — a known gap on the 2026 roadmap:

- **mcp.run**, **Smithery**, **mcpcat.io** serve as community registries
- SEPs (Spec Enhancement Proposals) underway for machine-readable server metadata format (targeted June 2026)
- Current state: server selection is still manual or hardcoded in config files

## MCP vs Function Calling

| | MCP | Function Calling (OpenAI-style) |
|---|---|---|
| What it is | **Protocol** (standardized server interface) | **API feature** (schema in prompt) |
| Reusability | Server works with any MCP client | Provider-specific |
| Discovery | Server self-describes capabilities | Developer defines schemas |
| Ecosystem | 1,000+ reusable servers | Per-project custom tools |
| Standard | Open, multi-vendor | Proprietary per provider |

In practice: MCP is the interoperability layer. OpenAI adopted it alongside their native function calling — the two coexist.

## Practical Patterns

### Server Composition
Combine multiple MCP servers to give an agent a rich tool environment. Example (from Claude Code):
- Context7 for documentation lookup
- Sequential for structured reasoning
- Playwright for browser automation
- Sentry for error tracking

### Local vs Remote
- **Local (stdio)**: Zero latency, full filesystem access, no auth complexity. Best for development tools.
- **Remote (Streamable HTTP)**: Shareable, scalable, requires auth. Best for SaaS integrations and team deployments.

### Security Considerations
- Servers run with the permissions of the host process — a malicious server can access anything the host can
- Remote servers need proper OAuth scoping — principle of least privilege
- Enterprise: gateway pattern centralizes auth and audit logging

## 2026 Roadmap Priorities

1. **Transport at scale**: Session affinity, horizontal scaling, stateless session options
2. **Tasks primitive**: Retry semantics, expiry policies for completed results
3. **Governance**: Formal SEP process, Working Groups
4. **Enterprise readiness**: Gartner predicts 40% of enterprise apps will include AI agents by end of 2026

## Known Limitations

- stdio-only in Claude Desktop limits remote server deployment
- Streamable HTTP's half-duplex design is architecturally awkward
- No standard discovery mechanism yet (manual server configuration)
- Session management complexity for stateful servers behind load balancers
- Spec velocity creates integration churn (SSE deprecated within months of standardization)

## Related Pages

- [[Claude Code Architecture Deep Dive]]
- [[AI Coding Tools Landscape 2026]]
- [[Multi-Agent Architecture Patterns]]

## Sources

- [MCP Official Spec](https://modelcontextprotocol.io/specification)
- [2026 MCP Roadmap](https://blog.modelcontextprotocol.io/posts/2026-mcp-roadmap/)
- [Why MCP Won — The New Stack](https://thenewstack.io/why-the-model-context-protocol-won/)
- [MCP Authorization Spec](https://modelcontextprotocol.io/specification/draft/basic/authorization)
- [MCP Transport Comparison — MCPcat](https://mcpcat.io/guides/comparing-stdio-sse-streamablehttp/)
- [Enterprise MCP Adoption — CData](https://www.cdata.com/blog/2026-year-enterprise-ready-mcp-adoption)
