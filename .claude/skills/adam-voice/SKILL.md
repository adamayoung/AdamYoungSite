---
name: adam-voice
description: The canonical guide to Adam's writing voice and the de-AI lint that enforces it — British spelling, direct second person, no em-dashes, a delete-on-sight list of AI tells, and sentence-rhythm rules. Use it whenever you write or polish prose meant to sound like Adam (blog posts, READMEs, talk abstracts, release notes, LinkedIn posts, emails), and run its checks before showing him anything. blog-post-writer composes this skill. Triggers: "make this sound like Adam", "de-AI this", "check the voice", "run the AI-tell lint", "/adam-voice".
---

# adam-voice

This is the canonical guide to how Adam writes, and the mechanical lint that catches the ways drafts drift away from it. Read it before writing any prose in his voice, and run section 2's checks before showing him a draft. It applies to anything — a blog post, a README, a talk abstract, release notes, a LinkedIn post, an email. The blog-specific structure lives in `blog-post-writer`; the voice lives here.

If a draft violates a section 1 rule, fix it before showing Adam.

## 1. Voice rules — these are absolute

### Spelling and address

- **British spelling.** behaviour, organise, recognised, colour, optimise, fulfilment, defence, analyse, programme (the noun), travelled. Don't "translate" code or library names.
- **Direct second person.** Use "you" for the reader. Use "we" inclusively (you and the reader doing something together). Never "one" or "the developer" or "users". It should feel like Adam is talking to one person across a desk.
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

Add to this list whenever Adam flags a phrase he hates. When you add a word here, add it to the section 2 regex too so the lint stays in sync.

### Sentence rhythms to break

- **Tricolons.** Three-item parallel lists ("fast, reliable, and scalable") in a row are an AI signature. Drop one item or vary the structure.
- **"Not just X, but Y."** Once per piece is fine. Twice is a tell.
- **Hedging stacks.** "While it's true that, in many cases, one might…". Just say it.
- **Closing meta-commentary.** End on a substantive sentence, not a wave goodbye.

### Patterns Adam uses that you should mirror

(Observed from his blog. Confirm by reading his existing posts when the piece is a blog post.)

- Opens with a hook: a personal moment, a quote, a contrarian one-liner. Never a definition.
- Code examples for technical pieces, often with progressive simplification (the long-form closure → `{ $0 * 2 }` style).
- Blockquotes for things he's actually quoting (Henry Ford, Kent Beck), not for tips or callouts.
- Conversational headings ("So what's the actual difference?", "Where does `some` come into it?"), not corporate ones ("Conclusion", "Overview"). In longform, H2s are major beats and H3s are sub-points within a beat.
- Acknowledges common confusions out loud ("yeah yeah yeah, I know what TDD is").
- Closes with a link to the source material when riffing on someone else's idea.

## 2. The de-AI lint — run before showing Adam

Run the literal checks against the file you're polishing. Replace `<file>` with the path (e.g. `Content/blog/<slug>.md`, `README.md`):

```bash
# em-dashes — must be zero
grep -c '—' <file>

# en-dashes used as em-dashes — must be zero
grep -c '–' <file>

# AI tells — must return nothing
grep -iE '(\bdelve|\bleverage|\brobust\b|\bcrucial\b|\bcomprehensive\b|\btapestry|\brealm\b|\bembark\b|\bfoster\b|\bunleash\b|\bstreamline\b|\bholistic\b|\bsynergy|\bgame-?chang|\bcutting-edge\b|\bstate-of-the-art\b|\bharness the\b|\bunlock the potential\b|\bnavigate the\b|\bmyriad\b|\bplethora\b|\bfacilitate\b|\butilise\b|\butilize\b|\bensure that\b|in today.s|moving forward|at the end of the day|underscore|in this blog post|hope (this|you))' <file>
```

If any check returns a hit, rewrite the offending sentence and re-check. Don't show Adam a draft until all checks pass.

Then read the piece end to end with two questions:

- Does the first paragraph sound like Adam, or like ChatGPT? If the latter, redo it.
- Is the closing line a substantive sentence, or a "hope this was useful" wave-goodbye? The latter gets cut.
