#!/usr/bin/env bash
#
# Start the Pollen preview server, and remove rendered HTML from the source
# tree when the server exits. Pollen renders in place, so browsing would
# otherwise leave *.html alongside your sources.
#
# Works inside the Nix dev shell or on its own.
# Any args are passed through, e.g. `./preview.sh . 8080`.

set -euo pipefail
cd "$(cd "$(dirname "$0")" && pwd)"

cleanup() { rm -f ./*.html; }
trap cleanup EXIT INT TERM

if command -v raco >/dev/null 2>&1; then
  raco pollen start "$@"
else
  nix develop --command raco pollen start "$@"
fi
