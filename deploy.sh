#!/usr/bin/env bash
#
# Build the site and deploy it to Cloudflare Workers.
# Works inside the Nix dev shell or standalone.

set -euo pipefail
cd "$(cd "$(dirname "$0")" && pwd)"

./build.sh

if command -v wrangler >/dev/null 2>&1; then
  wrangler deploy
else
  nix develop --command wrangler deploy
fi
