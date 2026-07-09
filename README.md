# x402-tools

Public tools & resources for **HPP x402** — the agent payment rail on HPP.

## System requirements

| | Requirement |
|---|---|
| **Node.js** | 20 or newer (check with `node -v`). Install from [nodejs.org](https://nodejs.org), `brew install node`, or [nvm](https://github.com/nvm-sh/nvm). |
| **npm** | Bundled with Node.js. |
| **OS** | macOS, Linux, or Windows. |
| **Wallet storage** | An OS keychain — macOS Keychain / Linux gnome-keyring / Windows Credential Manager. Needed by `setup` and `wallet` to store your key. |

The installer only checks for Node and runs `npm i -g` — it does **not** install
Node for you. Install Node first (above), then run the one-liner.

### Headless / server / CI (no keychain)

A headless box (no desktop) has no OS keychain, so `setup`/`wallet` can't store a
key there. Use one of:

```bash
hpp-x402 setup --print-key    # prints a raw key instead of using the keychain
# or: export DELEGATE_PRIVATE_KEY=0x...   and skip key generation
```

Read-only commands (`discover`, `status`, `--help`) work anywhere.

To try the CLI without touching the host at all, run it in Docker:

```bash
docker run --rm node:20 bash -c 'npm i -g @hpp-io/x402-mcp-bridge && hpp-x402 discover --limit 5 && hpp-x402 setup --print-key'
```

## Install the CLI

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/hpp-io/x402-tools/main/install/install.sh | bash
# Windows (PowerShell)
irm https://raw.githubusercontent.com/hpp-io/x402-tools/main/install/install.ps1 | iex
```

This installs the public [`@hpp-io/x402-mcp-bridge`](https://www.npmjs.com/package/@hpp-io/x402-mcp-bridge)
npm package globally, giving you the `hpp-x402` CLI. Prefer npm directly? Same thing:

```bash
npm install -g @hpp-io/x402-mcp-bridge
```

Then:

```bash
hpp-x402 setup --install claude-code   # create a wallet + register into your MCP host
hpp-x402 fund                           # where to send USDC.e
hpp-x402 --help
```

> The install scripts do nothing but check for Node 20+ and `npm i -g` the
> package — you can read them in [`install/`](./install/) before running.

## Contents

- [`install/`](./install/) — one-line installers (`install.sh`, `install.ps1`).
- _(more to come: host config examples, JSON schemas, one-click bundles.)_

## License

Apache-2.0
