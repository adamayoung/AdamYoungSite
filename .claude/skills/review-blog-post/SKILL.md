---
name: review-blog-post
description: Review a draft blog post for adam-young.co.uk from two independent angles — a Staff iOS engineer (senior-credibility) and a mid-level iOS engineer (does-this-teach) — and return one merged, deduplicated report. Use when Adam wants a substance/audience review of a post before publishing, after blog-post-writer has drafted it. Triggers: "review this post", "review the blog post", "get the reviewers on it", "/review-blog-post".
---

# review-blog-post

Run two independent reviews of a draft blog post and merge them into one report Adam can act on. The two reviewers judge **substance and audience reception**, not prose voice — voice is the `adam-voice` skill's job, and the reviewers are told to defer to it.

## 0. Find the draft

You'll be given a slug, a path, or nothing:

- **Slug** (`clean-architecture`) → the file is `Content/blog/<slug>.md`.
- **Path** → use it directly.
- **Nothing** → if there's an obvious in-progress draft (the most recently modified file under `Content/blog/`, or the one just written this session), use it and say which. Otherwise ask which post.

Confirm the file exists before spawning anyone.

## 1. Spawn both reviewers in parallel

Launch the two agents **in a single message** (two tool calls) so they run concurrently and — more importantly — in **isolated contexts**. They must not see each other's notes; the whole point is two independent reads, not one persona-switching pass.

- `staff-ios-reviewer` — the senior-credibility lens (claim defensibility, earned opinions, glossed edge cases, the embarrassment test, code correctness).
- `midlevel-ios-reviewer` — the does-this-teach lens (assumed prerequisites, unexplained jargon, followable examples, where a learner gets lost).

Hand each the same thing: the draft's path (and slug). Each returns a structured markdown review with a verdict, strengths, and severity-grouped issues.

## 2. Merge the two reviews

Produce **one** report, not two stapled together:

1. **Two verdicts up top.** Show both reviewers' one-line verdicts side by side (`Staff: Ship with fixes` / `Mid-level: Lands with gaps`), so Adam sees both audiences at a glance.
2. **Strengths**, briefly merged. If both praised the same thing, say it once.
3. **Issues, deduplicated and severity-ordered.** Walk both lists:
   - Where **both reviewers raised the same point**, merge into one entry and mark it **`[both]`** — that's the strongest signal and goes first within its severity.
   - Otherwise tag each entry with its source — **`[staff]`** or **`[mid]`** — so Adam knows whose lens it came from.
   - Keep each reviewer's severity. If they disagree on severity for the same merged point, take the higher and note the split.
   - Preserve the section/quote anchor and the concrete fix from the original.
4. **Voice pointers**, collected. Any "→ voice" notes either reviewer made get gathered into one line that says: run the `adam-voice` lint. Don't expand them — that's the other skill's job.

Order issues: `[both]` High → `[staff]`/`[mid]` High → Medium → Low.

## 3. Hand back

Present the merged report to Adam. Do **not** edit the draft, commit, or push — these are notes, he decides what to act on. End with a one-line bottom line: given both lenses, is this ready, ready-with-fixes, or needs another pass.

## Boundaries

- The reviewers are read-only and so are you here — produce notes, change nothing.
- Substance and audience only. If the merged report is light because the only problems are voice/style, say that and point at `adam-voice` rather than padding.
- Don't average the two reviewers into mush. Their disagreements are signal — a thing the Staff reviewer loved and the mid-level reviewer found impenetrable is exactly what Adam needs to see, so keep both.
