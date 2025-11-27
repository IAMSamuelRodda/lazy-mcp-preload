# STATUS.md

> **Purpose:** Current project state and active work (2-week rolling window)
> **Lifecycle:** Living document, updated daily/weekly

**Last Updated:** 2025-11-27

## Quick Overview

| Aspect | Status |
|--------|--------|
| Build | Working |
| Deployment | Deployed to ~/.claude/lazy-mcp/ |
| Testing | Passed |
| GitHub | Published |

## Current Focus

### This Week: Initial Testing & Publishing

- [x] Test lazy-mcp-preload after Claude Code session reset
- [x] Verify token reduction (~15,000 → ~800)
- [x] Verify background preloading eliminates cold start
- [x] Publish to GitHub
- [x] Post comment to issue #3036

## Deployment Status

| Environment | Status | Notes |
|-------------|--------|-------|
| Local (~/.claude/lazy-mcp/) | Deployed | Config updated in ~/.claude.json |
| GitHub | Published | https://github.com/iamsamuelrodda/lazy-mcp-preload |

## Configuration

```
~/.claude/lazy-mcp/
├── mcp-proxy          # Go binary
├── config.json        # preloadAll: true enabled
└── hierarchy/         # Tool schemas (30 tools across 3 servers)
    ├── joplin/
    ├── todoist/
    └── nextcloud-calendar/
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

### 2025-11-27
- Forked voicetreelab/lazy-mcp
- Added `preloadAll` config option
- Implemented `PreloadServers()` with parallel goroutines
- Built and deployed to ~/.claude/lazy-mcp/
- Generated hierarchy for 3 MCP servers (30 tools)
- Updated ~/.claude.json to use proxy
- **Testing passed** - confirmed ~95% context reduction, zero cold-start latency
- **Published to GitHub** - https://github.com/iamsamuelrodda/lazy-mcp-preload
- **Posted to issue #3036** - shared with community
- **Fixed Pydantic params issue** - auto-wrap args when schema requires `params` wrapper
- **Added joplin_ensure_running tool** - proactive warmup for Joplin with polling until API ready

## Next Steps (Prioritized)

1. **Monitor feedback** - Watch for issues/improvements on GitHub
2. **Consider upstream PR** - If voicetreelab/lazy-mcp is active, propose preloadAll feature
3. **Iterate based on community feedback** - Address any issues reported

## Related Resources

- **Issue:** [anthropics/claude-code#3036](https://github.com/anthropics/claude-code/issues/3036)
- **Upstream:** [voicetreelab/lazy-mcp](https://github.com/voicetreelab/lazy-mcp)
- **Draft comment:** `GITHUB_COMMENT_DRAFT.md`
