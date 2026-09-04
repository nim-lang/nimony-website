# Nimony
## Efficient, expressive, elegant

**Nimony** is a **new compiler** organised around [NIF](https://github.com/nim-lang/nifspec): a plugin-friendly interchange format through the whole pipeline, with **incremental** and **parallel** builds. The evolving **Nim 3** language features (borrow checking, explicit nilability, sum types, concepts-on-generics, …) are built  on top of that foundation.

With plugins you can go far beyond what a macro system can accomplish easily:

- **Custom validators**
  - look for possible **deadlocks**
  - look for **race conditions**
  - look for risky **recursion** (embedded targets often have **very small stacks**)
- **Custom code generators**
  - compile a **subset of Nim to GPUs**
  - compile toward **FPGAs**
- **Custom DSLs**, supported more cleanly than in Nim today—for example **lexer** and **parser generators**

For how Nimony relates to **Nim 3** and **Nim 2**, see the [FAQ](faq.html).

## Nightly builds

Prebuilt toolchains are published every day.

[→ Browse the nightly releases](https://github.com/nim-lang/nimony-website/releases) and grab the newest archive for your platform. We currently offer builds for: Linux x86_64, Linux ARM64, macOS ARM64, or Windows x86_64.

Extract the archive, add its `bin/` directory to your `PATH`, and make sure a C compiler (`gcc` or `clang`) is available. On Windows, run `hastur install` from the extracted directory to fetch the bundled MinGW+LLVM toolchain. Or [build from source](install.html).

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

Shared fields can live outside the `case`, variants can nest (`seq[Tree]` in a branch), and grouped matchers like `{Add, Sub}(left, right)` appear where multiple tags share the same shape—see **Case in object** in the [manual](language.html).

----

## Borrow checking — iterator safety and aliasing

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

## Type checked generics

Duck typing for containers is opt-in, the new default are type checked generics. In other words, generics are check at instantiation time!

The required operations are described via concepts:

```nim
type
  Comparable = concept
    proc `<`(a, b: Self): bool

proc min[T: Comparable](a, b: T): T =
  if a < b: a else: b

echo min(3, 7)
echo min("b", "a")
```

Container-style concepts (e.g. `Findable[T]`) work the same way with iterators and indexed access — see **Concepts** and **Generics** in the [manual](language.html).


----

# Latest news

**2026-09-04** Nimony **0.6** is released. It ships with a guest report from a
user who spent a year porting real projects — a Vulkan visualiser, a web
framework, an embedded server — over to it: [Nim, one year in](version0_6.html).

Older entries, including the [0.2 release](version0_2.html), live on the
[News](news.html) page.
