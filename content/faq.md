# FAQ

## What are Nimony, Nim 3, and Nim 2?

- [Nim 2](https://nim-lang.org/) is today’s stable Nim toolchain and language as commonly used.
- **Nimony** is a **new compiler** organised around [NIF](https://github.com/nim-lang/nifspec): a plugin-friendly interchange format through the whole pipeline, with **incremental** and **parallel** builds. The evolving **Nim 3** language features (borrow checking, explicit nilability, sum types, concepts-on-generics, …) are built on top of that foundation.
- **Nim 3** is the **language revision** Nimony targets — the evolution of Nim 2.

----

## Why plugins on NIF? What can they do?

Plugins are the evolution of Nim’s macro system. Plugins can be used for:

- **Custom validators** — for example analysis passes hunting possible **deadlocks**, **race conditions**, or dangerous **recursions** when stack space is tiny (embedded targets).
- **Custom code generators** — such as lowering a **subset of Nim** toward **GPUs** or **FPGAs**.
- **Custom DSLs** — including **lexer** and **parser generators**, that run at full speed as plugins are compiled to native code.

Note that macros can be and are used for all these purposes as well. But we think plugins make them easier to do!

----

## How does Nimony relate to Nim 3?

**Nimony is the compiler implementation of Nim 3.** It is scoped so that, for **new (“greenfield”) projects**, it can already be **the practical target** — especially if you care about the **NIF plugin pipeline** and modern semantics together.

**Nim 3 as a full release** is intentionally larger: **Nimony plus substantial compatibility work** so Nim 2 codebases can migrate — libraries, migration aids, and features tuned for **existing projects**. Nimony stays the **focused core** (pipeline + language direction); Nim 3 grows **around** it for everyone else.

----

## What is different from Nim 2?

The **Architecture:** Everything revolves around **NIF**, thanks to NIF we can offer incremental and parallel compilation easily. It also enables validators and alternate backends in a way that Nim’s classic frontend cannot.

The **Language:** Nimony explores Nim 3 designs before Nim offers them (see [differences.md](https://github.com/nim-lang/nimony/blob/master/doc/differences.md)), including:

- explicit `nil` only where you spell `nil ref T` / `nil ptr T`, otherwise refs/ptrs cannot hold nil by default;
- **sum types** with pattern matching;
- **concepts** on generics (`proc foo[T: Comparable](...)`) checked at definition *and* instantiation;
- **borrow checking** for aliasing / iterator invalidation;
- **side-effect defaults** flipped versus Nim 2 (`func`/`iterator` → `noSideEffect`, `proc` → `sideEffect`);
- polymorphic `[]` instead of paired `var` / non-`var` indexing overloads;
- **passive procs** to unify parallelism and concurrency.

----

## How do I get Nimony?

A prebuilt toolchain is published **every day** for Linux x86_64/ARM64, macOS
(Apple silicon) and Windows x86_64: see [Download](download.html). Unpack the
archive, put its `bin/` on your `PATH`, and you are done — no Nim installation
is needed to *use* Nimony, and with the native backend (`nimony n`) no C
compiler either. To build the compiler yourself instead, follow
[Installation](install.html).

----

## What else ships with the compiler?

The archive contains the whole pipeline. Two of those programs you will use
directly: **dagon** generates API documentation from checked NIF, and **pnak**
resolves, pins and fetches a project's dependencies. The [Tools](tools.html)
page introduces both.

----

## Is Nimony a drop-in replacement for Nim 2?

**No.** Once that happens it will be renamed to Nim 3. Currently it neither tries to compile all Nim 2 unchanged nor replicate every pragmatic shortcut overnight. It shines when you want the **NIF-centric toolchain** and early **Nim 3** semantics and can accept **gaps** documented under “present” in [differences.md](https://github.com/nim-lang/nimony/blob/master/doc/differences.md).

----

## Where can I read more?

- The [manual](language.html) on this site has a full language guide.
- The [library index](stdlib/theindex.html) lists every module you can import.
- [Tools](tools.html) covers `dagon` and `pnak` and the rest of the toolchain.
- [differences.md](https://github.com/nim-lang/nimony/blob/master/doc/differences.md) for Nim 2 vs Nim 3 / Nimony trade-offs and open questions.
