---
title: Canon TDD: How I Learned to Stop Worrying and Love Writing Tests
date: 2026-01-21 12:00
description: Red, Green, Refactor is the part of TDD everyone remembers, and the bit Kent Beck keeps having to remind us isn't the whole workflow. Notes from a recent talk.
tags: tdd, testing
image: /assets/images/posts/canon-tdd.svg
---

![Diagram showing the Canon TDD flow: a Test List feeding into a Red, Green, Refactor cycle that loops until the list is empty](/assets/images/posts/canon-tdd.svg)

I gave a talk recently called *Test-Driven Development — or, how I learned to stop worrying and love writing tests*. This is a written-up version of it.

If you've been around long enough you've probably had TDD pitched at you as three words: **Red, Green, Refactor**. Write a failing test, make it pass, tidy up. Repeat. Easy.

It's a great mnemonic. It's also incomplete, and the bit it leaves out is the bit that does most of the work.

## Why bother with TDD at all?

Before getting into the *how*, the *why* is worth a minute. TDD isn't there because someone in the 90s thought you should write more tests. It's there because it gives you a workflow that:

- Helps you understand the new behaviour you're trying to implement, *before* you implement it.
- Lets you see clearly what a unit of behaviour should achieve.
- Lets you code in safer steps.
- Helps you detect bugs and their causes as you go, instead of weeks later.
- Aids implementation design, without dictating it.
- Tends to result in cleaner, tidier code.
- Lets you refactor confidently, knowing you aren't quietly breaking existing behaviour.

That last one is the one I keep coming back to. The whole game, in the end, is being able to *change a system with confidence*.

Kent Beck (who literally invented TDD) puts it more crisply. TDD aims to leave you in a state where:

> Everything that used to work still works. The new behaviour works as expected. The system is ready for the next change. And the programmer (and their colleagues) feel confident in all of the above.

That last clause is the quiet one, but it's the whole point.

## The version everyone knows

Most people, if you ask them what TDD is, will draw you the loop:

1. **Red**: write a failing test.
2. **Green**: make it pass with minimal code.
3. **Refactor**: tidy up.

Loop forever.

This is fine. It's also where it usually goes wrong, because it skips the most important step.

## Canon TDD

In 2024 Kent Beck wrote a piece called [*Canon TDD*](https://tidyfirst.substack.com/p/canon-tdd) (partly, I suspect, because he was tired of seeing people argue about a watered-down version of his own thing). It lays out the actual workflow. It is five steps, not three.

Before the steps, there's a useful split to keep in mind: **interface vs implementation**. The interface is *how a particular piece of behaviour is invoked*. The implementation is *how the system fulfils that behaviour*. TDD wants you to make those decisions at different times, on purpose.

### 1. Write a test list

Given a system and a desired change in behaviour, list all the variants of the new behaviour you're expecting.

This is the step everyone wants to skip. Don't.

If you launch straight into coding, you'll never know when you're done. The test list is what tells you.

Think about all the cases the new behaviour should cover. If it occurs to you that some change shouldn't break existing behaviour, write that down too. That's also a case.

What you should *not* do here is mix in implementation decisions. Don't write "use a hash map" on the list. There'll be time for that later. Right now you're enumerating *what* the system should do, not *how*.

### 2. Write a test

One test. A real, automated test, with setup, invocation, and assertions. Arrange/Act/Assert, or Given/When/Then, whichever flavour you like.

Picking *which* test to write next is a real skill, and the order can affect both the experience of writing the code and the shape of what you end up with. A pro-tip from Beck: try working backwards from the assertions sometimes. It forces you to be clear about what "done" looks like for that case.

In writing the test, you'll start making design decisions. That's expected. The trick is that they should be **interface** decisions (what's it called, what does it take, what does it return) and *not* implementation decisions. The test shouldn't know how the implementation will work.

#### Common mistakes

- **Writing tests without assertions, just to get coverage.** A test without an assertion isn't a test, it's a smoke alarm with the batteries out.
- **Turning the entire test list into concrete tests up front, then making them pass one by one.** This sounds productive. It isn't. The first test you make pass will probably make you reconsider a decision that affects all the others. Congratulations, you now have five tests to rewrite. And if you get to test 6 and nothing passes yet, you'll be bored and demoralised. Both of these are avoidable by writing one test at a time.

### 3. Make it pass

Now you have a failing test. Change the system to make it pass.

If you discover, while doing this, that you need a new test, add it to the list. (If that new test invalidates work you've already done, that's a sign you should start over with a different ordering.)

When the test passes, mark it off the list. Run all the previous tests to make sure they still pass.

#### Common mistakes

- **Deleting an assertion so the test pretends to pass.** Don't. Make it pass for real.
- **Copying the actual computed value out of the test failure and pasting it in as the expected value.** This defeats the double-checking that creates most of the validation value of TDD. You're meant to know what the answer should be *before* the code runs.
- **Mixing refactoring into making the test pass.** Make it run, *then* make it right. Dirty code is fine here. The next step exists for a reason.

### 4. Optionally refactor

*Now* you make implementation design decisions. Tidy the code. Remove duplication. Improve names. Make sure all your tests still pass while you do it.

#### Common mistakes

- **Refactoring further than necessary for this session.** Even when it feels good. Make a note, come back during a "tidy session". Especially: ask yourself whether you're refactoring because the code needs it, or because you don't yet know how to make the next test pass. Those are very different problems.
- **Abstracting too soon.** Duplication is a *hint* to abstract, not a *command*. Not all duplication is bad. The premature abstraction will be wrong, and undoing it will cost more than the duplication did. YAGNI (You Aren't Gonna Need It) earns its keep here.

### 5. Repeat

Until the test list is empty, go to step 2.

## The whole thing, on one page

![Canon TDD flowchart: Start → Step 1 (Write a list of test scenarios) → Step 2 (Turn one item into a runnable test) → Step 3 (Make it pass) → Step 4 (Optionally refactor) → decision: is the list empty? Yes ends; No loops back to step 2. A dashed arrow loops from Step 3 back to Step 1 labelled "discover the need for a new test". Common mistakes are annotated at each step.](/assets/images/posts/canon-tdd-flowchart.svg)

## So what's the actual difference?

You can do Red-Green-Refactor as a tight cycle of three things and still make every mistake above: chase coverage with assertion-less tests, refactor in the wrong step, abstract too early, fudge the assertion to make it green. The reason Canon TDD is five steps and not three is that the **Test List** is the bit that turns it from "test, then code" into a *deliberate workflow*.

It's the bit that:

- Forces you to understand the behaviour before you start.
- Gives you a definition of done.
- Lets you pick the next test deliberately, instead of whatever's nearest to your cursor.
- Catches the realisation that you need a new case *while* you're working, instead of three days later.

Red-Green-Refactor is the engine. The Test List is the steering wheel.

## Closing thought

If you only take one thing from any of this, take this: before you write the test, write the list.

[Kent Beck's original](https://tidyfirst.substack.com/p/canon-tdd) is short and worth your time.
