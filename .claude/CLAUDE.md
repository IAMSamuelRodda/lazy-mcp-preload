# mcp-proxy

Aggregating MCP proxy with ~95% context reduction through progressive tool disclosure.

## Build & Deploy

```bash
# Build
go build -o build/mcp-proxy ./cmd/mcp-proxy
go build -o build/structure_generator ./structure_generator/cmd

# Deploy locally
cp build/mcp-proxy ~/.claude/lazy-mcp/
cp build/structure_generator ~/.claude/lazy-mcp/

# Regenerate hierarchy
~/.claude/lazy-mcp/structure_generator \
  --config ~/.claude/lazy-mcp/config.json \
  --output ~/.claude/lazy-mcp/hierarchy
```

## Issue Tracking

Use GitHub Issues: https://github.com/IAMSamuelRodda/mcp-proxy/issues
