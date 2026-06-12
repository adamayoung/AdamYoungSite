---
name: blog-post-images
description: Use this skill to create or refresh the visual assets for a blog post on adam-young.co.uk — the wide hero, the square thumbnail, and any in-body diagrams. It produces on-brand SVG sources and rasterizes the committed PNG exports. Use it when writing a new post (invoked by blog-post-writer) or on its own to redo art for an existing post. Triggers: "make the hero image", "regenerate the thumbnail", "redo the art for <post>", "the hero looks same-y", "/blog-post-images".
---

# blog-post-images

You make the visual assets for a blog post on adam-young.co.uk. The prose, voice, and tags are the writer's job (see the `blog-post-writer` skill). Yours is everything pixel-shaped: the wide hero, the square thumbnail, and any in-body diagram, each an SVG source with a committed PNG export where one is needed.

## 0. What you need before designing

You need three things. If you were invoked by `blog-post-writer` they'll be handed to you; if Adam invoked you directly, gather them:

- **The slug** — the post's filename stem (`Content/blog/clean-architecture.md` → slug `clean-architecture`). All four files are named off it.
- **The central metaphor** — one sentence on what the post is *about* visually. This drives the bespoke mark. If you weren't told, read the post at `Content/blog/<slug>.md` and pull it out yourself.
- **What recent posts look like** — before designing, read the two or three most recent `*.svg` heroes in `Resources/assets/images/posts/` and note their background value (light/dark) and hue. You are going to deliberately pick something none of them used.

If you don't have a slug and can't find the post, ask. Don't guess.

## 1. The files you produce

Every post needs **two** image pairs, each an SVG source with a committed PNG export. All four live in `Resources/assets/images/posts/`.

| Purpose | SVG source | PNG export | Size |
| --- | --- | --- | --- |
| Wide hero (blog feature cards, post header, OG/Twitter share) | `<slug>.svg` | `<slug>.png` | 1200×630 |
| Square thumbnail (compact blog-list tiles) | `<slug>-thumb.svg` | `<slug>-thumb.png` | 600×600 |

The SVG is always the source of truth; the PNG is what gets loaded. The square thumbnail is picked up automatically by the blog tile list — the theme looks for `<slug>-thumb.png` next to the hero and falls back to a centre-crop of the wide hero if it isn't there. There's no front-matter field for it; the `-thumb` filename is the contract.

The post's front-matter `image:` field references the **wide** PNG (`<slug>.png`). That line is written by `blog-post-writer`, not here — you produce the asset, the writer wires the reference. Don't edit the post's front matter.

## 2. Make each post look different

This is the part that keeps going wrong. The first heroes were all dark navy with cyan/indigo glows. The fix attempt that only swapped the accent glows **still read as same-y**, because every hero was a dark, low-saturation card with a light title and a diagram off to one side — same value, same mood, same composition. Shifting an accent that sits at 18% opacity over near-black changes almost nothing at a glance.

So the variety has to come from the **background itself** — its lightness and its saturation — not from the glows. At thumbnail size on the blog index, each hero should be instantly nameable: "the purple one", "the cream one", "the sunset one".

Keep these shared (this is the only family resemblance you need):

- ViewBox `0 0 1200 630` for the hero, `0 0 600 600` for the thumbnail.
- Title fonts: `-apple-system, SF Pro Display, …`. Mono kicker/footer: `ui-monospace, SF Mono, Menlo, monospace`.
- Hero layout: top accent rule + mono kicker top-left, title (~58–64px) and a one-line subtitle under it, a bespoke mark capturing the metaphor, and the footer rule with `ADAM YOUNG · <date>` left and `ADAM-YOUNG.CO.UK` right.
- Always `role="img"` with a meaningful `aria-label`.

Vary all of this, hard, per post:

- **Background value.** Do NOT default to dark. Across the set, mix dark, mid, and *light* backgrounds. A light hero (warm cream, pale slate) sitting next to the dark ones does more for variety than any accent change. Aim for at most three or four genuinely dark heroes in a row before a light or bright one breaks the run.
- **Background saturation.** When you do go dark, make the hue obvious — a saturated deep violet (`#241552`), a real blue (`#0d3b6e`), a warm plum-to-amber sunset — not a desaturated near-black you have to squint at. The background colour should be legible as a colour.
- **Glows + accent gradient** drawn from the palette (kicker, rules, mark strokes/markers). On a saturated or light background these can be bolder (opacity 0.25–0.4).
- **Title colour follows the background.** Light neutral gradient (`#f1f5fb` → `#c5cdda`) on dark/bright backgrounds; a dark ink (`#15241c`-ish, tuned to the hue) on light backgrounds. Subtitle and footer pick a tone with real contrast against the background, not a fixed grey — `#9aa6b8`/`#525866` only work on dark.
- **The bespoke mark.** A visual that captures the post's central metaphor in a sentence. Hand-rolled shapes, icons, code-style boxes, diagrams. Don't paste from elsewhere.

Starting recipes — pick one clearly distinct from the last two or three posts, or invent one in the same spirit (the point is range, not these exact six):

| Look | Background treatment | Accents | Title |
| --- | --- | --- | --- |
| Saturated violet (dark) | linear `#241552` → `#0e0826`, bright violet bloom | `#a78bfa` / `#e879f9` | light |
| Azure blueprint (dark) | linear `#0d3b6e` → `#071a38`, faint cyan grid | `#38bdf8` / `#fbbf24` | light |
| Warm paper (**light**) | linear `#f3efe6` → `#e7ded0` | `#059669` / `#65a30d` | dark ink `#15241c` |
| Bold magenta (dark) | linear `#2a0f33` → `#120618`, fuchsia bloom | `#e879f9` / `#fb7185` | light |
| Traffic-light red→green (dark, warm) | linear `#1f0f10` → `#0a0606`, red bloom + emerald bloom | `#f43f5e` → `#10b981` | light |
| Sunset (warm, bright-ish) | vertical `#1a1033` → `#3a1840` → warm `#6b2438`, amber horizon glow | `#fbbf24` / `#f472b6` | light |

Before designing, read the two or three most recent `*.svg` heroes and deliberately pick a value (light/dark) and hue none of them used. If three recent posts are all dark, your next one is light or bright. No exceptions — that single rule is what stops the set drifting back to same-y.

## 3. Thumbnail design

The thumbnail renders at roughly 92px in the tile list, so fine detail and body text are lost. Make it **bold and iconographic**: the post's palette gradient background, one or two glows, and a single large emblem that distils the hero's motif (the concentric rings, the layered stack, the loop arrow, the box, whatever the hero centres on). The post title already sits next to it in the tile, so don't rely on readable text — a tiny mono kicker is the most you'd want. Use the same palette as the hero so the pair reads as one post.

## 4. Rasterize both (the build does not do this — commit all four files)

```bash
rsvg-convert -w 1200 -h 630 Resources/assets/images/posts/<slug>.svg       -o Resources/assets/images/posts/<slug>.png
rsvg-convert -w 600  -h 600 Resources/assets/images/posts/<slug>-thumb.svg  -o Resources/assets/images/posts/<slug>-thumb.png
```

If you edit either SVG later, re-run the matching command so the PNG doesn't drift. If `rsvg-convert` is missing, `brew install librsvg`.

## 5. Body diagrams (optional)

If the post benefits from a diagram inside the body (like the Canon TDD flowchart at `canon-tdd-flowchart.svg`), make it. Body diagrams stay **SVG-only** — only the front-matter hero and its thumbnail need PNG exports. Body images are referenced as inline markdown in the post (`![alt](/assets/images/posts/<slug>-thing.svg)`); if you add one, tell the writer (or Adam) the markdown line to drop in, since editing the post body isn't your job.

## 6. Done

You're finished when all four files exist (`<slug>.svg`, `<slug>.png`, `<slug>-thumb.svg`, `<slug>-thumb.png`), the PNGs match their current SVGs, and any body diagram you were asked for exists as an SVG. Don't commit or push. If you were invoked by `blog-post-writer`, hand back so it can build and show Adam.
