---
title: From Plan to PR: A Delivery Pipeline Built from Claude Code Skills
date: 2026-06-18 12:00
description: How I built an autonomous delivery pipeline from Claude Code skills: an approved plan to a ready-to-merge PR, one human gate, and a loop that improves itself.
tags: ai, claude code, automation, agents
image: /assets/images/posts/claude-code-delivery-pipeline.png
---

There are two ways people tend to use an AI coding agent, and I don't much like either of them.

The first is to babysit it. You sit there approving every edit, re-reading every diff, nudging it back on track. It works, but you've not really bought yourself much. You're a very expensive pair of eyes.

The second is to let go entirely. "Build me the feature." You come back to a 40-file diff, no tests worth the name, and a creeping suspicion that you now own code you've never read. That works right up until it doesn't, and when it doesn't, you're the pilot who hasn't flown manually in years.

I wanted a third thing. I wanted the agent to have a *workflow*. Not a vibe, not a one-shot prompt, but the same disciplined pipeline I'd run by hand on a good day, encoded once and run every time. So I built one for my [TMDb Swift package](https://github.com/adamayoung/TMDb), out of [Claude Code](https://claude.com/claude-code) skills. (A skill, if you've not met them, is a reusable instruction set you invoke with a slash command; one skill can spin up subagents that do work in their own separate context and report a result back.) This is what it does and why it's shaped the way it is.

## Where this came from

I didn't sit down one morning and decide to build a delivery pipeline. I backed into it.

Claude Code has an `/insights` command that generates a report analysing your recent sessions, how you've actually been using it. I ran it over nineteen days of work on this package and handed the report back to Claude for an honest read. It was honest. It liked the adversarial review (agents whose whole job is to disagree with each other) and the cross-session memory. It was less kind about the friction: a habit of guessing before verifying (change the CSS, *then* measure, in that order), work landing in the wrong repo or at the wrong scope, and one genuinely embarrassing afternoon where a JSON payload arrived as a string instead of an object, got iterated character by character, and spun up 281 junk subagents before I noticed. Those were the failures I was catching by hand, after the fact.

## A ladder to ten

Then, because I asked it to, Claude laid out a scale for how people actually use Claude Code, one to ten, and placed me on it. Lightly trimmed, here's the ladder. Don't worry if the upper rungs read as alphabet soup; the ideas that actually matter to the rest of this post get unpacked as we go.

<div class="table-wrap">
<table>
<thead>
<tr><th style="width:30%">Level</th><th>What it looks like</th></tr>
</thead>
<tbody>
<tr class="tier-row"><td colspan="2">Beginner</td></tr>
<tr><td><strong>1.</strong> One-shot questions</td><td>Single questions in chat. No follow-up, no project awareness.</td></tr>
<tr><td><strong>2.</strong> Basic code editing</td><td>Editing individual files by copy-paste, asking for fixes. No tool use.</td></tr>
<tr class="tier-row"><td colspan="2">Intermediate</td></tr>
<tr><td><strong>3.</strong> Multi-file awareness</td><td>Letting Claude read and edit across a codebase, and find the right files itself.</td></tr>
<tr><td><strong>4.</strong> Shell commands &amp; iteration</td><td>Letting it run build, test and lint and loop through the errors. <code>CLAUDE.md</code> starts to appear.</td></tr>
<tr><td><strong>5.</strong> Task delegation</td><td>Handing over whole tasks, using git through Claude, knowing when to trust the output and when to review.</td></tr>
<tr class="tier-row"><td colspan="2">Advanced</td></tr>
<tr><td><strong>6.</strong> Custom skills &amp; prompts</td><td>Reusable skills for repeated workflows, working around token limits, the first MCP servers.</td></tr>
<tr><td><strong>7.</strong> Autonomous PR workflows</td><td>Full branch-to-merge cycles: CI verification, conflict resolution, SemVer calls, multi-session context, parallel worktrees.</td></tr>
<tr class="tier-row"><td colspan="2">Expert</td></tr>
<tr><td><strong>8.</strong> Adversarial orchestration</td><td>Multi-agent systems: one implements, another reviews adversarially, a third watches CI and merges. Composable skills, MCP-backed knowledge across sessions.</td></tr>
<tr><td><strong>9.</strong> Self-maintaining systems</td><td>Pipelines that monitor themselves and adapt. CI triage agents that auto-resolve failures. Knowledge bases that update every session. Hooks on lifecycle events. Claude mostly runs in the background.</td></tr>
<tr><td><strong>10.</strong> Full autonomous operator</td><td>Claude as a persistent background system, not a tool you invoke. Agents delegate to sub-agents, self-heal, hold their own state, and surface only novel decisions. You set the direction; it handles the rest.</td></tr>
</tbody>
</table>
</div>
<p class="table-note">The ladder above was produced by Claude.</p>

