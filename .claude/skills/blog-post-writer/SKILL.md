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
image: /assets/images/posts/<slug>.svg
---
```

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

## 4. Hero image (SVG)

Every post has a hero SVG at `Resources/assets/images/posts/<slug>.svg`. Open one or two existing ones (`canon-tdd.svg`, `existential-and-opaque-types.svg`) and match the visual language:

- ViewBox `0 0 1200 630` (Twitter / OG dimensions).
- Dark gradient background: `linearGradient` from `#0d1626` to `#040810`.
- Two `radialGradient` glows in cyan (`#22d3ee`) and indigo (`#818cf8`) at low opacity (around 0.18 to 0.25), positioned in opposite corners.
- Title in a gradient text fill (cyan to indigo, sometimes adding magenta `#d946ef`).
- Subtitle in `#9aa6b8`.
- A visual element that captures the post's central metaphor in a sentence. Hand-rolled shapes, simple icons, code-style boxes, diagrams. Don't paste from elsewhere.
- Always include `role="img"` and a meaningful `aria-label` for accessibility.

If the post benefits from a second SVG inside the body (like the Canon TDD flowchart at `canon-tdd-flowchart.svg`), make it. The hero is referenced in the front matter `image:` field; body images are inline markdown (`![alt](/assets/images/posts/<slug>-thing.svg)`).

## 5. Drafting workflow

1. Read the source material Adam provided.
2. Pick a tone target by reading one existing post in the closest format (technical → `map-filter-reduce.md`; essay → `when-ai-forgets-wonder.md`; talk write-up → `canon-tdd.md` or `existential-and-opaque-types.md`).
3. Decide a slug and a date.
4. Draft the post in one pass. Use `##` and `###` for sections. Include code samples verbatim from the source where they exist. Don't pad.
5. Generate the hero SVG. Match the style above.
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
