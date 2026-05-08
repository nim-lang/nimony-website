# Nimony
## Efficient, expressive, elegant

**Why Nimony exists:** the whole compiler is organized around [NIF](https://github.com/nim-lang/nifspec), an interchange format you can plug tools into. That plugin ecosystem is what Nimony is *for*—and it also delivers **incremental** and **parallel** builds in a way the classic Nim compiler does not.

Along the pipeline, Nimony lowers structured programs into **NJ**, an IR where control flow has only **loops** and **`if`**—**no unstructured control flow**. Both **validators** and **code generators** become dramatically simpler to write than against arbitrary CFGs or macros bolted onto the frontend.

With plugins on top of NIF / NJ you can go far beyond a plain compiler driver—for example:

- **Custom validators**
  - look for possible **deadlocks**
  - look for **race conditions**
  - look for risky **recursion** (embedded targets often have **very small stacks**)
- **Custom code generators**
  - compile a **subset of Nim to GPUs**
  - compile toward **FPGAs**
- **Custom DSLs**, supported more cleanly than in Nim today—for example **lexer** and **parser generators**

For how Nimony relates to **Nim 3** and **Nim 2**, see the [FAQ](faq.html).

Below are small **language** sketches Nimony emphasizes alongside that toolchain story.

----

## Sum types (algebraic data types)

Variant objects no longer need a separate discriminator enum: tags live in the `case` section, and **`case value of Tag(fields):`** pattern matching binds the fields for that arm—like expressions you’d write in ML-family languages, checked for exhaustiveness.

```nim
type
  Expr = ref object
    case
    of Lit:
      value: int
    of Add, Sub:
      left, right: Expr

proc eval(e: Expr): int =
  case e
  of Lit(value):
    result = value
  of Add(left, right):
    result = eval(left) + eval(right)
  of Sub(left, right):
    result = eval(left) - eval(right)

echo eval(Add(left: Lit(value: 10), right: Lit(value: 32)))  # 42
```

Shared fields can live outside the `case`, variants can nest (`seq[Tree]` in a branch), and grouped matchers like `{Add, Sub}(left, right)` appear where multiple tags share the same shape—see **Case in object** in the [manual](manual.html).

----

## Borrow checking — iterator safety and aliasing

(Nimony tightens memory aliasing rules—nice-to-have safety on top of the pipeline story.)

Nimony rejects classic footguns at compile time:

```nim
proc grow(s: var seq[int]; use: int) =
  s.add use

var s = @[1, 2, 3]
# for v in s:
#   grow(s, v)   # Error: `s` is borrowed during iteration — no realloc under active borrows
```

This follows **prefix exclusion**: while `s` (or `s.elements`) is borrowed, that path cannot be mutated until the borrow ends—sibling fields can still be updated.

----

## Concepts describe what generics need

Concepts list required operations; generics use them so APIs are checked at definition and instantiation—duck typing for containers is gone:

```nim
type
  Comparable = concept
    proc `<`(a, b: Self): bool

proc min[T: Comparable](a, b: T): T =
  if a < b: a else: b

echo min(3, 7)
echo min("b", "a")
```

Container-style concepts (e.g. `Findable[T]`) work the same way with iterators and indexed access—see **Concepts** and **Generics** in the [manual](manual.html).


----

# News

**2025-11-05** We have our first release! Version 0.2! Read this [article](version0_2.html) for more information.
