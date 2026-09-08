# News

Release announcements and reports from the Nimony project. Newest first.

----

## Nimony v0.6.2 — HTTP in the stdlib, and `.passive` grows up

**2026-09-08** · *Araq*

The second stable release on the 0.6 line. `std/http` joins the standard
library, generic `.passive` procs may now suspend and delay-spawn, `.passive`
combines with `.raise`, and all exception lowering has moved into a single
pass in hexer. Behind those: concept requirements anchored to `Self`, a pile
of overload-resolution and template fixes, and error messages where there used
to be assertion failures.

Prebuilt toolchains for Linux x86_64/ARM64, macOS ARM64 and Windows x86_64 are
on the [nightly releases](https://github.com/nim-lang/nimony-website/releases)
page, or [build from source](install.html).

----

## Nimony v0.6 — Nim, one year in

**2026-09-04** · *tokyovigilante*

Nimony 0.6 is out. Instead of a feature list, this release comes with a guest
report from a user who spent the past year moving a stack of real projects —
a Vulkan scientific visualiser, a web framework, an embedded server — onto the
new compiler. It covers the benefits of `.passive` procs and CPS.



[→ Read the article](version0_6.html)

----

## Nimony v0.2 — early preview of Nim 3.0's compiler

**2025-11-01** · *planetis*

Our first release. Rather than a generic enthusiastic announcement, we asked
planetis for an honest review of where Nimony actually stood: a 250-line
Tic-Tac-Toe game with an AI in a worker thread, a tour of the standard library
modules that had been ported, and a frank list of the rough edges — type
resolution errors, missing templates, and the compiler crash that got fixed the
same day it was reported.


[→ Read the article](version0_2.html)
