# mcp-proxy

[![GitHub release](https://img.shields.io/github/v/release/IAMSamuelRodda/mcp-proxy)](https://github.com/IAMSamuelRodda/mcp-proxy/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

An aggregating MCP proxy that reduces context window usage by ~95% while providing zero-latency tool execution.

## How It Works

Instead of exposing all tools directly to Claude (consuming ~15,000+ tokens), mcp-proxy exposes just 2 meta-tools:

1. **`get_tools_in_category`** - Navigate a hierarchical tree of available tools
2. **`execute_tool`** - Execute any tool by its path

This progressive disclosure pattern reduces context to ~800 tokens while maintaining full access to all tools.

## Features

| Feature | Benefit |
|---------|---------|
| **95% context reduction** | ~800 tokens instead of ~15,000 |
| **Background preloading** | Zero cold-start latency |
| **Multi-transport** | stdio, SSE, HTTP Streamable |
| **Graceful degradation** | Failed servers disabled, don't block |
| **Secrets integration** | Optional OpenBao/Vault support |
| **Source-based installation** | MCP servers installed from git/local sources |
| **Portable config** | Variable expansion for machine-independent configs |

## Quick Start

```bash
# Clone
git clone https://github.com/IAMSamuelRodda/mcp-proxy.git
cd mcp-proxy

# Copy and configure
cp config/config.template.json config/config.local.json
# Edit config.local.json with your MCP servers

# Simple mode (MCP servers + proxy, uses .env files for secrets)
./scripts/bootstrap.sh --simple

# Or full bootstrap (includes OpenBao/Bitwarden secrets infrastructure)
./scripts/bootstrap.sh
```

## Bootstrap Workflow

The bootstrap script orchestrates full workstation setup:

```
./scripts/bootstrap.sh [FLAGS]
```

| Flag | Behavior |
|------|----------|
| (none) | Full bootstrap: secrets infra → MCP servers → mcp-proxy |
| `--simple` | Simple mode: skip secrets infrastructure (for `.env` users) |
| `--refresh` | Config + hierarchy only (fast, skips source updates) |
| `--force` | Clean reinstall all MCP servers from source |

**What it installs:**
1. **bitwarden-guard** - Bitwarden CLI session management (optional)
2. **openbao-agents** - Local secrets agents (optional)
3. **MCP servers** - From source definitions in config
4. **mcp-proxy** - This proxy binary + hierarchy

## Configuration

### Portable Config with Variables

Config files use variables that are expanded at deploy time:

```json
{
  "mcpProxy": {
    "hierarchyPath": "${MCP_PROXY_DIR}/hierarchy"
  },
  "mcpServers": {
    "my-server": {
      "source": {
        "type": "git",
        "url": "https://github.com/user/mcp-server.git"
      },
      "command": "${MCP_SERVERS_DIR}/my-server/.venv/bin/python",
      "args": ["${MCP_SERVERS_DIR}/my-server/server.py"]
    }
  }
}
```

**Available variables:**
| Variable | Default |
|----------|---------|
| `${MCP_SERVERS_DIR}` | `~/.claude/mcp-servers` |
| `${MCP_PROXY_DIR}` | `~/.claude/mcp-proxy` |
| `${HOME}` | User home directory |

### Source Types

Each MCP server can specify a source for installation:

**Git source** (recommended):
```json
"source": {
  "type": "git",
  "url": "https://github.com/user/mcp-server.git"
}
```

**Local source** (for development):
```json
"source": {
  "type": "local",
  "path": "~/repos/my-mcp-server"
}
```

**Remote HTTP** (no installation needed):
```json
"transportType": "streamable-http",
"url": "https://example.com/mcp"
```

### Update Behavior

| Source Type | Update Mechanism |
|-------------|------------------|
| Git | `git pull` on each bootstrap run |
| Local | Clean replace (rm + cp) preserving .venv |
| Remote | No installation, connects directly |

**Venv rebuilds** only occur when `pyproject.toml` or `requirements.txt` changes (hash-based detection).

## Setup Options

| Mode | Secrets Storage | Best For |
|------|-----------------|----------|
| **Simple** | `.env` files per server | Local dev, single machine |
| **Secure** | OpenBao + Bitwarden | Production, multi-machine, audit trails |

**Simple mode:** Configure MCP servers with environment variables. See [config.template.json](config/config.template.json).

**Secure mode:** Full secrets management with OpenBao, Bitwarden integration. See [docs/SECURE_SETUP.md](docs/SECURE_SETUP.md).

## Claude Code Integration

Add to `~/.claude.json`:

```json
{
  "mcpServers": {
    "mcp-proxy": {
      "type": "stdio",
      "command": "~/.claude/mcp-proxy/mcp-proxy",
      "args": ["--config", "~/.claude/mcp-proxy/config.json"]
    }
  }
}
```

**Important:** Remove individual MCP server entries - the proxy handles them.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Claude Code                        │
│                        │                             │
│                        ▼                             │
│         ┌──────────────────────────────┐            │
│         │         mcp-proxy            │            │
│         │                              │            │
│         │  2 meta-tools (~800 tokens)  │            │
│         │  • get_tools_in_category()   │            │
│         │  • execute_tool()            │            │
│         │                              │            │
│         │  Background: preload all     │            │
│         └──────────────────────────────┘            │
│                        │                             │
│     ┌──────────────────┼──────────────────┐         │
│     ▼                  ▼                  ▼         │
│ [Server 1]        [Server 2]        [Server 3]      │
│   warm              warm              warm          │
└─────────────────────────────────────────────────────┘
```

## Project Structure

```
mcp-proxy/
├── cmd/mcp-proxy/         # Main entry point
├── internal/
│   ├── client/            # MCP client connections
│   ├── config/            # Configuration parsing
│   ├── hierarchy/         # Tool schema management
│   ├── secrets/           # Secrets provider interface
│   └── server/            # Proxy server logic
├── structure_generator/   # Hierarchy generation tool
├── config/                # Configuration templates
│   ├── config.template.json   # Portable template with variables
│   └── config.local.json      # Your local config (gitignored)
├── scripts/
│   ├── bootstrap.sh       # Full workstation setup
│   └── install.sh         # Binary-only install
└── docs/
    └── SECURE_SETUP.md    # OpenBao + Bitwarden guide
```

## Development

```bash
# Build
make build

# Test
go test ./...

# Deploy binary only (keeps existing config)
make deploy

# Full install (binary + config from config.local.json)
make install

# Regenerate hierarchy only
make generate-hierarchy
```

## Acknowledgments

This project was inspired by [voicetreelab/lazy-mcp](https://github.com/voicetreelab/lazy-mcp), which introduced the elegant 2-meta-tool pattern for progressive tool disclosure. mcp-proxy extends this foundation with background preloading, multi-transport support, secrets integration, and production resilience features.

## License

MIT License