It put me at 8, which was generous. The part that stuck was its reason I wasn't a 9:

> You're still the orchestrator who kicks things off and intervenes when something goes wrong. A true 9 would have those failure modes caught and handled automatically before you ever see them, baked in as standing infrastructure rather than lessons from the postmortem.

That's the sentence that started this. *Standing infrastructure, not postmortem lessons.* The 281-agent afternoon is now a one-line guard at the top of the script: if the payload came in as a string, parse it back before you touch it. The lint-caught-late loop is now a hook (a script that fires automatically on an event) that runs the formatter on every file edit. And the bigger gap, the workflow noticing its own rough edges and fixing them without me playing nurse, is the pipeline the rest of this post is about.

## It starts in plan mode

Before any of the pipeline runs, there's a plan, and the plan is where the real thinking happens. I build it in Claude Code's [plan mode](https://code.claude.com/docs/en/permission-modes#analyze-before-you-edit-with-plan-mode), and I don't open with "implement X". I open with a user story:

```text
As a <type of user> I want <feature> so that <reason>

Acceptance criteria:
- ...

Any extra context:
- ...
```

Then one instruction that pulls more weight than it looks: **ask me at least three clarifying questions before you write the plan.**

That's the part that does the work. A user story is meant to be a little vague (that's what makes it a story and not a spec), and the gap between what I wrote and what I actually meant is exactly where bad features come from. Forcing the questions drags that gap into the open before a single line of the plan exists. What should happen when the list is empty? Breaking change, or additive? Does it need to work on Linux? I answer, it revises, I push back, it asks again. We go round until the plan reflects what I want, not what I first typed.

Only when the plan is ready do I hand it to `/deliver`. The questioning starts *before* the plan exists, not after the code does, so by the time the pipeline runs the ambiguity is already gone.

## One command, one gate

`/deliver` takes that approved plan and carries it all the way to a pull request that's green and ready to merge:

<div class="flow">
<div class="flow-step flow-you"><span class="flow-skill">you</span><span class="flow-label">approve the plan (invoking <code>/deliver</code> is the approval)</span></div>
<div class="flow-step"><span class="flow-skill">branch</span><span class="flow-label">a feature branch off <code>main</code></span></div>
<div class="flow-step"><span class="flow-skill">/review-plan</span><span class="flow-label">three critics harden the plan (risky changes only)</span></div>
<div class="flow-step"><span class="flow-skill">/implement-plan</span><span class="flow-label"><a href="/blog/canon-tdd/">Canon TDD</a> until the test list is empty</span></div>
<div class="flow-step"><span class="flow-skill">/review-changes</span><span class="flow-label">code review, then fix every finding test-first</span></div>
<div class="flow-step"><span class="flow-skill">/capture-knowledge</span><span class="flow-label">record what the delivery taught</span></div>
<div class="flow-step"><span class="flow-skill">/pr</span><span class="flow-label">the full CI gate, then open the pull request</span></div>
<div class="flow-step flow-gate"><span class="flow-skill">/watch-pr</span><span class="flow-label">resolve threads, fix checks, green and <strong>ready to merge</strong> (the one hard stop)</span></div>
<div class="flow-step flow-you"><span class="flow-skill">you</span><span class="flow-label">review the PR, then merge, the one call the pipeline hands back</span></div>
<div class="flow-step"><span class="flow-skill">retro</span><span class="flow-label">what worked and what didn't, folded back into the skills</span></div>
</div>

