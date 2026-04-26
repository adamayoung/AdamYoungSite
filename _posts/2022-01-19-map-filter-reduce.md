---
title: "Map, Filter and Reduce"
date: 2022-01-19 22:39:00 +0000
description: "Map, filter and reduce allow you to manipulate sequences. You iterate over a list of items and perform an action on each of those items."
tags: [swift]
---

![Diagram showing map, filter and reduce operating on a list of numbers](/assets/images/posts/map-filter-reduce.svg)

Map, filter and reduce are handy tools for allowing you to manipulate [sequences](https://developer.apple.com/documentation/swift/sequence) in Swift. They are available in most other programming languages too. At first they might seem a little strange, but once you get the hang of them it allows you to write concise and elegant code to get a task done.

## Map

Map lets you iterate over a sequence (e.g. an `Array`) of items and 'transform' each item into something else, returning an array of those new items.

### Arrays

Take this example - we have a list of `Int`s and we want to double each number in that array and get back a new array containing those new numbers. If you've never used map before you might attempt to do this by,

```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
var numbersDoubled = [Int]()

for number in numbers {
    let doubled = number * 2
    numbersDoubled.append(doubled)
}

// [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
```

Looks fine right?

Map allows you to do this in a much neater way. For example,

```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
let numbersDoubled = numbers.map { (number: Int) -> Int in
    return number * 2
}

// [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
```

which could be simplified to,

```swift
let numbersDoubled = numbers.map { number in
    number * 2
}
```

and simplified even further to,

```swift
let numbersDoubled = numbers.map { $0 * 2 }
```

Map is also useful when used with a list of `struct`s or `class`es. For example, suppose we have a list of people, and we want to get a list of just their names.

```swift
struct Person {
    let name: String
}

let people = [
    Person(name: "Adam"),
    Person(name: "Dave"),
    Person(name: "Rob"),
    Person(name: "Matthew")
]

let names = people.map { $0.name }

// ["Adam", "Dave", "Rob", "Matthew"]
```

We could simplify the map by using a [KeyPath](https://developer.apple.com/documentation/swift/keypath),

```swift
let names = people.map(\.name)
```

### Dictionaries

Map can be used with `Dictionary`s too.

```swift
let countryCapitals = [
    "England": "London",
    "France": "Paris",
    "Germany": "Berlin",
    "Italy": "Rome"
]

let countries = countryCapitals.map { key, value in
    return key
}

// ["England", "France", "Germany", "Italy"]

let capitalCities = countryCapitals.map { key, value in
    return value
}

// ["London", "Paris", "Berlin", "Rome"]
```

which could be simplified to,

```swift
let countries = countryCapitals.map { $0 }

let capitalCities = countryCapitals.map { $1 }
```

and even further simplified using `KeyPath`s,

```swift
let countries = countryCapitals.map(\.key)

let capitalCities = countryCapitals.map(\.value)
```

## Filter

Filter, as the name suggests, lets you iterate over a sequence of items, see if the match a predicate, returning an array of those items with match that predicate.

Suppose we have an array of `Int`s, and we want to filter out all the even numbers in that array,

```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
let evenNumbers = numbers.filter { (number: Int) -> Bool in
    return number % 2 == 0
}

// [2, 4, 6, 8, 10]
```

which could be simplified to,

```swift
let evenNumbers = numbers.filter { $0 % 2 == 0 }
```

Another example, let's say we have a list of people, and want to filter out people who's name begins with the letter A,

```swift
struct Person {
    let name: String
}

let people = [
    Person(name: "Adam"),
    Person(name: "Dave"),
    Person(name: "Rob"),
    Person(name: "Adrian"),
    Person(name: "Matthew"),
    Person(name: "Albert")
]

let aPeople = people.filter {
    $0.name.lowercased().starts(with: "a")
}

// ["Adam", "Adrian", "Albert"]
```

## Using Map and Filter

Because map and filter return a sequence of items, you can chain map and filter together to do more complex things. For example,

```swift
struct Person {
    let name: String
}

let names = ["Adam", "Dave", "Rob", "Adrian", "Matthew", "Albert", "Richard"]

let rPeople = names
    .map { name in
        Person(name: name)
    }
    .filter { person in
        person.name.lowercased().starts(with: "r")
    }

// ["Rob", "Richard"]
```

which could be simplified to,

```swift
let rPeople = names
    .map(Person.init)
    .filter { $0.name.lowercased().starts(with: "r") }
```

## Reduce

Reduce is probably the least commonly used of the Map, Filter and Reduce combo. Reduce allows you to iterate over a sequence of items, and combine all those items into a single value.

Here's an example. Suppose we have a list of `Int`s, and we want to find the sum of those `Int`s,

```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
let summedNumbers = numbers.reduce(0) { total, number in
    return total + number
}

// 55
```

Reduce takes two parameters. The first is the initial result of what you're going to get back after reduce as iterated over your list. The second is a closure, which takes two parameters and returns the new value. The first is the next partial result (the result of the previous items having the closure called on them), and the second is the next value in the sequence we're iterating over.

The above can be simplified to,

```swift
let summedNumbers = numbers.reduce(0) { $0 + $1 }
```

and even further to,

```swift
let summedNumbers = numbers.reduce(0, +)
```

Another example, let's concatenate an `Array` of strings into one string,

```swift
let letters = ["A", "B", "C", "D", "E"]
let text = letters.reduce("", +)

// "ABCDE"
```
