#!/usr/bin/env sh
# hpp-x402 installer — one-liner:
#   curl -fsSL https://raw.githubusercontent.com/hpp-io/x402-tools/main/install/install.sh | bash
#
# Installs the public @hpp-io/x402-mcp-bridge npm package globally, which puts
# the `hpp-x402` CLI (+ the `x402-mcp-bridge` MCP server) on your PATH.
set -e

PKG="@hpp-io/x402-mcp-bridge"
echo "Installing hpp-x402 (${PKG})…"

REQS_URL="https://github.com/hpp-io/x402-tools#system-requirements"
if ! command -v node >/dev/null 2>&1; then
  echo "✗ Node.js not found — hpp-x402 needs Node 20+."
  echo "  Install it from https://nodejs.org (or: brew install node / use nvm), then re-run."
  echo "  Requirements: ${REQS_URL}"
  exit 1
fi
NODE_MAJOR=$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)
if [ "$NODE_MAJOR" -lt 20 ]; then
  echo "✗ Node $(node -v) is too old — need 20+. Please upgrade and re-run."
  echo "  Requirements: ${REQS_URL}"
  exit 1
fi

if npm install -g "$PKG"; then
  :
elif command -v sudo >/dev/null 2>&1; then
  echo "Retrying with sudo (global npm prefix not writable)…"
  sudo npm install -g "$PKG"
else
  echo "✗ Global install failed (permissions). Try:  sudo npm install -g $PKG"
  exit 1
fi

echo ""
echo "✓ Installed hpp-x402. Get started:"
echo ""
echo "    hpp-x402 setup --install claude-code    # create wallet + register into your host"
echo "    hpp-x402 fund                            # show where to send USDC.e"
echo "    hpp-x402 --help                          # all commands"
echo ""
