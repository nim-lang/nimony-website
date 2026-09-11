# Tools

Nimony is not a single executable. It is a pipeline of small programs that hand
each other [NIF](https://github.com/nim-lang/nifspec) files — which is exactly
why the toolchain is easy to extend: a tool only has to read and write the same
interchange format everything else already speaks.

The two tools you will reach for outside the compiler proper are **dagon**, the
documentation generator, and **pnak**, the package manager. Both ship in the
`bin/` directory of every [nightly build](download.html).

.. raw:: html

   <div class="card-grid">
     <a class="card" href="#dagon">
       <span class="card-kicker">Documentation</span>
       <span class="card-title">dagon</span>
       <span class="card-text">Turns a semantically checked program into a browsable API reference &mdash; HTML, or a NIF tree for other tools to consume. The library docs on this site are its output.</span>
     </a>
     <a class="card" href="#pnak">
       <span class="card-kicker">Packages</span>
       <span class="card-title">pnak</span>
       <span class="card-text">Fetches a project&rsquo;s dependency closure from the <code>requires</code> lines of its <code>.nimble</code> file, pins it to exact commits, and wires the paths into your build.</span>
     </a>
   </div>

----

## dagon

Dagon is the documentation backend, sitting in the pipeline exactly where the
C code generator sits. It reads the post-semantic-check `.sc.nif` of a module and
emits one rendered page per module. Because it works on checked NIF rather than
on source text, every symbol it documents is the symbol the compiler resolved:
signatures are rendered from real types, and links between modules follow the
import graph instead of guessing at names.

You rarely invoke it by hand — the compiler drives it:

```
nimony --outdir:docs doc myproject.nim
```

That produces `docs/` with one HTML page per module and a global index page.
The [standard library reference](stdlib/theindex.html) on this site is built by
exactly this command.

### What it renders

Doc comments (`##`) go through a small, deliberate Markdown subset:

- headings (`#`, `##`, `###`), paragraphs and bullet lists
- fenced code blocks, syntax-highlighted
- pipe tables
- inline `**bold**`, `*italic*`, `` `code` `` and `[links](url)`

Types, procs, iterators, converters, methods, macros, templates, constants and
module-level variables each get an anchored entry. Anchors are percent-encoded
from the symbol id, so links stay stable and unambiguous even when a name is
overloaded.

### HTML is not the only output

```
dagon --format:nif module input.sc.nif output.nif out.docidx
```

`--format:nif` emits the *same document structure* as a NIF tree instead of
HTML. A documentation site with a different look, a search index, an IDE
hover-doc provider — all of them can read that tree instead of scraping
generated markup. The `link` command combines the per-module `.docidx` files
into the global index:

```
dagon link docs/theindex.html docs/*.docidx
```

----

## pnak

**P**nakotic **N**imony **A**rchive **K**ontrol is the package manager. It
reads the `requires` lines of a `.nimble` file, walks the dependency graph, and
leaves you with a `deps/` directory plus the `--path:` lines your build needs.

```
pnak fetch          # clone or update the dependency closure
pnak pin            # write pnak.nif: every dep at an exact commit
pnak search json    # find packages by name
```

### How versions are resolved

Depth decides. The requirement closest to your project wins:

```
YourApp (depth 0)
├── A (depth 1) → wants C@abc123
│   └── C (depth 2)
└── B (depth 1)
    └── D (depth 2) → wants C@def456
        └── C (depth 3)
```

`C@abc123` is used, because `A`'s demand sits closer to `YourApp` than `D`'s.
It is a plain breadth-first traversal — the same algorithm for a first checkout
and for an update, with no solver and no surprises.

A `requires` line may name a git URL or a bare package name; bare names are
resolved through Nim's official `packages.json` (cached locally, `alias`
entries followed), falling back to a GitHub `language:nim` search when that
misses. An optional `#commit` pins the revision.

### Lockfiles

`pnak pin` resolves the full closure and writes `pnak.nif`, listing every
direct *and* indirect dependency at its exact commit. Because the shallowest
requirement wins, that file at your project root simply *is* a lockfile: later
`pnak fetch` runs prefer it over the `.nimble` file.

### Working on several packages at once

Inside `deps/`, an entry may be a directory (a real checkout) or a plain text
file whose first line is a path — a *link*. For a linked package pnak clones
nothing: it parses that checkout's `.nimble` for transitive dependencies and
points the generated paths at wherever the package actually lives. This is the
feature you want when you are editing a library and its consumer side by side.

### Build integration

After resolution pnak rewrites a sentinel-delimited block in `nimony.paths`
(or a `nim.cfg`, with `--cfg:`) containing one `--path:` per resolved package.
Only the managed block is touched — anything you wrote around it survives.

Useful flags: `--parallel:auto` to clone dependencies concurrently, `--offline`
to work from the cache alone, `--depsdir:DIR` to move the checkout directory,
and `--nimony` to restrict `search` to packages tagged for Nimony / Nim 3.

----

## The rest of the toolchain

These sit inside the pipeline; `nimony` shells out to them for you.

| Tool | Role |
| ---- | ---- |
| `nimony` | the driver: parses the command line, runs the pipeline, builds the project |
| `nifler` | maps Nim source to NIF, using Nim's own parser |
| `nimsem` | semantic checking: the pass that produces the `.sc.nif` files dagon reads |
| `hexer` | lowering and optimization, including the ARC-specific optimizer |
| `lengc` | the Leng compiler — NIF to C |
| `niflink` | the link driver: compiles generated C and links the final binary |
| `nifmake` | a make-like engine over a NIF dependency graph; this is what makes builds parallel and incremental |
| `validator` | phase-aware grammar validator: checks that each pass emits well-formed NIF |
| `hastur` | the build and test driver for the toolchain itself (`hastur build all`) |
| `arkham`, `nifasm` | the native backend behind `nimony n`: machine code and a finished ELF / Mach-O / PE image, with no C compiler, assembler or system linker involved |

All of them are in the `bin/` directory of a [nightly build](download.html).
