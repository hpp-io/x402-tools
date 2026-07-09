# hpp-x402 installer (Windows PowerShell) — one-liner:
#   irm https://raw.githubusercontent.com/hpp-io/x402-tools/main/install/install.ps1 | iex
$ErrorActionPreference = "Stop"
$Pkg = "@hpp-io/x402-mcp-bridge"
Write-Host "Installing hpp-x402 ($Pkg)…"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Host "X Node.js not found - hpp-x402 needs Node 20+. Install from https://nodejs.org and re-run."
  exit 1
}
$major = [int](node -p "process.versions.node.split('.')[0]")
if ($major -lt 20) {
  Write-Host "X Node $(node -v) is too old - need 20+. Please upgrade."
  exit 1
}

npm install -g $Pkg

Write-Host ""
Write-Host "OK Installed hpp-x402. Get started:"
Write-Host "    hpp-x402 setup --install claude-code"
Write-Host "    hpp-x402 fund"
Write-Host "    hpp-x402 --help"
