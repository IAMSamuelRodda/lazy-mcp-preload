# ISSUES.md

> **Purpose:** Track bugs, improvements, and technical debt for lazy-mcp-preload
> **Lifecycle:** Living document, updated when issues change

**Last Updated:** 2025-12-17

---

## Status/Priority Guides

**Status Indicators:**
- 🔴 **Open** - Issue identified, needs attention
- 🟡 **In Progress** - Actively being worked on
- 🟢 **Resolved** - Fixed and verified
- 🔵 **Blocked** - Cannot proceed due to dependencies

**Priority Levels:**
- **P0** - Critical, blocks core functionality
- **P1** - High, affects user experience significantly
- **P2** - Medium, should fix but not urgent
- **P3** - Low, nice to have

---

## Active Issues

### Bugs

#### issue_001: Vikunja Tool Count Discrepancy (MOVED to vikunja-mcp)
- **Status**: 🔵 Moved to vikunja-mcp repository
- **Priority**: P2
- **Component**: Vikunja MCP server (not lazy-mcp-preload)
- **Discovered**: 2025-12-17
- **Tracking**: `/home/x-forge/repos/3-resources/MCP/vikunja-mcp/ISSUES.md#BUG-001`

**Description:**
Vikunja MCP server shows tool count discrepancy when accessed via lazy-mcp (27 actual vs 23 reported). Systematic review of 10 other MCP servers found NO similar discrepancy, indicating this is specific to vikunja-mcp implementation, not a lazy-mcp-preload bug.

**Resolution:**
Systematic review of 10 other MCP servers (cloudflare, joplin, mailjet, nextcloud-calendar, stalwart, stripe, todoist, tplink-router, youtube-transcript) found all report accurate tool counts. Issue is specific to vikunja-mcp server, not lazy-mcp-preload.

**See:** `/home/x-forge/repos/3-resources/MCP/vikunja-mcp/ISSUES.md#BUG-001` for full investigation and tracking.

---

### Improvements

*None currently*

---

### Technical Debt

*None currently*

---

## Resolved Issues (Last 2 Weeks)

*None yet*

---

## Archived Issues (Older than 2 Weeks)

*Items will be moved here from Resolved Issues after 2 weeks*

---

## Issue Patterns

*Track recurring issues here as patterns emerge*
