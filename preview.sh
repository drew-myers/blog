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
trap clean_rendered_html EXIT INT TERM

if command -v raco >/dev/null 2>&1; then
  raco pollen start "$@"
else
  nix develop --command raco pollen start "$@"
fi
