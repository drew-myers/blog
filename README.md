# blog

A minimal blog built with [Pollen](https://docs.racket-lang.org/pollen/).

## Enter the dev environment

```sh
nix develop
```

The first run downloads Pollen into the project-local `.racket/` directory
(needs network). After that it's offline and self-contained.

## Write

| File | What it is |
| --- | --- |
| `index.html.pm` | Landing page. Add a link here for each new post. |
| `YYYY-MM-DD-title.html.pm` | A post, written in Markdown (`#lang pollen/markdown`). |
| `template.html.p` | The shared HTML layout. `doc` is the current page's content. |
| `styles.css` | Plain CSS. |

Because filenames sort chronologically, dated posts also appear in order in the
project dashboard.

## Preview

```sh
raco pollen start        # live server at http://localhost:8080
```

Edit a source file and refresh the browser to see the change.

## Build

```sh
./build.sh               # renders sources, assembles a clean site in ../blog-site
```

The deployable site lands in a **sibling** directory (`../blog-site`) because
Pollen refuses to publish inside its own source tree. `build.sh` works either
inside the Nix dev shell or standalone.

Which files get copied is controlled by `omitted-path?` in `pollen.rkt`. It
already omits dotfiles/dirs (`.racket`, `.git`), the flake, and the scripts, so
you get just `*.html` + `styles.css` (plus any assets you add).

## Deploy

```sh
./deploy.sh              # build, then `wrangler deploy`
```

Live at **https://blog.drewmyers.dev**.

The site is a static-assets-only Cloudflare Worker; config is in
`wrangler.jsonc`. It must deploy to the Cloudflare account that owns the
`drewmyers.dev` zone — a Custom Domain has to be in the same account as the
Worker. Sign in once with `wrangler login`.

`assets.html_handling` is `auto-trailing-slash`, so canonical URLs are
extensionless (`/2024-01-15-hello`); the local Pollen server serves the same
extensionless URLs, so internal links work in both places.

## Gotchas

- `template.html.p` must **not** start with `#lang pollen`. Templates are read
  as raw text with `◊(...)` commands embedded.
- `◊(->html doc #:splice? #t)` inserts the page content without the extra
  `<root>` wrapper.
- Render output (`*.html`, `compiled/`) is gitignored. Your sources are the
  `.pm` / `.p` / `.css` files, and the built site is `../blog-site`.
- If you ever need to *force* a file into the published site (e.g. a
  `.nojekyll` for GitHub Pages), add an `extra-path?` predicate alongside
  `omitted-path?` in `pollen.rkt`.
