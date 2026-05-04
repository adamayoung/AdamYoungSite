---
title: Principles of Object-Oriented Design
date: 2026-05-04 12:00
description: SOLID and the three component principles, demonstrated with a car. A tour of the rules of thumb that keep classes and modules from turning to soup.
tags: swift, architecture, design principles, solid
image: /assets/images/posts/object-oriented-design-principles.svg
---

![SOLID spelled out as five glass cards (SRP, OCP, LSP, ISP, DIP), with three smaller cards beneath for the component-cohesion principles (REP, CCP, CRP).](/assets/images/posts/object-oriented-design-principles.svg)

SOLID is one of those acronyms you can recite in your sleep but find harder to apply than to memorise. Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion. Bob Martin's five rules of thumb for keeping classes manageable.

There are also three less-famous siblings about *components* (modules, packages, frameworks): REP, CCP, CRP. They get less air time, probably because once you're past one-class-fits-all and into structuring whole codebases, the answers stop fitting on a poster.

This is a tour of all eight, with a car in every example. Cars and OO seem to fit naturally together, probably because both have well-defined parts that have to work together without knowing too much about each other.

A note before we start: these are rules of thumb, not laws. They have edges, they have exceptions, and they're often more useful as questions than as commandments. *"Am I about to violate SRP, and if so, why?"* tends to be a better prompt than *"this code violates SRP, therefore it's wrong."*

## SOLID: principles for classes

### Single Responsibility Principle (SRP)

> A class should have only one reason to change.

The clean phrasing is "one job", but "one reason to change" is more useful. A `Car` that knows how to drive itself, log diagnostics, and serialise to JSON has three reasons to change: a new driving feature, a new logger, a new on-disk format. Three reasons mean three places where one concern can ripple into another.

```swift
// Doing too much.
final class Car {
    private(set) var speed: Double = 0

    func accelerate(by delta: Double) {
        speed += delta
        print("Speed: \(speed)")
    }

    func toJSON() -> String {
        "{ \"speed\": \(speed) }"
    }
}
```

Three jobs in one type. Pull them apart.

```swift
final class Car {
    private(set) var speed: Double = 0
    func accelerate(by delta: Double) { speed += delta }
}

struct CarLogger {
    func log(_ car: Car) { print("Speed: \(car.speed)") }
}

struct CarEncoder {
    func encode(_ car: Car) -> String { "{ \"speed\": \(car.speed) }" }
}
```

Now each type changes for one reason. Logging policy moves? `CarLogger`. Storage format moves? `CarEncoder`. Driving model changes? `Car`.

### Open/Closed Principle (OCP)

> A class should be open for extension and closed for modification.

You should be able to teach an existing class new tricks without editing it. The mechanism is usually polymorphism: depend on a protocol, swap in new conforming types.

```swift
// Closed to extension: every new engine forces you to edit Car.
final class Car {
    enum EngineKind { case petrol, diesel }
    let engine: EngineKind

    func start() {
        switch engine {
        case .petrol: print("vroom")
        case .diesel: print("clatter clatter vroom")
        }
    }
}
```

Add hydrogen, edit `Car`. Add electric, edit `Car`. The class is the bottleneck. Invert it:

```swift
protocol Engine {
    func start()
}

struct Petrol: Engine   { func start() { print("vroom") } }
struct Diesel: Engine   { func start() { print("clatter clatter vroom") } }
struct Electric: Engine { func start() { print("hum") } }

final class Car {
    let engine: any Engine
    init(engine: some Engine) { self.engine = engine }
    func start() { engine.start() }
}
```

