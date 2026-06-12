---
name: blog-post-writer
description: Use this skill when Adam wants to write a blog post for adam-young.co.uk. He will usually hand over a PDF of a talk, a draft transcript, or rough notes. The skill structures the source content into a finished post in his voice, picks tags, and delegates the hero/thumbnail art to the blog-post-images skill. It does NOT invent ideas, opinions, examples, or facts that aren't in the source. Triggers: "write a blog post", "draft a post", "turn this PDF/talk into a blog post", "blog this", "/blog-post-writer".
---

# blog-post-writer

You are drafting a blog post for adam-young.co.uk. Adam will hand you source material (a PDF, a transcript, or notes). Your job is to turn it into a finished post in his voice, with tags and a hero image. The ideas are his. You structure and polish.

## 0. Read these before drafting

Always read these in parallel before writing a single word:

- `CLAUDE.md` — the "Adding a blog post" section has the canonical front matter format and slug rules.
- `Content/blog/*.md` — the existing posts. They are the live voice reference. Read at least two: one in the closest tone to whatever you're writing (technical Swift tutorial, essay, talk write-up).
- The source material Adam handed you. Use the `Read` tool on the PDF directly.

If Adam hasn't handed you any source material and you don't have a topic, ask. Don't guess.

## 1. Voice

The voice rules — British spelling, direct second person, no em-dashes, the delete-on-sight AI-tell list, the sentence-rhythm tells, and the patterns Adam mirrors — live in the **`adam-voice`** skill. Read it before you draft a single word; it's absolute, and a blog post is exactly the kind of prose it governs. The self-review lint in section 6 is also that skill's.

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

The `image:` references the **`.png`** (rasterized hero) — the SVG is the source, the PNG is what gets loaded in cards and OG/Twitter share previews. You write this line; the `blog-post-images` skill produces the file it points at. See section 4.

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

The visual assets — wide hero, square thumbnail, and any in-body diagram — are made by the **`blog-post-images`** skill, not here. Invoke it once the draft and slug are settled, handing over:

- the **slug**,
- the post's **central metaphor** (one sentence — what the hero should depict),
- a **distinctness constraint** if you know it ("recent posts were dark violet and cream, go bright/blue").

It produces and rasterizes all four committed files (`<slug>.svg`/`.png` at 1200×630, `<slug>-thumb.svg`/`.png` at 600×600) under `Resources/assets/images/posts/`, plus any body diagram you ask for (SVG-only).

What stays your job:

- The front-matter `image:` line points at the **wide PNG** (`<slug>.png`). You write that line; the image skill produces the file.
- If the image skill hands back a body-diagram markdown line, drop it into the post body where it belongs.

## 5. Drafting workflow

1. Read the source material Adam provided.
2. Pick a tone target by reading one existing post in the closest format (technical → `map-filter-reduce.md`; essay → `when-ai-forgets-wonder.md`; talk write-up → `canon-tdd.md` or `existential-and-opaque-types.md`).
3. Decide a slug and a date.
4. Draft the post in one pass. Use `##` and `###` for sections. Include code samples verbatim from the source where they exist. Don't pad.
5. Invoke the `blog-post-images` skill with the slug and the post's central metaphor (see section 4). It generates and rasterizes the hero, thumbnail, and any body diagram. Then set the front-matter `image:` to `/assets/images/posts/<slug>.png`.
6. Pick the tags. Reuse before inventing.
7. Run the self-review pass (section 6).
8. Build to verify: `rm -rf Output && swift run AdamYoungSite`. Confirm the post appears on the home page and on `/blog/`.
9. Show Adam the result. Do not commit. Do not push. He'll review.

## 6. Self-review pass

Run the **`adam-voice`** de-AI lint against the draft (`Content/blog/<slug>.md` is the `<file>`): the em-dash, en-dash, and AI-tell `grep` checks, plus the two end-to-end read questions (does the first paragraph sound like Adam; is the closing line substantive). Don't show Adam a draft until all checks pass.

## 7. Hard rules — never do these

- **Don't invent claims, opinions, statistics, examples, or quotes that aren't in the source.** If the source says "I gave a talk on X", don't add "and the audience loved it". If a code snippet isn't in the source, don't fabricate one to fill space. If you genuinely need an example to make a point land, ask Adam for one.
- **Don't add a "Conclusion" or "Summary" or "Overview" heading.** A natural closing paragraph is enough. A TL;DR section at the end is allowed if the post is long enough to genuinely benefit from one.
- **Don't add placeholders** like `[insert example here]` or `TODO`. If you're missing content, ask before drafting.
- **Don't push or commit.** Draft the post, build to verify, stop. Adam reviews and tells you what's next.
- **Don't second-guess the source's content.** If Adam said something in his talk, treat it as load-bearing. Restructure the order if it helps the post flow, but don't argue with the substance.

## 8. When in doubt, ask

The skill exists to save Adam time on structure and polish, not to second-guess his content. If the source is ambiguous, ask one focused question rather than guessing. One question is fine. A multi-question audit is annoying.
