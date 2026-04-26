# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Personal website at **adam-young.co.uk** — Jekyll-based, hosted on GitHub Pages via a GitHub Actions deployment workflow (not Pages' default branch-build).

## Commands

```bash
bundle install                  # install gems (Ruby 3.1.6, see .ruby-version)
bundle exec jekyll serve        # local dev server at http://127.0.0.1:4000
bundle exec jekyll build        # produce _site/
bundle update                   # bump all gems within Gemfile constraints
```

There are no tests, linters, or formatters configured.

## Deployment

Pushing to `main` triggers `.github/workflows/pages.yml`, which builds with Ruby 3.1.6 and deploys via `actions/deploy-pages@v5`. The repo's GitHub Pages source must be set to **"GitHub Actions"** (not "Deploy from a branch") for the workflow to deploy.

`Gemfile.lock` includes both `arm64-darwin-23` (local) and `x86_64-linux` (CI) platforms. If you regenerate the lockfile and only the local platform appears, run `bundle lock --add-platform x86_64-linux` before pushing or CI will fail.

## Architecture

### Pages and routing

- `index.html` — home page (frosted-glass hero + Projects + Elsewhere + stack chips)
- `blog/index.html` (permalink `/blog/`) — post list
- `_posts/YYYY-MM-DD-*.md` — posts; permalink format `/blog/:year/:month/:day/:title/` (set in `_config.yml`)
- `_layouts/default.html` wraps every page; `_layouts/post.html` extends default for individual posts
- `_includes/header.html` carries the full `<head>`, ambient blob layer, and top nav; `_includes/footer.html` closes them

### Design system

The visual language is "cool frosted glass" — drifting cyan/indigo/mint blobs behind glass cards with `backdrop-filter`, supporting both light and dark via `prefers-color-scheme`. All styling lives in **one file**, `css/styles.scss`, structured as:

1. `:root` CSS custom properties for both colour schemes
2. Layout primitives (`.ambient`, `.glass`, `.nav`, `.hero`, `.cards`, `.card`, `.chip`)
3. Blog-specific styling (`.blog-header`, `.posts-list`, `.post-link`, `.post-body`)
4. Rouge syntax-highlight palette at the bottom (`github.light` baseline + `github.dark` inside a `prefers-color-scheme: dark` media query)

The `.glass` class is the reusable mixin: it stacks `backdrop-filter` blur + a thin gradient border (via `mask-composite`) + a top inner highlight. Apply it to any element you want to look frosted.

### SEO

`jekyll-seo-tag` does most of the heavy lifting; `_includes/header.html` deliberately avoids duplicating any tag the plugin emits. Per-page `og:image` defaults are set via Jekyll **defaults** in `_config.yml` (because `jekyll-seo-tag` reads `image:` from the page drop, not the site config). If you add a post with a custom hero, override `image:` in that post's front matter to provide its own social card.

Twitter card type is auto-resolved by `jekyll-seo-tag`: `summary_large_image` whenever an `image` is present (which is always, via the default), otherwise `summary`.

### Adding a blog post

Create `_posts/YYYY-MM-DD-slug.md` with front matter:

```yaml
---
title: "Post Title"
date: YYYY-MM-DD HH:MM:SS +0100
description: "Short blurb shown on the blog index and as og:description."
tags: [tag1, tag2]
---

![Alt text](/assets/images/posts/slug.svg)

Body…
```

The `layout: post` is applied automatically (`defaults` in `_config.yml`). Code blocks use ` ```swift ` etc. — Rouge highlights with the GitHub palette in both modes.

### Conventions worth knowing

- The hero "AY" avatar on the home page is a CSS gradient, not an image — `assets/images/me.jpg` is only the OG/share image.
- Post hero images live under `assets/images/posts/` and are SVG (small, scalable, on-brand). Twitter doesn't render SVG OG cards, so per-post `image:` overrides should usually point at PNG/JPG; the SVG is fine for the in-page hero.
- The `designs/` folder used during the redesign is gone — don't recreate it.
- `_sass/` was removed; all CSS is in `css/styles.scss` directly.
