# Nimony v0.6.4

**2026-11-28**

## Author: Andreas Rumpf

0.6.4 is here. This is supposed to be the last release before the big 6.0.0 release in December. Yes, you read that right, the first stable release will be *6*.0.0. I hope
this will not be seen as an evil advertisement campaign of some vaporware.

So why *6*? Because it will be released in 2026. The used version scheme is time-based 
versioning, not semver. But it is somewhat compatible with semver, the format is still 
`major.minor.patch`. `major` determines the major product line and will be `6` for the
foreseeable future.

`patch` is odd for an unreleased in-development version and even for an official release.

You can always use `major + minor + 2020` to determine the year of the release. So the 
first release in 2027 will be `6.1`, as `6 + 1 + 2020 == 2027`. It is theoretically possible
that a new major line is released in 2027 too, this would then be `7.0.0`.

What constitutes a new major line? I don't intend to break backwards compatibility, Nimony
in its current state is already Nim 4 in my mind; Nim 3 was Nim 2 + the NIF based plugin 
system, Nim 4 would have added the static contract checking engine. All part of 0.6.4 already
because agentic coding does speed up development.


## What this means in practice

If version 6.0.0 is released in December 2026, any version of the 6 line released in 2027 will be 6.1.x.
Nimony is developing very rapidly so a time-based release every 3 months seems realistic.


## Accepts invalid

Compilers are unlike most other software because they often have bugs of the form "accepts-invalid", bugs that lead the compiler to accept an ill-formed program. Whenever such a bug is fixed, we might break somebody's build! In fact, in general all bugfixes change the behavior of a program and are way more dangerous than feature additions. Semver encourages the thinking that bugfixes are these "minor" things you simply want to receive automatically, whereas feature additions are the "major" things you want to consider cautiously. That is exactly the wrong ordering and every package manager that forces semver upon you is deeply flawed.

Only bugfixes that deal with security holes are the ones that should be pushed harder to you.
And of course bugfixes that deal with simple program crashes. For a compiler this assumes that
your build pipeline did not depend on the compiler to crash, a very practical assumption.

So for version 0.6.4 we focussed on accepts-invalid bugs, the compiler should be as picky as
we can get away with. We can always allow more programs to be valid later, but the opposite
is not true: Programs that used to compile, should keep compiling. There are migration methods
such as new warnings that can be turned into errors. But these are band-aids, they eventually do break your build and lead to a miserable update experience.


## Boring! Show me some code

Alright, here is what 0.6.4 can do:

```nim
import std / parfor

const N = 100
var x: array[N, int]

proc main =
  for i in 0 || N:
    for j in 0 ..< 3:
      x[i] = j

main()
```

This program does not compile! It is racy:

```
Error: `||` writes `x[i]` inside a nested loop — a single `i` then spans a range of indices and adjacent chunks race; hoist the write out of the inner loop
```

A parallel program that compiles and does something useful is left as an exercise for the reader.


The full list of changes, and some numbers, can be found in the [changelog](version_0_6_4-changelog.html).

Please support our work by contributing on [Open Collective](https://opencollective.com/nim).

