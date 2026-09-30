#lang racket/base

;; Project settings for Pollen. The `setup` submodule is what Pollen reads.
(module+ setup
  (require racket/path)
  (provide (all-defined-out))

  ;; Project plumbing that should never be rendered or published. Pollen
  ;; already omits Pollen/Racket sources, `compiled/`, and VCS directories.
  (define omitted-names
    '("compiled"
      "flake.nix"
      "flake.lock"
      "README.md"
      "template.html"
      "build.sh"
      "deploy.sh"
      "clean.sh"
      "Makefile"
      "wrangler.jsonc"
      "wrangler.toml"))

  ;; Omit by matching individual path components (never the basename alone,
  ;; because `file-name-from-path` returns #f for directories and would make
  ;; us omit whole directory trees).
  (define (omitted-path? path)
    (for/or ([part (in-list (explode-path path))])
      (and (path? part)
           (let ([name (path->string part)])
             (or (regexp-match? #rx"^\\." name)      ; hidden files/dirs
                 (and (member name omitted-names) #true)))))))
