# Nimony
## Efficient, expressive, elegant

.. raw:: html

   <div class="download-panel download-panel-hero">
     <p class="download-kicker">Get the nightly toolchain</p>
     <p class="download-version" data-nightly-version>Built every day from nimony&rsquo;s <code>master</code> branch.</p>
     <div class="download-grid">
       <a class="download-btn" data-nightly="linux_amd64" href="https://github.com/nim-lang/nimony-website/releases">
         <span class="download-os">Linux</span>
         <span class="download-arch">x86_64 &middot; tar.xz</span>
       </a>
       <a class="download-btn" data-nightly="linux_arm64" href="https://github.com/nim-lang/nimony-website/releases">
         <span class="download-os">Linux</span>
         <span class="download-arch">ARM64 &middot; tar.xz</span>
       </a>
       <a class="download-btn" data-nightly="macos_arm64" href="https://github.com/nim-lang/nimony-website/releases">
         <span class="download-os">macOS</span>
         <span class="download-arch">Apple silicon &middot; tar.xz</span>
       </a>
       <a class="download-btn" data-nightly="windows_amd64" href="https://github.com/nim-lang/nimony-website/releases">
         <span class="download-os">Windows</span>
         <span class="download-arch">x86_64 &middot; zip</span>
       </a>
     </div>
     <p class="download-note">
       Unpack, put <code>bin/</code> on your <code>PATH</code>, done &mdash; and with
       <code>nimony n</code> you do not even need a C compiler.
       <a href="download.html">Download page</a> &middot;
       <a href="install.html">Build from source</a> &middot;
       <a href="tools.html">Tools</a>
     </p>
   </div>

**Nimony** is a new compiler for Nim, organised around [NIF](https://github.com/nim-lang/nifspec): an interchange format that every stage of the pipeline reads and writes. NIF is what makes plugins possible and it is also how we can offer **incremental** and **parallel** builds. The **Nim 3** language features (borrow checking, explicit nilability, sum types, checked generics, …) are built on top of it.

With plugins you can go far beyond what a macro system can accomplish easily:

- **Custom validators**
  - look for possible **deadlocks**
  - look for **race conditions**
  - look for risky **recursion** (embedded targets often have **very small stacks**)
- **Custom code generators**
  - compile a **subset of Nim to GPUs**
  - compile toward **FPGAs**
- **Custom DSLs**, supported more cleanly than in Nim today — for example **lexer** and **parser generators**

For how Nimony relates to **Nim 3** and **Nim 2**, see the [FAQ](faq.html).

The compiler is not the whole story: `dagon` generates the API documentation
from checked NIF, and `pnak` resolves and pins a project's dependencies — see
[Tools](tools.html).

Below are small **language** sketches Nimony emphasizes alongside that toolchain story.

----

## Sum types (algebraic data types)

Variant objects no longer need a separate discriminator enum: tags live in the `case` section, and **`case value of Tag(fields):`** pattern matching binds the fields for that arm — like expressions you’d write in ML-family languages, checked for exhaustiveness.

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

Shared fields can live outside the `case`, variants can nest (`seq[Tree]` in a branch), and grouped matchers like `{Add, Sub}(left, right)` appear where multiple tags share the same shape — see **Case in object** in the [manual](language.html).

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

This follows **prefix exclusion**: while `s` (or `s.elements`) is borrowed, that path cannot be mutated until the borrow ends — sibling fields can still be updated.

----

## Type checked generics

By default generics are type checked: the code is checked when the generic is **defined**, not only when it is instantiated! Duck typing is still available, you get it via the `{.untyped.}` pragma.

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

**2026-09-08** Nimony **0.6.2** has been released. It ships with a guest report from a
user who spent a year porting real projects over. A Vulkan visualiser, a web
framework, an embedded server: [Nim, one year in](version0_6.html).

Older entries, including the [0.2 release](version0_2.html), live on the
[News](news.html) page.
