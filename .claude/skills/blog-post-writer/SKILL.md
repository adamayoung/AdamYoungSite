---
name: blog-post-writer
description: Use this skill when Adam wants to write a blog post for adam-young.co.uk. He will usually hand over a PDF of a talk, a draft transcript, or rough notes. The skill structures the source content into a finished post in his voice, picks tags, and generates a hero SVG. It does NOT invent ideas, opinions, examples, or facts that aren't in the source. Triggers: "write a blog post", "draft a post", "turn this PDF/talk into a blog post", "blog this", "/blog-post-writer".
---

# blog-post-writer

You are drafting a blog post for adam-young.co.uk. Adam will hand you source material (a PDF, a transcript, or notes). Your job is to turn it into a finished post in his voice, with tags and a hero image. The ideas are his. You structure and polish.

## 0. Read these before drafting

Always read these in parallel before writing a single word:

- `CLAUDE.md` — the "Adding a blog post" section has the canonical front matter format and slug rules.
- `Content/blog/*.md` — the existing posts. They are the live voice reference. Read at least two: one in the closest tone to whatever you're writing (technical Swift tutorial, essay, talk write-up).
- The source material Adam handed you. Use the `Read` tool on the PDF directly.

If Adam hasn't handed you any source material and you don't have a topic, ask. Don't guess.

## 1. Voice rules — these are absolute

If a draft violates one of these, fix it before showing Adam.

### Spelling and address

- **British spelling.** behaviour, organise, recognised, colour, optimise, fulfilment, defence, analyse, programme (the noun), travelled. Don't "translate" code or library names.
- **Direct second person.** Use "you" for the reader. Use "we" inclusively (you and the reader doing something together). Never "one" or "the developer" or "users". The post should feel like Adam is talking to one person across a desk.
- **Conversational, not formal.** Light asides, gentle self-deprecation, the occasional dry joke. Never a lecture.
- **No "in conclusion", "this article will explore", "let us examine", "it is important to note that", "in summary".** Just say the thing.

### Punctuation

- **No em-dashes (`—`).** Replace with commas, parentheses, semicolons, or full stops. Restructure the sentence if you have to. Adam uses em-dashes himself but doesn't want them in your drafts because they're a giveaway AI tell. He can add them back.
- **No en-dashes (`–`) used as em-dashes.** Hyphens for compound words are fine.
- **Sparingly use parentheses for asides.** They suit his voice better than em-dashes.

### AI tells — delete on sight

Scan for these and rewrite the sentence if any appear. Non-exhaustive:

