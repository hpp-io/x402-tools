# x402-tools

Public tools & resources for **HPP x402** — the agent payment rail on HPP.

`hpp-x402` is a CLI + MCP bridge that lets an AI agent (Claude Desktop, Claude
Code, Cursor, Windsurf, OpenClaw) **discover and pay for x402 services on HPP**
with USDC.e — per call, within a spend cap, no API keys, no manual signing.

- [What it is](#what-it-is)
- [Install](#install)
- [Quick start](#quick-start)
- [System requirements](#system-requirements)
- [Command reference](#command-reference) — `setup` · `wallet` · `install` · `fund` · `status` · `discover` · `call` · `serve` · `policy` · `channel` · `safe`
- [Wallet modes](#wallet-modes-light-vs-safe)
- [Use it from your MCP host](#use-it-from-your-mcp-host)
- [Headless / server / CI](#headless--server--ci-no-keychain)

## What it is

MCP hosts can't sign x402 payments themselves. This package is two things:

- **The bridge** (`x402-mcp-bridge`) — a stdio MCP server your host spawns. It
  proxies a paid upstream MCP server and adds tools to **discover** and **call**
  any x402 service on HPP. When a service returns HTTP `402`, the bridge pays
  from your wallet and retries — the host just sees tools that work.
- **The CLI** (`hpp-x402`) — one command surface to create a wallet, register
  the bridge into your host, fund it, browse/call services, set spend policy,
  and even run your own paid endpoint.

Payments settle in **USDC.e** on HPP and are **gasless** (no native gas needed).

| Network | CAIP-2 id |
|---|---|
| HPP Sepolia (default) | `eip155:181228` |
| HPP Mainnet | `eip155:190415` |

## Install

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/hpp-io/x402-tools/main/install/install.sh | bash
# Windows (PowerShell)
irm https://raw.githubusercontent.com/hpp-io/x402-tools/main/install/install.ps1 | iex
```

This installs the public [`@hpp-io/x402-mcp-bridge`](https://www.npmjs.com/package/@hpp-io/x402-mcp-bridge)
npm package globally, putting `hpp-x402` (and the `x402-mcp-bridge` server) on
your PATH. Prefer npm directly? Same result:

```bash
npm install -g @hpp-io/x402-mcp-bridge
```

> The install scripts only check for Node 20+ and run `npm i -g` — read them in
> [`install/`](./install/) before running.

## Quick start

```bash
# 1. Create a wallet + register the bridge into your agent host
hpp-x402 setup --install claude-code     # or: claude | cursor | windsurf | openclaw

# 2. Fund it — send USDC.e to the printed address (no native gas needed)
hpp-x402 fund

# 3. See it works
hpp-x402 status                          # config · balance · reachability
hpp-x402 discover --limit 5              # browse live services
```

Restart your host and chat — your agent can now discover and pay for services.
(You can also just ask it *"what's my wallet address?"*.)

## System requirements

| | Requirement |
|---|---|
| **Node.js** | 20 or newer (check with `node -v`). Install from [nodejs.org](https://nodejs.org), `brew install node`, or [nvm](https://github.com/nvm-sh/nvm). |
| **npm** | Bundled with Node.js. |
| **OS** | macOS, Linux, or Windows. |
| **Wallet storage** | An OS keychain — macOS Keychain / Linux gnome-keyring / Windows Credential Manager. Needed by `setup` and `wallet` to store your key. |

The installer does **not** install Node for you — install it first, then run the
one-liner. On a headless box without a keychain, see
[Headless / server / CI](#headless--server--ci-no-keychain).

## Command reference

Run `hpp-x402 --help` or `hpp-x402 <command> --help` any time. Two options
recur across commands:

| Option | Default | Meaning |
|---|---|---|
| `-a, --account <name>` | `delegate-default` | which keychain wallet to use |
| `-n, --network <id>` | `eip155:181228` (HPP Sepolia) | target network |

### `setup` — onboard in one command

Creates a wallet, prints funding instructions, and optionally wires your host.

```bash
hpp-x402 setup [--install <host>] [-a <name>] [-n <id>]
               [--resource-server-url <url>] [--delegate-pk 0x...] [--print-key]
```

| Option | Notes |
|---|---|
| `--install <host>` | also register into `claude` \| `claude-code` \| `cursor` \| `windsurf` \| `openclaw` |
| `--delegate-pk <0x…>` | import an existing key instead of generating one |
| `--print-key` | emit the raw key instead of storing in the keychain (**dev / headless only**) |
| `--resource-server-url <url>` | upstream x402 MCP server (default `http://localhost:4021/mcp/sse`) |

### `wallet` — manage your key (OS keychain)

```bash
hpp-x402 wallet address              # print the delegate address
hpp-x402 wallet balance              # USDC.e balance on-chain
hpp-x402 wallet generate             # new key into the keychain
hpp-x402 wallet import <0xkey>       # import an existing key
hpp-x402 wallet remove               # delete the keychain entry
```

All accept `-a <name>` to target a named wallet.

### `install <host>` — register the bridge into an MCP host

```bash
hpp-x402 install claude-code        # claude | claude-code | cursor | windsurf | openclaw
```

Writes the correct MCP config for that host (on Claude Code it runs
`claude mcp add` for you). Use `-a`/`-n` to pin a wallet/network.

### `fund` — where to send USDC.e

```bash
hpp-x402 fund [-a <name>] [-n <id>]
```

Prints your wallet address and a reminder that settlement is gasless.

### `status` — health check

```bash
hpp-x402 status
```

Shows config, wallet balance, and whether the resource server is reachable.

### `discover` — browse the HPP service directory

```bash
hpp-x402 discover [query] [-t http|mcp|a2a|all] [-n <id>] [--limit <n>] [--url <base>]
```

| Option | Default |
|---|---|
| `-t, --type` | `all` |
| `--limit` | `20` |
| `--url` | `https://x402-discovery.hpp.io` |

```bash
hpp-x402 discover                    # browse everything
hpp-x402 discover compute -t http    # search "compute", HTTP services only
```

### `call` — pay + call a service by id

```bash
hpp-x402 call <resourceId> [--body '<json>'] [-a <name>] [-n <id>] [--url <base>]
```

Pays from your wallet and invokes the service directly from the terminal.
`resourceId` comes from `discover`.

```bash
hpp-x402 call c928e2c2-… --body '{"prompt":"hello"}'
```

### `serve` — become a seller (run a paid endpoint)

```bash
hpp-x402 serve --pay-to 0x... [--port 4030] [--path /paid/echo] [--price 10000]
               [--network <id>] [--asset 0x...] [--handler <url>]
               [--description "..."] [--private]
```

Starts a lightweight x402 seller. Default handler **echoes** the request;
`--handler <url>` forwards the body to your webhook. `--price` is in USDC.e
atomic units (6 decimals → `10000` = 0.01). Advertises discovery metadata so the
facilitator auto-indexes it, unless `--private`.

### `policy` — spend guardrails for `x402_http_call`

Manages `~/.hpp-x402/policy.json` — which hosts your agent may pay and the caps.

```bash
hpp-x402 policy path                 # where the file lives
hpp-x402 policy show                 # current policy
hpp-x402 policy list                 # per-host entries
hpp-x402 policy set <host> [--header NAME=SOURCE]... [--max-per-call <usdc>]
                          [--cooldown-ms <n>] [--https true|false]
hpp-x402 policy unset <host> [--header NAME]
hpp-x402 policy defaults [--allow-unlisted true|false] [--max-per-call <usdc>] [--https true|false]
```

Header **value sources**: `file:<path>#<field>` · `env:<VAR>` ·
`keychain://<svc>/<acct>` · `literal:<value>`.

```bash
hpp-x402 policy set api.example.com \
  --header X-Api-Key=file:~/.config/app.json#api_key --max-per-call 5 --cooldown-ms 300000
```

### `channel` — batch-settlement channels

```bash
hpp-x402 channel ls                       # list local channels
hpp-x402 channel status <channelId>       # channel detail
hpp-x402 channel refund <url> [amount]    # cooperative refund (server co-signs)
hpp-x402 channel withdraw <url> [--finalize]  # unilateral withdraw (server-free)
```

### `safe` — governance wallet mode

```bash
hpp-x402 safe setup --owner-pk 0x... [options]     # create a Safe + AllowanceModule
hpp-x402 safe revoke ...                            # revoke the delegate allowance
```

Advanced. Sets up a [Safe](https://safe.global) with an on-chain **daily
allowance** so a delegate key can only spend up to a cap you control. See
[Wallet modes](#wallet-modes-light-vs-safe).

## Wallet modes: light vs Safe

| Mode | Your cap | Gas | For |
|---|---|---|---|
| **light** (default) | fund small = your cap | none (gasless settlement) | quick start, low value |
| **Safe** (governance) | on-chain daily cap (AllowanceModule) | delegate pays top-up gas | treasury, teams |

In light mode the delegate key **is** the wallet — fund it with only what you're
willing to spend. Safe mode keeps funds in a Safe and grants the delegate a
capped daily allowance (`hpp-x402 safe setup`).

## Use it from your MCP host

`hpp-x402 install <host>` writes this for you, but here's what a host config
entry looks like — the host spawns the `x402-mcp-bridge` server over stdio:

```json
{
  "mcpServers": {
    "hpp-x402": { "command": "npx", "args": ["-y", "@hpp-io/x402-mcp-bridge"] }
  }
}
```

The bridge boots zero-config: with no key set it auto-creates a delegate wallet
in the keychain and prints the funding address. Set `RESOURCE_SERVER_URL` to
proxy a specific paid MCP server, or leave it unset for local tools only
(`x402_http_call`, service discovery).

## Headless / server / CI (no keychain)

A headless box has no OS keychain, so `setup`/`wallet` can't store a key. Use one of:

```bash
hpp-x402 setup --print-key           # prints a raw key instead of using the keychain
# or: export DELEGATE_PRIVATE_KEY=0x...   and skip key generation
```

Read-only commands (`discover`, `status`, `--help`) work anywhere. To try the
CLI without touching the host at all, run it in Docker:

```bash
docker run --rm node:20 bash -c \
  'npm i -g @hpp-io/x402-mcp-bridge && hpp-x402 discover --limit 5 && hpp-x402 setup --print-key'
```

## Contents

- [`install/`](./install/) — one-line installers (`install.sh`, `install.ps1`).
- _(more to come: host config examples, JSON schemas, one-click bundles.)_

## License

Apache-2.0
