# Agent Instructions — Specification

## Event Visualisation

Deploy the idiom described at https://haslab.github.io/formal-software-design/modelling-tips/index.html#an-idiom-to-depict-events to model events occuring at the system boundary.

## Alloy 6 syntax rules

All `.als` files must be valid Alloy 6. Follow these rules strictly.

### File structure
A file must begin with an optional `module` declaration, followed by `open`, `sig`, `fact`, `pred`, `fun`, `assert`, `check`, and `run` blocks in any order. No other tokens are valid at the top level.

```
module <name>

open <module>

sig ...
fact ...
pred ...
assert ...
check ...
run ...
```

### Comments
`--` or `//` start a line comment to end of line. Block comments use `/* ... */`. Prefer `--` for line comments.

### Multiplicity keywords
Use `one`, `lone`, `some`, `set` — not `optional`, `required`, or any other word.

### Signatures
```
sig Foo {}
sig Bar extends Foo {}
abstract sig Baz {}
one sig Singleton {}
```

### Fields
Declared inside the `sig` body with multiplicity:
```
sig Foo {
    field : one Bar,
    other : lone Baz
}
```

### Facts
```
fact <optional-name> {
    <formula>
}
```

### Predicates and functions
```
pred myPred[a: A, b: B] {
    <formula>
}

fun myFun[a: A] : B {
    <expression>
}
```

### Conditionals inside predicates
Use `=>` / `else`, not `if`/`then`/`else`:
```
condition => { ... } else { ... }
```

### Relational navigation
- `a.f` — follow field `f` from `a`
- `~f` — transpose of relation `f`
- `f.g` — relational join
- `^f` — transitive closure
- `*f` — reflexive transitive closure

### Quantifiers
```
all x: T | formula
some x: T | formula
no x: T | formula
lone x: T | formula
one x: T | formula
```

### Assertions and checks
```
assert MyAssertion {
    <formula>
}
check MyAssertion for <scope>
```

### Run
```
run myPred for <scope>
run { <formula> } for <scope>
```

### Integer arithmetic and bitwidth

**Two things are required** whenever a model uses integer arithmetic (`sum`, `plus`, `minus`, `mul`) or has integer-valued fields.

#### 1. Explicit Int bitwidth on every `check` and `run`

```
check MyAssertion for 3 but 5 Int, 5 steps
run { <formula> }  for 3 but 5 Int, 5 steps
```

`for N` alone leaves Int at the Alloy default (4 bits, range −8 to 7). In the temporal SAT solver, an overflowed `sum` can evaluate to `none` (empty relation) rather than wrapping. This produces spurious counterexamples: if both a computed ledger value and a response field overflow to `none`, an equality like `r.quantity = stockLevel[u]` becomes `none = none` — TRUE — while `one r.quantity` is FALSE, causing a false assertion violation. The CLI's `exec` backend handles overflow differently, so the same model returns UNSAT on the CLI and SAT in the GUI.

#### 2. Explicit bounds on every integer field

**Bitwidth alone is not sufficient.** With scope `for N` and bitwidth `K`, the solver can pick field values up to `2^(K−1) − 1`, so `N` atoms can produce a sum of `N × (2^(K−1) − 1)`, which always overflows for `N > 1`. The solver will deliberately choose overflow-triggering values to find spurious counterexamples.

Add a `fact` — marked with a comment — that bounds each integer field so the maximum possible sum stays within range:

```
-- Scope guard: N atoms × maxQ < 2^(K-1). Prevents sum[] overflow in the temporal SAT solver.
fact quantityBound {
    all x: T | x.field <= maxQ
}
```

Choose `maxQ` so that `scope × maxQ < 2^(bitwidth−1)`. For `for 3 but 5 Int` (range −16 to 15): `3 × 4 = 12 < 15`, so `maxQ = 4` is safe.

**Do not rely on integer wrap-around as a feature.** Overflow behaviour differs between solver backends and can change between Alloy versions.