- delve, delving, delve into
- leverage (just say "use")
- robust (say what's actually good about it)
- crucial (try "important", or just say what matters)
- comprehensive (say what it covers)
- holistic, synergy, synergise
- tapestry, rich tapestry
- realm, in the realm of
- embark, embark on (say "start")
- foster (build, grow)
- unleash (release, ship)
- streamline (simplify, speed up)
- game-changer, game-changing
- cutting-edge, state-of-the-art, next-generation
- harness the power of, unlock the potential of, navigate the complexities of
- in today's fast-paced world, in this digital age
- it's worth noting that, it is important to note
- underscore, underscores the importance
- bespoke (when you mean "custom")
- ensure that (just "make sure")
- facilitate (help, let, allow)
- utilise (use)
- myriad, plethora (lots, many)
- moving forward, at the end of the day
- "In this blog post, we will explore…"
- "I hope this helps", "Hopefully this gives you a sense of"

Add to this list whenever Adam flags a phrase he hates.

### Sentence rhythms to break

- **Tricolons.** Three-item parallel lists ("fast, reliable, and scalable") in a row are an AI signature. Drop one item or vary the structure.
- **"Not just X, but Y."** Once per post is fine. Twice is a tell.
- **Hedging stacks.** "While it's true that, in many cases, one might…". Just say it.
- **Closing meta-commentary.** End on a substantive sentence, not a wave goodbye.

### Patterns Adam uses that you should mirror

(Confirm by reading his existing posts. These are observed.)

- Opens with a hook: a personal moment, a quote, a contrarian one-liner. Never a definition.
- Code examples for technical posts, often with progressive simplification (the long-form closure → `{ $0 * 2 }` style).
- Blockquotes for things he's actually quoting (Henry Ford, Kent Beck), not for tips or callouts.
- H2s are major beats, H3s are sub-points within a beat. Headings are conversational ("So what's the actual difference?", "Where does `some` come into it?"), not corporate ("Conclusion", "Overview").
- Acknowledges common confusions out loud ("yeah yeah yeah, I know what TDD is").
- Closes with a link to the source material when riffing on someone else's idea.

## 2. Front matter format

Per `CLAUDE.md`:

```yaml
---
title: Post Title
date: YYYY-MM-DD HH:MM
description: One sentence shown on the blog index and as og:description.
tags: tag1, tag2
image: /assets/images/posts/<slug>.png
---
```

The `image:` references the **`.png`** (rasterized hero) — the SVG is the source, the PNG is what gets loaded in cards and OG/Twitter share previews. See section 4 for the SVG → PNG step.

Rules:

- **No quotes around the title.** Publish's frontmatter parser is naive and the quotes render literally.
- **Title can contain a colon.** Only the first colon is treated as the key/value separator.
- **Date is today** unless Adam tells you otherwise. Use 12:00 if no time matters; bump the time if there is already a post earlier today so this one sorts first.
- **Description is one sentence**, around 140 to 180 characters, drawn from the post's own opening claim. It powers the home preview card and the OG description.
- **Slug is the filename** (`Content/blog/canon-tdd.md` → `/blog/canon-tdd/`). Pick a slug that is short, kebab-case, and descriptive of the topic, not a verbatim copy of the title.

## 3. Tags

1. Read `Content/blog/*.md` to see which tags already exist on the site. The rail's Topics list is built from these. New posts should slot into the existing taxonomy where they fit.
2. Reuse existing tags first. If a post is about Swift, use `swift` (lowercase, exact match), not `Swift` or `swift-language`.
3. Add new tags only when no existing one fits. Multi-word tags are allowed (`existential types`, `opaque types`); Publish slugifies them for URLs.
4. Two to four tags per post. Don't tag-stuff.

## 4. Hero image + thumbnail

Every post needs **two** images, each an SVG source with a committed PNG export:

| Purpose | SVG source | PNG export | Size |
| --- | --- | --- | --- |
| Wide hero (blog feature cards, post header, OG/Twitter share) | `<slug>.svg` | `<slug>.png` | 1200×630 |
| Square thumbnail (compact blog-list tiles) | `<slug>-thumb.svg` | `<slug>-thumb.png` | 600×600 |

All four files live in `Resources/assets/images/posts/`. The SVG is always the source of truth; the PNG is what gets loaded. The front matter `image:` field references the **wide** PNG (`<slug>.png`). The square thumbnail is picked up automatically by the blog tile list — the theme looks for `<slug>-thumb.png` next to the hero and falls back to a centre-crop of the wide hero if it isn't there. There is no front-matter field for it; the `-thumb` filename is the contract.

### Make each post look different

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

### Thumbnail design

The thumbnail renders at roughly 92px in the tile list, so fine detail and body text are lost. Make it **bold and iconographic**: the post's palette gradient background, one or two glows, and a single large emblem that distils the hero's motif (the concentric rings, the layered stack, the loop arrow, the box, whatever the hero centres on). The post title already sits next to it in the tile, so don't rely on readable text — a tiny mono kicker is the most you'd want. Use the same palette as the hero so the pair reads as one post.

### Rasterize both (the build does not do this — commit all four files)

```bash
rsvg-convert -w 1200 -h 630 Resources/assets/images/posts/<slug>.svg       -o Resources/assets/images/posts/<slug>.png
rsvg-convert -w 600  -h 600 Resources/assets/images/posts/<slug>-thumb.svg  -o Resources/assets/images/posts/<slug>-thumb.png
```

If you edit either SVG later, re-run the matching command so the PNG doesn't drift. If `rsvg-convert` is missing, `brew install librsvg`.

If the post benefits from a diagram inside the body (like the Canon TDD flowchart at `canon-tdd-flowchart.svg`), make it. Body diagrams stay SVG-only — only the front-matter hero and its thumbnail need PNG exports. Body images are inline markdown (`![alt](/assets/images/posts/<slug>-thing.svg)`).

## 5. Drafting workflow

1. Read the source material Adam provided.
2. Pick a tone target by reading one existing post in the closest format (technical → `map-filter-reduce.md`; essay → `when-ai-forgets-wonder.md`; talk write-up → `canon-tdd.md` or `existential-and-opaque-types.md`).
3. Decide a slug and a date.
4. Draft the post in one pass. Use `##` and `###` for sections. Include code samples verbatim from the source where they exist. Don't pad.
5. Generate the hero SVG and the square thumbnail SVG in a palette and motif distinct from recent posts, then rasterize both to PNGs (hero `-w 1200 -h 630`, thumb `-w 600 -h 600`; see section 4). All four files are committed.
6. Pick the tags. Reuse before inventing.
7. Run the self-review pass (section 6).
8. Build to verify: `rm -rf Output && swift run AdamYoungSite`. Confirm the post appears on the home page and on `/blog/`.
9. Show Adam the result. Do not commit. Do not push. He'll review.

## 6. Self-review pass

Before showing Adam, run the literal checks:

```bash
# em-dashes — must be zero
grep -c '—' Content/blog/<slug>.md

# en-dashes used as em-dashes — must be zero
grep -c '–' Content/blog/<slug>.md

# AI tells — must return nothing
grep -iE '(\bdelve|\bleverage|\brobust\b|\bcrucial\b|\bcomprehensive\b|\btapestry|\brealm\b|\bembark\b|\bfoster\b|\bunleash\b|\bstreamline\b|\bholistic\b|\bsynergy|\bgame-?chang|\bcutting-edge\b|\bstate-of-the-art\b|\bharness the\b|\bunlock the potential\b|\bnavigate the\b|\bmyriad\b|\bplethora\b|\bfacilitate\b|\butilise\b|\butilize\b|\bensure that\b|in today.s|moving forward|at the end of the day|underscore|in this blog post|hope (this|you))' Content/blog/<slug>.md
```

If any check returns a hit, rewrite the offending sentence and re-check. Don't show Adam a draft until all checks pass.

Then read the post end to end with two questions:
- Does the first paragraph sound like Adam, or like ChatGPT? If the latter, redo it.
- Is the closing line a substantive sentence, or a "hope this was useful" wave-goodbye? The latter gets cut.

## 7. Hard rules — never do these

- **Don't invent claims, opinions, statistics, examples, or quotes that aren't in the source.** If the source says "I gave a talk on X", don't add "and the audience loved it". If a code snippet isn't in the source, don't fabricate one to fill space. If you genuinely need an example to make a point land, ask Adam for one.
- **Don't add a "Conclusion" or "Summary" or "Overview" heading.** A natural closing paragraph is enough. A TL;DR section at the end is allowed if the post is long enough to genuinely benefit from one.
- **Don't add placeholders** like `[insert example here]` or `TODO`. If you're missing content, ask before drafting.
- **Don't push or commit.** Draft the post, build to verify, stop. Adam reviews and tells you what's next.
- **Don't second-guess the source's content.** If Adam said something in his talk, treat it as load-bearing. Restructure the order if it helps the post flow, but don't argue with the substance.

## 8. When in doubt, ask

The skill exists to save Adam time on structure and polish, not to second-guess his content. If the source is ambiguous, ask one focused question rather than guessing. One question is fine. A multi-question audit is annoying.
