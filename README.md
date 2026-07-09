# x402-tools

Public tools & resources for **HPP x402** — the agent payment rail on HPP.

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
