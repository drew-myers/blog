#!/usr/bin/env bash
#
# Build the deployable site into $SITE (default ../blog-site).
#
# Pollen refuses to publish into its own source tree, hence the sibling dir.
# Publish filtering (what gets copied) is configured in pollen.rkt.
#
# Works inside the Nix dev shell or on its own (it will enter the shell for you).

set -euo pipefail

site="${SITE:-../blog-site}"

# Use raco directly if we're already in the dev shell; otherwise enter it.
if command -v raco >/dev/null 2>&1; then
  run() { "$@"; }
else
  run() { nix develop --command "$@"; }
fi

run raco pollen render .
run raco pollen publish . "$site"

# The rendered HTML now lives in $site; drop the in-tree copies so the source
# tree stays tidy.
rm -f ./*.html

echo "Built: $site"
