# STATUS.md

> **Purpose:** Current project state and active work (2-week rolling window)
> **Lifecycle:** Living document, updated daily/weekly

**Last Updated:** 2025-12-18

## Quick Overview

| Aspect | Status |
|--------|--------|
| Build | Working |
| Deployment | Deployed to ~/.claude/lazy-mcp/ |
| Testing | Passed (13 servers, 136 tools) |
| GitHub | Published |

## Current Focus

### This Week: OpenBao Integration & Graceful Degradation

- [x] Add OpenBao package (`internal/openbao/`) with health check and auto-start
- [x] Add OpenBao config options to proxy config
- [x] Implement graceful server disabling (failed servers don't block proxy)
- [x] Reduce server init timeout from 30s to 5s for fast-fail
- [x] Add structured error codes (OPENBAO_AGENT_NOT_RUNNING, SECRET_NOT_FOUND, etc.)
- [x] Update Python MCP servers with DeferredCredentialLoader pattern

## Deployment Status

| Environment | Status | Notes |
|-------------|--------|-------|
| Local (~/.claude/lazy-mcp/) | Deployed | Config updated in ~/.claude.json |
| GitHub | Published | https://github.com/iamsamuelrodda/lazy-mcp-preload |

## Configuration

```
# Deployment
~/.claude/lazy-mcp/
├── mcp-proxy          # Go binary (with OpenBao integration)
├── config.json        # preloadAll: true enabled (gitignored - personal)
└── hierarchy/         # Tool schemas (136 tools across 13 servers)

# Source (internal/)
├── client/            # MCP client wrappers
├── config/            # Configuration parsing + OpenBao options
├── hierarchy/         # Tool hierarchy + graceful server disabling
├── openbao/           # OpenBao health check, auto-start, error codes
└── server/            # Stdio/HTTP server startup
```

## Known Issues

*None currently*

### Recently Fixed

**Pydantic params wrapper issue (2025-11-27)**
- **Symptom:** First MCP tool call fails with `params Field required` validation error, retry succeeds
- **Root cause:** Python MCP servers using Pydantic expect args wrapped in `params`, Claude passes flat args
- **Fix:** Auto-wrap detection in `maybeWrapInParams()` - transparent to Claude, zero context bloat
- **Commit:** `78d95da`

## Recent Achievements (Last 2 Weeks)

### 2025-12-18
- **OpenBao integration** - Health check, auto-start, graceful degradation
- **Graceful server disabling** - Failed servers disabled, don't block proxy
- **Fast-fail detection** - 5s timeout instead of 30s for server init
- **Structured error codes** - OPENBAO_AGENT_NOT_RUNNING, SECRET_NOT_FOUND, etc.
- **Python deferred loading** - DeferredCredentialLoader for lifespan-based creds
- **Fixed structure_generator panic** - context7 SSE transport caused nil pointer
- **Added multi-transport support** - stdio, SSE, and HTTP Streamable

### 2025-12-16
- **Security hardening** - STRIDE threat model audit, input validation
- **Auth token validation** - 24+ character minimum with helpful error messages
- **Command injection protection** - Block shell metacharacters in stdio configs

### 2025-11-27
- Forked voicetreelab/lazy-mcp
- Added `preloadAll` config option
- Implemented `PreloadServers()` with parallel goroutines
- **Testing passed** - ~95% context reduction, zero cold-start latency
- **Fixed Pydantic params issue** - auto-wrap args when schema requires `params` wrapper

## Next Steps (Prioritized)

1. **Test OpenBao integration** - Verify graceful degradation with agent on/off
2. **Update remaining MCP servers** - Apply deferred loading to stalwart, cloudflare, etc.
3. **Merge security branch** - Review and merge dev/security-hardening to main
4. **Monitor feedback** - Watch for issues/improvements on GitHub

## Related Resources

- **Issue:** [anthropics/claude-code#3036](https://github.com/anthropics/claude-code/issues/3036)
- **Upstream:** [voicetreelab/lazy-mcp](https://github.com/voicetreelab/lazy-mcp)
- **Draft comment:** `GITHUB_COMMENT_DRAFT.md`
