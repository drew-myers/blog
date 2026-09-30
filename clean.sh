#!/usr/bin/env bash
#
# Remove locally generated artifacts:
#   - rendered HTML in the source tree (root + subdirs)
#   - Pollen compile/render caches (compiled/)
#   - the assembled deploy directory (../blog-site)
#
# Keeps .racket/ (the project-local Racket package scope). Delete that by hand
# if you want the space back; the next `nix develop` reinstalls it.

set -euo pipefail
cd "$(cd "$(dirname "$0")" && pwd)"

site="${SITE:-../blog-site}"

find . \( -name '*.pm' -o -name '*.pmd' -o -name '*.p' \) \
  -not -path './.racket/*' -not -path '*/compiled/*' -print0 |
  while IFS= read -r -d '' source; do
    case "$source" in
      *.pm)  rm -f -- "${source%.pm}" ;;
      *.pmd) rm -f -- "${source%.pmd}" ;;
      *.p)   rm -f -- "${source%.p}" ;;
    esac
  done

find . -type d -name compiled -not -path './.racket/*' -prune -exec rm -rf -- {} +
rm -rf -- "$site"

echo "Cleaned: rendered HTML, compiled/, $site"
