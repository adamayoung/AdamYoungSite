---
title: iOS Architectures
date: 2026-06-12 12:00
description: Every iOS architecture pattern as a job on a building site: who does what in MVC, MVVM, VIPER, Clean, Redux, TCA and the rest, and which I reach for.
tags: architecture, swift, design principles
image: /assets/images/posts/ios-architectures.png
---

Ask five iOS developers which architecture to use and you'll get six answers, a flame war, and at least one person quietly rewriting the whole app in TCA over the weekend.

Underneath the acronyms, every one of these patterns is answering the same question: who does what? That's it. An architecture is the org chart for your code. It decides which part is allowed to know about which other part, and who has to change when the requirements do.

So instead of another box-and-arrows lecture, picture a building site. The client (your user) wants something built. Each pattern is just a different way of organising the crew.

![iOS architecture patterns laid out as a grid of cards, each with a small node diagram and a one-line building-site analogy: MVC, MVVM, MVVM-C, MVP, VIP, VIPER, Clean, Hexagonal, Redux, TCA and RIBs, with a recommended stack along the bottom.](/assets/images/posts/ios-architectures-infographic.svg)

## One builder, then a crew

**MVC** is one builder doing the lot. The view controller handles the UI, the logic, the data and the navigation. That's fine for a shed. The moment the job grows, that one person is laying bricks, running cable, plumbing and talking to the client all at once, and Model-View-Controller quietly becomes Massive View Controller.

**MVVM** brings in a foreman. The ViewModel preps the materials and decides the state; the View just puts things where it's told. The builder stops making decisions and gets on with building. It's cleaner, and far easier to test, because you can check the foreman's decisions without putting up a single wall.

**MVVM-C** adds a site manager. MVVM still leaves one awkward question hanging: who decides what gets built next? The Coordinator does. It owns the navigation and the flow between screens, so the ViewModel can focus on its own job without knowing or caring where the client wanders off to next.

**MVP** is a passive builder. Model-View-Presenter looks similar, but here the View does nothing on its own. The Presenter decides what to show and when, and the View just reflects it. The builder waits to be told, and the Presenter calls every shot.

## Spelling out every trade

**VIP** is a clear chain of command: View, Interactor, Presenter, in a tidy loop. The View asks for something, the Interactor does the actual structural work, and the Presenter shapes the result and hands it back to the View to display. Each step only talks to the next one.

**VIPER** takes that further and gives every trade its own ticket: View, Interactor, Presenter, Entity, Router. Navigation gets its own layer (the Router), and every responsibility has a dedicated home. On a big crew with a lot of people, that separation earns its keep. On a small one, you spend half your day filling in paperwork to get anything done, and that paperwork has a name: boilerplate.

## Protecting the blueprints

**Clean Architecture** is a professional site with proper stations, and the thing that matters is which way the dependencies point. Your business rules (the blueprints, what the building actually has to do) sit in the middle and depend on nothing. The frameworks, the database and the UI all sit on the outside. You can swap the brand of drill without touching the blueprint.

**Hexagonal** comes from the same instinct: seal the core off. The business logic sits in the centre and talks to the outside world only through ports (interfaces). The database, the network and the UI are just adapters plugged into those ports. Swap an adapter and the core never notices.

## One source of truth on site

**Redux** puts a single board up that everyone reads from. Instead of state scattered across the site, there's one source of truth. Actions describe what just happened, reducers take an action and update the board, and nobody changes the state directly. You post an action and the board updates. When something's wrong, there's one place to look.

**TCA**, the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture), is that same idea built for Swift. It models State, Actions, Reducers and Effects explicitly, with Effects handling the messy async work (the deliveries that turn up whenever they turn up). There's more ceremony up front, but complex SwiftUI screens become predictable and genuinely testable.

## Prefabricated at scale

**RIBs** is prefabricated construction for a very large project. Each feature is its own self-contained unit, with its own router, interactor and builder, that slots into the bigger build. It's aimed at very large apps with very large teams, where you want feature crews working independently without tripping over each other. Overkill for most apps, exactly right for a few.

## What I actually reach for

For most of what I build, I don't reach for the heaviest option on the list. The combination that earns its keep is MVVM-C for the screens, Clean-style layers underneath, use cases for the business logic, the repository pattern for data, a Coordinator for navigation, and tests running through the middle of all of it. Separation of concerns, without drowning in ceremony.

A good architecture is like a well-run building site: every trade knows their role, nothing gets mixed up, and the client ends up with something solid they actually want to live in. The trick is matching the pattern to the size of the job. A shed doesn't need a site manager, and a tower block won't stay up without one.
