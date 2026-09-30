#lang racket/base

(require racket/file
         racket/list
         racket/path
         racket/string
         pollen/setup)

(provide (all-defined-out))

;; ── Blog index ────────────────────────────────────────────────────────────
;; `posts-list` scans posts/*.html.pm in filename order (= date order) and
;; returns a Markdown bullet list, using each post's first "# Heading" as the
;; link text. Insert it from a Markdown source with:  ◊(posts-list)

(define posts-dir "posts")

(define (post-source-files)
  (define dir (build-path (current-project-root) posts-dir))
  (if (directory-exists? dir)
      (sort (for/list ([name (in-list (directory-list dir))]
                       #:when (regexp-match? #rx"[.]html[.]pm$" (path->string name)))
              (build-path dir name))
            path<?)
      '()))

(define (post-title source)
  (define rx #rx"^#[ \t]+(.+)$")
  (define match
    (for/first ([line (in-list (file->lines source))]
                #:when (regexp-match? rx line))
      (regexp-match rx line)))
  (or (and match (string-trim (cadr match)))
      (path->string (file-name-from-path source))))

(define (post-href source)
  (regexp-replace #rx"[.]pm$"
                  (path->string (find-relative-path (current-project-root) source))
                  ""))

(define (markdown-escape text)
  (string-replace (string-replace text "[" "\\[") "]" "\\]"))

(define (posts-list)
  (string-join
   (for/list ([source (in-list (post-source-files))])
     (format "- [~a](~a)" (markdown-escape (post-title source)) (post-href source)))
   "\n"))

;; Project settings for Pollen. The `setup` submodule is what Pollen reads.
(module+ setup
  (provide (all-defined-out))

  ;; Project plumbing that should never be rendered or published. Pollen
  ;; already omits Pollen/Racket sources, compiled/, and VCS directories.
  (define omitted-names
    '("compiled"
      "flake.nix"
      "flake.lock"
      "README.md"
      "template.html"
      "build.sh"
      "deploy.sh"
      "clean.sh"
      "preview.sh"
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