`Car` is now closed for modification (you don't touch it again) and open for extension (add new engines by adding new types). Want a hydrogen fuel-cell? Write `struct Hydrogen: Engine`. `Car` stays exactly as it was.

`some` on the init parameter, `any` on the stored property is the idiomatic Swift split. The caller gets the cheap, statically-resolved version; the property accepts the box because it has to hold the engine across the car's lifetime. [Why](/blog/existential-and-opaque-types/) is its own post.

### Liskov Substitution Principle (LSP)

> Subtypes must be substitutable for their base types without breaking correctness.

If `B` is a subtype of `A`, anywhere your code uses an `A` it must be safe to hand it a `B` instead. The bit that catches people is "without breaking correctness": LSP isn't about whether the code *compiles*, it's about whether it still *behaves* correctly.

The classic violation:

```swift
class Car {
    func refuel(litres: Double) { /* fill the tank */ }
}

class ElectricCar: Car {
    override func refuel(litres: Double) {
        fatalError("electric cars don't take petrol")
    }
}
```

This compiles. Anywhere holding a `Car`, you can technically pass an `ElectricCar`. The first time something calls `refuel`, the program dies. `ElectricCar` is *not* substitutable for `Car`, even though the type system is fine with it.

And LSP isn't only about crashing. The deeper version of the principle is about contracts: a subtype mustn't strengthen what its base type requires, or weaken what its base type guarantees. A `Square` that inherits from `Rectangle` and quietly couples width and height together never crashes, never throws, but every caller that assumed independent dimensions is now silently wrong. `fatalError` is just the loud version.

The fix is to push the offending behaviour out of the base type:

```swift
protocol Vehicle {
    func start()
    func stop()
}

protocol Refuelable {
    func refuel(litres: Double)
}

protocol Rechargeable {
    func recharge(kWh: Double)
}

final class PetrolCar: Vehicle, Refuelable {
    func start() { /* … */ }
    func stop()  { /* … */ }
    func refuel(litres: Double) { /* … */ }
}

final class ElectricCar: Vehicle, Rechargeable {
    func start() { /* … */ }
    func stop()  { /* … */ }
    func recharge(kWh: Double) { /* … */ }
}
```

A function that needs to refuel asks for `Refuelable`. A function that just wants to drive asks for `Vehicle`. Nobody ever holds a "car-shaped thing" and finds out at runtime that it explodes when you try to refuel it.

The fix for the contract case is the same shape: stop claiming a `Square` is-a `Rectangle` when its invariants are stricter. Composition, not inheritance.

### Interface Segregation Principle (ISP)

> Many small, client-specific protocols beat one large general one.

If a protocol has fifteen methods and most clients use three of them, every client now depends on the twelve they don't care about. Add a method to the big protocol and every conforming type has to implement it, even the ones it makes no sense for.

```swift
// One big protocol that everything has to implement.
protocol Vehicle {
    func drive()
    func refuel(litres: Double)
    func recharge(kWh: Double)
    func openSunroof()
    func deployAirbags()
}
```

A bicycle conforming to `Vehicle` would have to implement five methods, four of which are nonsense for a bike. Worse, the call site doesn't know which calls are safe.

Slice it up:

```swift
protocol Drivable       { func drive() }
protocol Refuelable     { func refuel(litres: Double) }
protocol Rechargeable   { func recharge(kWh: Double) }
protocol Sunroofed      { func openSunroof() }
protocol AirbagEquipped { func deployAirbags() }
```

A type now adopts only the protocols it can honour. A function asks only for the capability it actually needs, and Swift's protocol composition makes that natural at the call site:

```swift
func service(_ vehicle: some Drivable & Refuelable) { /* … */ }
```

That signature declares exactly the capability set the function requires and nothing else. You'll often find the cleanest fix to an LSP violation is an ISP one: split the protocol so subtypes only sign up for what they can really do.

### Dependency Inversion Principle (DIP)

> Depend on abstractions, not concretions. High-level modules should not depend on low-level ones; both should depend on abstractions.

If `Car` reaches in and constructs a specific `BoschECU`, the high-level `Car` is now coupled to a specific low-level supplier. Swap to a Continental ECU, edit `Car`. Want to test `Car` in isolation? You can't, because `BoschECU` comes for the ride.

```swift
// Concrete dependency, baked in.
final class Car {
    private let ecu = BoschECU()
    func start() { ecu.boot() }
}
```

Invert the dependency direction:

```swift
protocol ECU {
    func boot()
}

final class Car {
    private let ecu: any ECU
    init(ecu: some ECU) { self.ecu = ecu }
    func start() { ecu.boot() }
}

struct BoschECU: ECU       { func boot() { /* … */ } }
struct ContinentalECU: ECU { func boot() { /* … */ } }
struct MockECU: ECU        { func boot() { /* … */ } }   // tests
```

The "inversion" is about ownership of the abstraction, not just the direction of the arrow. Before, `BoschECU` would have defined its own API and `Car` would have depended on it: high-level depends on low-level. After, `Car` declares the `ECU` protocol it needs, and `BoschECU` conforms to it: low-level now depends on the high-level's abstraction. Both ends point at the protocol, but the protocol lives with the layer that *uses* it, not the layer that supplies it.

DIP is the bit that makes OCP possible. Extension by polymorphism only works if your callers depend on the protocol, not the concrete type.

## Component principles

These aren't about classes. They're about how you group classes into deployable, releasable, reusable units (Swift packages, npm packages, .NET assemblies, however you slice your codebase).

The framing here is from Bob Martin's *Agile Software Development*. The tension between the three matters more than any one of them in isolation, so we'll get to that after the tour.

### Reuse/Release Equivalence Principle (REP)

> The granule of reuse is the granule of release.

If you want people to reuse your component, you have to release it as a coherent unit, with version numbers and change notes. Without those, no one can use it safely: they don't know which version of A is compatible with which version of B, or what's just changed under their feet.

In Swift terms: if you're tempted to have people reach into your repo and copy a few files, you've already lost. Either it's a Swift package with a version, or it isn't really reusable. (You don't take a *bit* of an engine.)

### Common Closure Principle (CCP)

> Gather into the same component the classes that change for the same reasons, at the same times.

This is SRP, restated for components. A component should not have multiple reasons to change. If, every time the speedometer calibration changes, you also have to release the entire `CarKit` package, your component is too big.

CCP says: cluster things that *move together*. Engine internals change for engine reasons; infotainment changes for infotainment reasons; they belong in different components.

### Common Reuse Principle (CRP)

> Don't force users of a component to depend on things they don't need.

Reusable classes rarely stand alone. They collaborate with a small group of others, and those collaborators belong in the same component. But classes that *aren't* part of that reusable cluster don't.

Concretely: a `CarKit` package that bundles in the entire infotainment stack will force every consumer to pull infotainment along, even if all they wanted was to start the engine. Either every consumer takes the whole lot or you split it. CRP says: split it.

### The tension between them

Here's where it gets interesting. The three pull against each other.

- **REP** pushes you towards bigger components, because fewer artefacts means fewer release headaches.
- **CCP** keeps things together that change together, which also tends to grow components.
- **CRP** wants things split apart so consumers don't take what they don't need, which shrinks components.

You can't satisfy all three at once. You sit somewhere inside the triangle, and *which corner you favour shifts as the project matures*.

Early on, when nothing's stable and you're still working out where the boundaries even are, you favour CCP. Don't fragment the codebase before you know what's coupled to what. Later, when consumers start showing up, the pressure shifts towards CRP: split out the bits that are actually being reused, so they don't drag the whole world along with them.

On iOS this turns up as the *"should this be its own Swift package?"* question, asked over and over. Early in an app, slicing into a forest of SPM modules buys you very little and costs you build complexity and project-graph headaches. CCP says: don't bother yet. Later, when a Today widget needs the same article-cell view that the main app renders, the bit that used to be tangled inside the app target becomes the obvious extraction. CRP says: now you have to. Same diagram, different point on it.

REP sits underneath all of it. The moment you cross "this is a thing other code depends on" you owe it a release process.

The diagram below is the classic one (from Martin). The vertices are the principles. Each edge describes the cost of *abandoning* the principle on the opposite vertex.

![Tension diagram for the three component principles. A triangle with REP at the top, CCP at the bottom-right, and CRP at the bottom-left. Each edge describes what goes wrong when the principle on the opposite vertex is abandoned: the bottom edge (opposite REP) is "Hard to reuse"; the left edge (opposite CCP) is "Too many components change"; the right edge (opposite CRP) is "Too many unneeded releases".](/assets/images/posts/object-oriented-design-principles-cohesion.svg)

## A unifying theme

Read all eight together and a common thread shows up: **manage the impact of change**.

- SRP, CCP: minimise the *spread* of any one change.
- OCP, DIP: let new behaviour land *without* changing existing code.
- LSP, ISP: keep substitution and dependency surfaces honest, so changes don't ripple unexpectedly.
- REP, CRP: don't make consumers re-test or re-deploy because of a change they don't care about.

Every one of them is a different angle on the same question: when something has to change, how much else has to change with it?

If you only take one thing from any of this, take that. The eight principles are scaffolding for asking that question well.

## Going deeper

Bob Martin's [*Clean Architecture*](https://www.amazon.co.uk/Clean-Architecture-Craftsmans-Software-Structure/dp/0134494164) is where this whole thing is laid out at length. *Agile Software Development, Principles, Patterns, and Practices* (older, denser, the original source for the component-cohesion chapters) is the one to pick up if any of the second half of this post left you wanting more.
