#!/usr/bin/env bash
#
# Remove locally generated artifacts:
#   - rendered HTML in the source tree (*.html)
#   - Pollen's compile/render cache (compiled/)
#   - the assembled deploy directory (../blog-site)
#
# Keeps .racket/ (the project-local Racket package scope). Delete that by hand
# if you want the space back; the next `nix develop` reinstalls it.

set -euo pipefail
cd "$(cd "$(dirname "$0")" && pwd)"

site="${SITE:-../blog-site}"

rm -f ./*.html
rm -rf compiled "$site"

echo "Cleaned: *.html, compiled/, $site"
