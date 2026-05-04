---
title: Existential and Opaque Types in Swift
date: 2026-05-04 14:00
description: any vs some — what they actually mean, why one of them is a box you have to open, and when to reach for which. With pizza.
tags: swift, generics, existential types, opaque types
image: /assets/images/posts/existential-and-opaque-types.svg
---

![A diagram contrasting 'any' (a closed pizza box that could hold any pizza) with 'some' (a single specific pizza whose flavour is hidden from the caller but known to the compiler)](/assets/images/posts/existential-and-opaque-types.svg)

`any` and `some` are two of the more frequently squinted-at keywords in modern Swift. They look interchangeable. They are not. This is a written-up version of a talk I gave on the difference, with the pizza analogy intact, because who doesn't love pizza.

A couple of pre-requisites: a working idea of what protocols and generics are. Good? Good.

## The two terms

An **existential type** is, roughly: *"any type, but conforming to protocol X."* In Swift it's spelled `any X`.

An **opaque type** is, roughly: *"the expected type, without naming a concrete one."* In Swift it's spelled `some X`.

Those two definitions sound almost identical when you read them quickly. The difference is in what the *compiler* does with each one — and that has real consequences for performance, for what code you can write, and for what the compiler will and won't let you do.

Let's set up the example.

## A pizza protocol

```swift
protocol Pizza {
    var name: String { get }
    var size: Int { get }
}
```

Imagine a function that takes a pizza:

```swift
func receivePizza(_ pizza: Pizza) {
    print("Yum, I love \(pizza.name).")
}
```

When this function is called, `pizza` is what's known as a **box type** — an *existential container*. To get to the `name` property, Swift has to open the box at runtime, find the concrete object inside that conforms to `Pizza`, and then read `name` off it.

That's not free. Existentials defeat most compile-time optimisation. The function does what you'd expect, but it's more expensive than it could be.

Now look at this:

```swift
func receivePizza<P: Pizza>(_ pizza: P) {
    print("Yum, I love \(pizza.name).")
}
```

Almost identical at a glance. Completely different in what's actually happening. Here `Pizza` isn't being used as a *type* — it's a *constraint* on the generic parameter `P`. The compiler resolves `P` at compile time, so `receivePizza` ends up receiving a concrete instance of a known type. No box. No runtime opening.

This is the part of Swift that bites people: those two function signatures look like they do the same thing. They don't.

## Enter `any`

Because the difference between "type" and "constraint" was so easy to miss, the Swift team introduced the `any` keyword. It doesn't add new functionality — it just forces you to *say* "this is an existential":

```swift
func receivePizza(_ pizza: any Pizza) {
    print("Yum, I love \(pizza.name).")
}
```

The generic version (`<P: Pizza>`) doesn't need `any`, because in that version `Pizza` is being used as a constraint, not as an existential.

You're probably already using `any` without writing it:

```swift
// These two are the same:
func receivePizza(_ pizza: Pizza) { … }
func receivePizza(_ pizza: any Pizza) { … }
```

The compiler currently fills it in for you. In the near future it'll be enforced, so you may as well start writing `any` now and be honest about what your code is doing.

## Where does `some` come in?

Look at the generic version again:

```swift
func receivePizza<P: Pizza>(_ pizza: P) {
    print("Yum, I love \(pizza.name).")
}
```

We declared `P` only because the function signature needs *something* to refer to the type by. We don't actually use `P` for anything else. `some` lets us drop that ceremony:

```swift
func receivePizza(_ pizza: some Pizza) {
    print("Yum, I love \(pizza.name).")
}
```

Read this as "this function takes some `Pizza`" rather than "this function takes some `Pizza` that we will call `P`." Functionally equivalent to the generic version. The compiler still resolves the underlying type at compile time and still optimises for it. It's just easier to write.

`some` is, essentially, syntactic sugar for a single-use generic parameter.

## The mental picture

