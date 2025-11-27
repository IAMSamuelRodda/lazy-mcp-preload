# lazy-mcp-preload

A fork of [voicetreelab/lazy-mcp](https://github.com/voicetreelab/lazy-mcp) with background server preloading for zero-latency MCP tool execution.

## Problem

lazy-mcp reduces context window usage by ~95% (from ~15,000 tokens to ~800 tokens for 30 tools). However, servers are started on-demand, causing ~500ms latency on first tool call to each server.

## Solution

This fork adds a `preloadAll` option that starts all configured MCP servers in the background immediately at proxy startup. By the time Claude needs them, they're already warm.

## Token Savings

| Metric | Direct MCP | lazy-mcp | lazy-mcp-preload |
|--------|------------|----------|------------------|
| Startup tokens | ~15,000 | ~800 | ~800 |
| First-call latency | 0ms | ~500ms | ~0ms |
| Tools visible | 30 | 2 | 2 |

## Installation

### Prerequisites

```bash
# Install Go 1.21+
sudo apt install golang-go
# Or use the install script
./scripts/install-go.sh
```

### Build

```bash
git clone https://github.com/x-forge/lazy-mcp-preload.git
cd lazy-mcp-preload
make build
```

### Deploy to Claude Code

```bash
./scripts/deploy.sh
```

## Configuration

### config.json

```json
{
  "mcpProxy": {
    "name": "x-forge MCP Proxy",
    "version": "1.0.0",
    "type": "stdio",
    "hierarchyPath": "/home/x-forge/.claude/lazy-mcp/hierarchy",
    "options": {
      "lazyLoad": true,
      "preloadAll": true
    }
  },
  "mcpServers": {
    "joplin": {
      "transportType": "stdio",
      "command": "/home/x-forge/.claude/mcp-servers/joplin/.venv/bin/python",
      "args": ["/home/x-forge/.claude/mcp-servers/joplin/joplin_mcp.py"],
      "env": {},
      "options": { "lazyLoad": true }
    },
    "todoist": {
      "transportType": "stdio",
      "command": "/home/x-forge/.claude/mcp-servers/todoist/.venv/bin/python",
      "args": ["/home/x-forge/.claude/mcp-servers/todoist/todoist_mcp.py"],
      "env": {},
      "options": { "lazyLoad": true }
    },
    "nextcloud-calendar": {
      "transportType": "stdio",
      "command": "/home/x-forge/.claude/mcp-servers/nextcloud-calendar/.venv/bin/python",
      "args": ["/home/x-forge/.claude/mcp-servers/nextcloud-calendar/nextcloud_calendar_mcp.py"],
      "env": {},
      "options": { "lazyLoad": true }
    }
  }
}
```

### Claude Code Integration

After deployment, your `~/.claude.json` will contain:

```json
{
  "mcpServers": {
    "lazy-mcp": {
      "type": "stdio",
      "command": "/home/x-forge/.claude/lazy-mcp/mcp-proxy",
      "args": ["--config", "/home/x-forge/.claude/lazy-mcp/config.json"]
    }
  }
}
```

## How Preloading Works

```
0ms      50ms     200ms    500ms    1000ms+
│        │        │        │        │
▼        ▼        ▼        ▼        ▼
[proxy starts]
         [2 meta-tools ready ─ Claude can start]
         [───── background preload (parallel) ─────]
                  [user typing...]
                           [all servers warm]
                                    [tool call = instant]
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Claude Code                        │
│                        │                             │
│                        ▼                             │
│         ┌──────────────────────────────┐            │
│         │     lazy-mcp-preload         │            │
│         │                              │            │
│         │  Main thread:                │            │
│         │  • get_tools_in_category()   │ ~800 tokens│
│         │  • execute_tool()            │            │
│         │                              │            │
│         │  Background goroutine:       │            │
│         │  • Pre-starts all servers    │            │
│         └──────────────────────────────┘            │
│                        │                             │
│     ┌──────────────────┼──────────────────┐         │
│     ▼                  ▼                  ▼         │
│ [Joplin]          [Todoist]        [Nextcloud]      │
│  warm              warm             warm            │
└─────────────────────────────────────────────────────┘
```

## Development

### Project Structure

```
lazy-mcp-preload/
├── README.md
├── Makefile
├── go.mod
├── go.sum
├── cmd/
│   └── mcp-proxy/
│       └── main.go
├── internal/
│   ├── client/
│   ├── config/
│   ├── hierarchy/
│   └── server/
├── config/
│   └── config.json.example
├── scripts/
│   ├── install-go.sh
│   ├── deploy.sh
│   └── generate-hierarchy.sh
└── deploy/
    └── hierarchy/          # Generated tool hierarchy
```

### Making Changes

1. Edit source in `internal/` or `cmd/`
2. Build: `make build`
3. Test locally: `./build/mcp-proxy --config config/config.json`
4. Deploy: `make deploy`

## Upstream

This is a fork of [voicetreelab/lazy-mcp](https://github.com/voicetreelab/lazy-mcp).

Changes from upstream:
- Added `preloadAll` option for background server initialization
- Added deployment scripts for Claude Code integration
- Customized for x-forge MCP server setup

## License

MIT License (same as upstream)
