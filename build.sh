#!/usr/bin/env bash
#
# Build the deployable site into $SITE (default ../blog-site).
#
# Pollen refuses to publish into its own source tree, hence the sibling dir.
# Publish filtering (what gets copied) is configured in pollen.rkt.
#
# Works inside the Nix dev shell or on its own (it will enter the shell for you).

set -euo pipefail
cd "$(cd "$(dirname "$0")" && pwd)"

site="${SITE:-../blog-site}"

if command -v raco >/dev/null 2>&1; then
  run() { "$@"; }
else
  run() { nix develop --command "$@"; }
fi

# Delete the in-tree HTML rendered from each Pollen source (root + subdirs).
# Only strips the source's own extension, so the sources themselves are safe.
clean_rendered_html() {
  find . \( -name '*.pm' -o -name '*.pmd' -o -name '*.p' \) \
    -not -path './.racket/*' -not -path '*/compiled/*' -print0 |
    while IFS= read -r -d '' source; do
      case "$source" in
        *.pm)  rm -f -- "${source%.pm}" ;;
        *.pmd) rm -f -- "${source%.pmd}" ;;
        *.p)   rm -f -- "${source%.p}" ;;
      esac
    done
}

# -s renders subdirectories (posts/) while keeping the project root fixed, so
# the shared template.html.p still applies to them. -f forces a re-render so
# the generated index picks up added/removed posts (the index source itself
# doesn't change, so the cache would otherwise reuse stale output).
run raco pollen render -f -s .
run raco pollen publish . "$site"
clean_rendered_html

echo "Built: $site"