If your eyes are glazing over, the talk had a slide that helps. (You're looking at a version of it at the top of this post.)

- **`any Pizza`** is a closed pizza box. The label says "pizza". You don't know which kind. To find out, you (or the runtime) have to open the box. The box can hold a pepperoni, a margherita, a hawaiian — *any* pizza that conforms to the `Pizza` protocol.
- **`some Pizza`** is one specific pizza. The compiler knows exactly which one — it can be a pepperoni, just one specific pepperoni — and it can optimise around that. *You*, as the caller, just know that what came back is "some pizza." The concrete type is hidden from you, but it's not hidden from the compiler.

That second point matters. `some` isn't "the compiler doesn't know either." `some` is "the compiler knows; you don't need to."

## A rule of thumb

> Prefer `some` (or generics) over `any`, whenever you can.

Most of the time you don't actually want a *box* that conforms to a protocol — you want the *object* that conforms to the protocol. `any` exists for the cases where you genuinely need the box (heterogeneous collections, dynamic dispatch through a stored property, that kind of thing). For everything else, `some` is cheaper and more honest about your intent.

## Where the rule bends: storing things

Take a `MusicPlayer` that needs an `AudioService`:

```swift
protocol AudioService {}

class MusicPlayer {
    private let audioService: AudioService

    init(audioService: AudioService) {
        self.audioService = audioService
    }
}
```

Per our rule of thumb, we'd reach for `some`:

```swift
class MusicPlayer {
    private let audioService: some AudioService   // ❌

    init(audioService: some AudioService) {       // ❌
        self.audioService = audioService
    }
}
```

But the compiler isn't having it:

> *Property declares an opaque return type, but has no initialiser expression from which to infer an underlying type.*

`some` on a stored property is opaque-return-type territory, and it needs to be backed by a single, statically-known underlying type. `init` taking `some AudioService` is a different `some` from `audioService: some AudioService` on the property — they don't match.

The fix is to mix them:

```swift
class MusicPlayer {
    private let audioService: any AudioService

    init(audioService: some AudioService) {
        self.audioService = audioService
    }
}
```

The init takes `some AudioService` — the caller gets the cheap, statically-resolved version. We then store it as `any AudioService`, accepting the box on the inside because we genuinely need to hold it across method calls without committing the property to one specific concrete type.

This pattern — `some` on the way in, `any` on the way to storage — is one of the most useful "in practice" rules in this whole topic.

## Pop quiz

The talk had two of these. They're worth doing in your head before reading the answer.

### One

```swift
var pizza: some Pizza = PepperoniPizza(size: 1)
pizza = HawaiianPizza(size: 1)
```

Compiles?

> ❌ No. The first line tells the compiler: "the underlying type of `pizza` is `PepperoniPizza`." The second line then tries to assign a `HawaiianPizza` to a `some Pizza` whose underlying type is locked in as `PepperoniPizza`. Different concrete type, doesn't fit.

### Two

```swift
let pizzas: [any Pizza] = [
    PepperoniPizza(size: 1),
    HawaiianPizza(size: 1)
]
```

```swift
let pizzas: [some Pizza] = [
    PepperoniPizza(size: 1),
    HawaiianPizza(size: 1)
]
```

Which compiles?

> ✅ The `[any Pizza]` one. The compiler only checks that each element conforms to `Pizza`; the array can mix concrete types because each element is a box.
>
> ❌ The `[some Pizza]` one fails. `some Pizza` collapses to *one* underlying type at compile time — the compiler can't pick between `PepperoniPizza` and `HawaiianPizza`, and it'll tell you so with a "conflicting arguments to generic parameter" error.

This is the cleanest illustration of the difference. `any` lets you have a heterogeneous collection because every box is the same kind of box, regardless of what's inside. `some` doesn't, because the whole point of `some` is that the underlying type is one thing, just hidden.

## TL;DR

- `any X` — existential. A box. Could be anything that conforms to `X`. Cheap to write, more expensive at runtime.
- `some X` — opaque. One specific concrete type that conforms to `X`. The compiler knows it; you don't need to. Cheap at runtime.
- Prefer `some` (or a generic) over `any` by default.
- For stored properties that need to hold a protocol-conforming thing across the lifetime of the object, you'll usually end up with `some` on the init parameter and `any` on the stored property.

## Going deeper

If you want to see what the compiler is actually doing under the hood with `any` and `some`, [there's a great deck by freddi](https://speakerdeck.com/freddi/deep-dive-into-any-and-some) that walks through it. Worth your time if this kind of thing fascinates you — and if you've made it this far, it probably does.
