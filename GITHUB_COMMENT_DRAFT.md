## Another community workaround: lazy-mcp-preload

I've created a fork of [voicetreelab/lazy-mcp](https://github.com/voicetreelab/lazy-mcp) that adds **background server preloading** to eliminate the first-call latency while maintaining the 95% token savings.

### Repository
🔗 https://github.com/iamsamuelrodda/lazy-mcp-preload

### The Problem with Existing Lazy Loading
While lazy-mcp achieves ~95% token reduction by exposing only 2 meta-tools instead of all tool schemas, it incurs ~500ms latency on the first tool call to each server (cold start).

### The Solution: Background Preloading
Added a `preloadAll` config option that starts all MCP servers in parallel background goroutines immediately at proxy startup. By the time you need a tool, the servers are already warm.

```json
{
  "mcpProxy": {
    "options": {
      "lazyLoad": true,
      "preloadAll": true
    }
  }
}
```

### Results

| Metric | Direct MCP | lazy-mcp | lazy-mcp-preload |
|--------|------------|----------|------------------|
| Startup tokens | ~15,000 | ~800 | ~800 |
| Context savings | 0% | 95% | 95% |
| First-call latency | 0ms | ~500ms | ~0ms |
| Tools visible | 30 | 2 | 2 |

### How It Works

```
Claude Code session starts
         │
         ▼
lazy-mcp-preload proxy starts
         │
         ├──► Main thread: Ready with 2 meta-tools (~800 tokens)
         │
         └──► Background goroutines (parallel):
                 ├─ Preload server 1
                 ├─ Preload server 2
                 └─ Preload server 3
                           │
                           ▼
              All servers warm before first tool call
```

### Installation
```bash
git clone https://github.com/iamsamuelrodda/lazy-mcp-preload
cd lazy-mcp-preload
make build
make generate-hierarchy
./scripts/deploy.sh
```

This is a workaround until native lazy loading support lands in Claude Code. Hope it helps others experiencing this issue!