The important word is *one*. Invoking `/deliver` on the approved plan **is** the approval. From that point it runs to a single *planned* stop: the PR is ready, and I read the diff and merge it. No "is the plan ok?" twice, no stopping to ask permission to run the tests. It will still interrupt for a genuine blocker (a plan critic judging the whole approach harmful, or a CI failure it can't safely triage), but those are the exceptions, not the rhythm. One routine gate, and a lot of disciplined work either side of it.

That single gate is deliberate, and I'll come back to why at the end. First, the parts.

## Skills that compose, not one skill that does everything

The temptation with something like this is to write one enormous prompt that tries to do the whole job. I went the other way. `/deliver` doesn't implement review, or TDD, or PR logic. It's a conductor. It sequences skills that already exist and each do one thing well:

- `/review-plan` pressure-tests the plan.
- `/implement-plan` writes the code, test-first.
- `/review-changes` reviews the diff.
- `/capture-knowledge` records what was learned.
- `/pr` runs the full CI gate and opens the pull request.
- `/watch-pr` babysits it to green.

Each of those is useful on its own. I can run `/review-changes` on a branch I wrote by hand, or `/watch-pr` on a PR that has nothing to do with the pipeline. `/deliver` just knows the order to call them in and where the safety gates go. The expertise lives in the pieces; the orchestrator stays small. That separation is the single best decision in the whole thing, because it means I can improve one skill without touching the other six.

## It scales itself to the risk

Not every change deserves the full machinery. A two-line README fix and a new concurrency-sensitive service are not the same animal, and reviewing them the same way is either overkill or negligence depending on which one you picked.

So `/deliver` judges the weight of the change up front, and re-confirms it from the actual diff once the code exists. A small, mechanical change with no risky surface (no concurrency, no networking, no decoder changes, no new public API) takes the *lite* path: skip the heavy plan review, use a single code reviewer. Anything risky or large (new concurrency, a new service, a broad diff) gets the *full* treatment. When it's unsure, it picks full, because the heavier review is cheap insurance against exactly the changes that bite.

The nice property here is that I never pass a flag; the pipeline reads the change and decides, the way I would. It can read one wrong, of course, a change that looks mechanical but quietly touches a decoder or a concurrency boundary, so the weight is a default rather than a verdict: it gets re-checked against the real diff once the code exists, and the tie-break is always to prefer full when unsure.

## Adversarial by default

Here's the part I'm most pleased with. At two points in the pipeline, the work is reviewed by agents whose entire job is to *disagree*.

When the plan matters, `/review-plan` fans out three independent critics in parallel, each pinned to a strong model at high reasoning effort, each given a different lens:

- **Correctness and completeness**: does this plan actually achieve the goal?
- **Risk and failure modes**: assume it ships and something breaks. What?
- **Simplicity and fit**: assume it does too much, the wrong way.

Each critic is told to assume the plan is flawed and hunt for the strongest objection. A critic that finds nothing has to say so explicitly *and* justify why each common failure mode doesn't apply. They can't just nod. And every finding has to cite a real file or constraint, because an objection that can't be tied to the actual code is noise.

> A plan that survives three hostile reviewers is worth implementing. A plan that nobody challenged is just the first idea that came to mind.

The same instinct runs through code review. On a large change, `/review-changes` spawns one reviewer per dimension (correctness, concurrency, architecture, testing, API and docs), then does something I think is the real trick: every Critical or High finding is handed to a *separate* skeptic whose job is to refute it. The prompt is blunt about which way to lean:

```text
Try to REFUTE it. Read the actual code and decide whether the issue is
REAL and in scope for THIS change. Default to real=false if it is
theoretical, already handled elsewhere, out of scope, or a misreading
of the diff. Be strict.
```

Anything that doesn't survive the refutation gets dropped before it ever reaches me. The number of findings killed that way isn't a gap in the review, it's the point of it. A reviewer biased towards finding problems plus a verifier biased towards dismissing them is a much better signal than either one alone.

## Test-first, all the way down

I've [written before](/blog/canon-tdd/) about Canon TDD and why the test list is the part that does the work. The pipeline takes that seriously, and not just during the initial build.

`/implement-plan` derives a test list (the set of behaviours the change has to cover), shows it to me before writing any code, and drives the red-green-refactor loop one test at a time until the list is empty and the suites are green. Fine, that's just TDD. The bit I like is what happens *after* review. When a code reviewer finds a real defect, the fix isn't a quiet patch. It's a failing test that captures the defect, then the fix, then a re-run. No untested patches sneak in under the banner of "just a quick fix". The discipline doesn't relax once the feature works; it's how every change gets made, including the corrections.

This has already earned its keep in a way I can point at. On one genuinely risky change, the three plan critics *unanimously* caught three blockers before a single line was written: adding methods as public-protocol requirements would have broken anyone who'd conformed to the protocol externally; sixteen pagination methods had been left out of scope; and deprecating the old call sites would have cascaded compiler failures through the package's own internal callers. That reversed my own "deprecate and add" instinct into a clean, additive design. The fan-out review then found nine pagination forwards with no test coverage. The change shipped with 2,700 unit tests and an architecture decision record explaining why. None of that came from me being clever in the moment. It came from the workflow refusing to skip steps.

## Keep the conductor lean

A subtle thing that took me a couple of iterations to get right: the orchestrator should hold almost nothing.

`/deliver` is a long-running session. If it carried the full output of every plan critique, every code review, and every test log in its own context, it would be bloated and slow by the time it reached code review, and useless by the time it was watching the PR. So the heavy or independent work is pushed out into subagents on purpose. The three plan critics run in their own workflow and only their verdicts come back. The code reviewer reads the diff in its own context. The build, test, and lint steps hand their noisy logs to a small, cheap model and return a one-line result.

The conductor keeps the plan reference, a phase ledger, and a short summary from each step. Everything else is handed off through git, the disk, or the PR, not through context. The result is an agent that can run a long pipeline without drowning in its own logs, and that can pick up cleanly if the session gets summarised halfway through.

One deliberate exception: the implementation step runs inline, in the main context, so the test list and each red-green step stay *visible* to me. I could have hidden it in a subagent for tidiness. I didn't, because watching the tests go red then green is the bit I actually want to see.

## Don't stall on someone else's flake

Real pipelines meet red CI that isn't their fault. A live integration test against a third-party API picks a bad moment and fails. The naive pipeline stops dead and waits for a human, and now your delivery is blocked on a flake that has nothing to do with your diff.

So before `/deliver` stops on a red gate, it triages. Is the failing check actually in your diff? If yes, it's yours: reproduce it with a failing test, fix it, re-run. If the failing test isn't in your change and tends to pass on a re-run, it's a problem with the main branch, not with you. That gets routed off to a separate skill that fixes the flake on its own branch, merges it, and brings your branch up to date, and then the gate runs again. Only a genuine, in-diff, unfixable break actually stops the pipeline. Someone else's bad luck doesn't.

## The one gate, and why it's human

Back to that single hard stop. The pipeline will do everything up to a green, ready-to-merge PR, and then it stops and hands it back to me to read and merge. By default it does not merge itself. That handing-back is the point, not a formality: the gate is where I actually review the change, end to end, instead of rubber-stamping whatever came out the other side. Green checks are necessary, not sufficient. A test suite that passes can still be the wrong design, and the only way I'd know is to read it.

That's not because the machine *couldn't* merge. It can: there's a one-word flag that tells `/deliver` to squash-merge the moment the PR goes green, and an unattended mode where a panel of subagents makes the calls I'd normally make and it runs the whole thing end to end. I just don't switch those on. Reviewing the change and deciding it ships is the one call I want to keep. I've [argued before](/blog/when-ai-forgets-wonder/) that the model I believe in is AI as Tony Stark's JARVIS: it runs the simulations, surfaces the options, does the legwork, and the human decides what matters. A pipeline that planned, built, reviewed, and merged entirely on its own would be the glass cockpit all over again. Looks competent, right up until the day it merges something I'd never have shipped, and I've long since lost the feel for the code.

So the machine does the disciplined, repeatable, tedious work it's genuinely better at than a tired human at 5pm. And the judgement call, reading the change and choosing to put it into the main branch, stays mine. One gate.

## The part that rewrites itself

The last phase is the one I didn't expect to care about as much as I do. Every delivery ends with a short, honest retrospective written to a file in the repo: what worked, where it was rough, anywhere I had to depart from the workflow to do the right thing, and the single highest-value improvement this run suggested.

On its own, that's just a diary. The interesting bit is what happens next. After writing the retro, the pipeline reads *all* the past retros and looks for friction that shows up in more than one of them. When the same complaint recurs, it writes a concrete proposal: here's the pattern, here are the deliveries it appeared in, here's the exact skill file and the exact wording I'd change, and why. Then it stops and asks me to approve each one, and records every decision (applied, deferred, or rejected, with the reasoning) in a log so it never re-proposes a settled call.

This isn't theoretical. Most of the pipeline's better features were born this way:

- The red-gate triage I described above didn't exist at first. A flaky integration test stalled a delivery, the retro flagged it, the pattern recurred, and the fix went into the skill.
- The lite-versus-full auto-scaling came out of a retro noting that a heavyweight review was overkill for a mechanical change.
- A rule to treat code-review *findings* as hypotheses and verify them against the actual code before acting came from three separate deliveries where a finding turned out to be mis-framed, including one outright false positive that the test-first discipline caught before any change was made.

So the workflow that delivers my features also, slowly, improves the workflow. That's the climb Claude was pointing at: the gap from an 8 to a 9 was failures becoming standing infrastructure instead of postmortems, and this is where that happens. But I've stopped one rung short on purpose. A 9, the way the ladder describes it, mostly runs in the background; a 10 surfaces only the novel decisions. Mine doesn't get the last word. It's honest about its own rough edges and proposes its own fixes, and then it waits for me to say yes.

That, in the end, is what I was actually after. Not an AI that builds things for me while I'm not looking. A discipline I believe in, written down once, run every time, and getting a little sharper with each delivery, while the decisions that matter stay where they belong.

If you want to poke at the actual moving parts, it's all open source. `/deliver` and the rest of the skills it orchestrates live under [`.claude/skills/`](https://github.com/adamayoung/TMDb/tree/main/.claude/skills) in the [TMDb package](https://github.com/adamayoung/TMDb), next to the `knowledge/` base they write their retrospectives into. Take a look, borrow whatever's useful, and tell me what you'd build differently.
