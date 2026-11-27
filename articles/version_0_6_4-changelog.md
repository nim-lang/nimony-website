# Nimony v0.6.4 — Changelog

**2026-11-27**

All changes since v0.6.2. See the [release announcement](version_0_6_4.html) for the
rationale behind the stricter compiler.


## By the numbers

Counted over nimony and its native backend [nativenif](https://github.com/nim-lang/nativenif),
tests excluded.

| | nimony | nativenif | total |
| --- | --- | --- | --- |
| Commits since v0.6.2 | 568 | 55 | 623 |
| Lines added | 85,000 | 22,158 | 107,158 |
| Lines removed | 18,946 | 10,239 | 29,185 |
| Lines of Nim (non-blank), v0.6.2 | 143k | 66k | 209k |
| Lines of Nim (non-blank), now | 204k | 76k | 280k |
| Bug reports closed as fixed | 363 | 2 | **365** |
| Bug reports still open | 333 | 8 | 341 |

26 people contributed. Of nimony's 363 fixed bug reports, 158 are from nim-lang/nimony,
149 from nimony-bugs-llms and 56 from nimony-bugs-fuzzers.

How many bugs *should* there be? The classic figure (McConnell, *Code Complete*) is
1–25 defects per 1,000 lines of delivered code. For 280,000 lines that means somewhere
between **280** and **7,000** bugs, roughly **4,200** at an industry-typical 15 per
thousand lines. We fixed 365 in this cycle and know of 341 more. You do the math on
the rest; better yet, run the fuzzer and report them.


## Breaking changes: the compiler is pickier

Programs that compiled with 0.6.2 may be rejected now. This is deliberate, see the
"accepts invalid" section of the announcement.

- Exceptions: only `ErrorCode` and `ref` objects can be raised.
- Unlabeled `break` only leaves loops (RFC #576).
- `.noSideEffect`/`func` disallow mutations through `ref`/`ptr`; a `var` parameter gives
  write access to its own storage only.
- `==`, `<=`, `<` are declared per type like in Nim; no implicit `==` for `distinct` types.
- `..` and `countup` require `b < high(T)` unless `T` has spare bits, and do not compile for `bool`.
- Enum field values must be in ascending order.
- A base method must be declared in its class's module.
- `.feature` inside a routine body is rejected.
- A `.noreturn` proc whose body can return is rejected; an undecided `.ensures` is an error in every mode.
- A global needs an initial value when zero is not a valid value of its type; a not-nil pointer has no default value.
- A `=destroy` requires a `=wasMoved`; `=copy` and `=dup` that disagree on `.error` are rejected.
- Value expressions (and `if`/`case`/`try`/`block` expressions) passed to `var`/`out` parameters are rejected.
- An assignment whose right-hand side may move its destination is rejected.
- Re-exported symbols no longer bring their module's name into scope.
- Recursive inline iterators, types that contain themselves by value and cyclic type aliases are reported as errors instead of crashing.
- A type class as a parameter type of a compiled routine is an error.
- `slurp` of a missing file is an error (as in Nim 2); a raising const evaluation is an error.
- Strings no longer reach `var openArray` parameters (see the new `readonlyView` pragma).
- `system.move` resets to `default(T)`; `=wasMoved` stays the cheap hook.
- The feature `earlyMagics` was removed.
- `std/regex` was renamed to `std/rex`.
- `std/ioring` refuses `--mm:arc` and `--mm:orc`.


## Static contracts and the prover

- `.requires` is checked at compile time; static assertion checking; array indexing is proven at compile time.
- Loop invariants: `{.invariant: cond.}`, proven by induction.
- The prover knows that signed arithmetic wraps, respects integer widths and bounds every integer operation by its type.
- `MaxContainerLen` bounds every length; `inc`/`dec` on a range-typed location owe the range at the call site.
- Range-parameter arguments are proven; sums are operand-order independent.
- Owned and shared variables; barriers end what is known.
- Correct handling of `finally`, `except`, `for`/`break` exits and joins.
- Aliasing rules for the prover and the `func` rule for `var` parameters are part of the spec.
- `||` loops are checked for races: writes that make adjacent chunks overlap are rejected.


## Borrow checking

- Fresh call results, forwarded `var` arguments and temporaries are handled.
- `result` holds its borrow, `let a = b` takes over `b`'s borrow, a self-reslice keeps it.
- Iterating a location reached through a `ref` is rejected.
- A borrowed location cannot be passed to a `sink` parameter.
- Views of by-value parameters: the first is passed by reference, the rest are rejected.


## Language

- Constant parameters: `staticParam`, `static(expr)`, static overloads.
- `owned ref`.
- Composable iterators; cross-module `.passive` methods and iterators; `for` loops over `.passive`, `.raises` iterators.
- `instantiationInfo` magic.
- Nim's `.compile` and `.link` pragmas, in full.
- `readonlyView` pragma.
- `case` on a float selector.
- `let (a, b): T = x` keeps the type annotation.
- Casts between a word-sized set and an integer, and between non-closure procs and `pointer`.
- A subtype satisfies a generic constraint `[T: Base]`.
- Concepts: container constraints (`C: Findable[T]`), inherited concept invocations, refined constraints.
- Bare `typedesc` template parameters; untyped templates with the same name in `when` branches; nested templates.
- Module-qualified `declared(m.name)`.
- Sum types: constructors take the type the context expects; `case` branches that bind fields can give the case's value; `var` results from hidden sum type patterns.
- A constant of an inheritable object type; compile-time folding of subscripts of constant arrays and tuples.
- Cyclic imports: exporting from a cyclic member works, one shared hook table per cycle.
- Closures: captured `sink` params are freed, closure-typed methods dispatch, loop variables are captured by value.


## Memory management

- `--mm:orc`: Nim's cycle collector was ported, `=trace` is lifted properly.
- `--mm` also takes a path, for a runtime of your own.
- Better out-of-memory handling: `new` panics on OOM outside a `.raises` routine; no writes through refused seq and string allocations.
- An inheritable object is destroyed through its vtable.
- Copy hooks are honored on types without `=destroy`; a lone `=copy` or `=dup` is a hook too; generics in hooks are instantiated.


## Plugins

- Macro plugins can live outside the repository.
- Fold plugins.
- Plugin imports join the program; a plugin is rebuilt when its imports change.
- Typed views of declarations, calls, field selections, operators and control flow; declaration lookup helpers.
- Imported macro plugins run from the stdlib cache.
- A deferred plugin call has its own tag, and `untyped` means untyped.
- Docs: introduction to NIF and basic template plugins.


## Backends and platforms

- JavaScript backend driver and `{.importjs.}`; one web backend binary for both `j` and `w`.
- LLVM backend: atomic instructions, target triples, integer promotion and many codegen fixes.
- C++: a module's `const` is `extern`; `exportc` procs and globals get C linkage.
- Intrinsics: `adc`, `sbb`, `mul`, `imul`, `cmovCC`, `sqrt`, block-memory rows; AArch64 support.
- `--app:lib` and `staticlib` export a `NimMain` and define `nimEnviron`.
- New platforms: Solaris, illumos, FreeBSD, Android (Bionic), Linux 32-bit ARM.
- `-d:useLibc` on arm64 Linux.


## Optimizer (shoggoth)

- Loop rotation, counted-loop recognition, cold guards, affine induction variables.
- Inliner builds results in place; SROA decomposes whole-assigned and nested objects.
- CSE is about 2x cheaper; the cleanup pipeline runs as one fixpoint.
- The move analysis runs directly on the Final IR.
- hexer was merged into shoggoth; shoggoth and lengc are self-hosted.


## Compiler performance and tooling

- The parser is about 3x faster (node based).
- Lower memory consumption; immutable views save ~8% of IC build time.
- Shared stdlib cache with per-node locks and parallel import parsing (bootstrap 38.5s → ~31s).
- IC: per-backend nimcache dirs, interface checksums cover generic bodies, private declarations, re-exports and imports.
- nifmake: `--profile` reports peak memory, `--keepgoing`, `(atomic)` outputs, better error reporting, one `[100%] done` line.
- hastur: `--parallelBuild:N`, faster test runs.
- `tools/difffuzz`: differential fuzzing of `nimony n` against `nimony c`.
- NIF logger; NIF reader accepts hex/octal/binary integers and `_` separators.
- Better diagnostics in many places, e.g. the undeclared identifier in a `for` head.


## Standard library

New modules:

- Networking: `std/httpserver`, `std/uri`, `std/http/httpdate`, websockets, `std/dns` (single resolver), `httpRequest` in `std/httpclient` with status codes, redirects and deadlines.
- `std/rex` (regular expressions, a port of lexim, with Unicode support) and a parser generator.
- `std/compress` (deflate, gzip, zlib) and HTTP content codings.
- Streams; `std/channels`; `std/parklocks`, a mutex that parks `.passive` tasks.
- `std/colors`; cursor control, erasing, terminal size and true color in `std/terminal`.
- `std/vectors` with broadcasting.
- `std/rationals`, `std/stats`, native `std/math` (correctly rounded `sqrt`, `sin`/`cos`/`tan` within 1 ulp, `sincos`).
- Time zones in `std/times`.
- Ports from Nim: `tables`, `critbits`, `ropes`, `parsexml`, `parsecsv` (streaming), `mimetypes`, `endians`, `oids`, `cstrutils`, `lenientops`.

Additions:

- `strutils`: `align`, `alignLeft`, `center`, `indent`, `unindent`, `indentation`, `dedent`, `count`.
- `system`: `&` for seqs and tuples, `/=`, `high`/`low` for floats, `items` for ordinal enums, composite `$` for built-in collections, value-level `repr`, stringification of types.
- `std/json`: raw-number parsing mode, `toJson`/`fromJson` for `Table`, `OrderedTable[string, V]` and `Opt[T]`.
- `parseutils`: correctly rounded float parsing (Eisel-Lemire).
- `syncio`: a `readLine` that returns a string; the native IO layer is the only one and retries `EINTR`.
- `std/ioring`: `submitPollRemove`, `Deadline.expired()`, epoll on Android.
- No `SIGPIPE` on a write to a gone peer.


## Security hardening

A security review (NMY-001 to NMY-018) led to these fixes:

- `std/json`: nesting depth is capped, a missing key yields a real null, missing commas and trailing input are errors, every control character is escaped.
- `std/tls` rejects unprotected records once encryption has started.
- `std/http`/`std/httpclient`/`std/httpserver` reject CR/LF in header values and URLs, malformed header blocks, non-chunked `Transfer-Encoding` and short bodies.
- `std/dns` uses random query ids and checks that a reply echoes the question.
- `std/crypto`: ECDSA accepts only DER signatures, the ChaCha20-Poly1305 block counter never wraps.
- `std/compress`: one-shot decoders default to a 64 MiB output limit.
- nifmake, nimony and pnak quote shell arguments properly; hastur verifies the SHA-256 of downloaded toolchains.
- `std/osproc` opens its launch pipes close-on-exec.


## Bugfixes

365 closed bug reports, many found by fuzzers and LLM-driven bug hunts
(planetis-m/nimony-bugs-fuzzers, planetis-m/nimony-bugs-llms). See the
[git log](https://github.com/nim-lang/nimony/compare/v0.6.2...master) for the full list.
