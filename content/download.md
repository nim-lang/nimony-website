# Download Nimony

Nimony ships as a **prebuilt toolchain**, rebuilt every day from the latest
`master` of [nim-lang/nimony](https://github.com/nim-lang/nimony). Unpack it,
put `bin/` on your `PATH`, and you have the compiler, the standard library and
every [tool](tools.html) in one directory. With the native backend no other tools (C compiler, assembler, linker) are required.

.. raw:: html

   <div class="download-panel">
     <p class="download-kicker">Nightly toolchain</p>
     <p class="download-version" data-nightly-version>Fresh build from nimony&rsquo;s <code>master</code>, published daily.</p>
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
       Every nightly is a separate, versioned release &mdash; the download URL
       pins an exact commit, so a build you tested never changes underneath you.
       <a href="https://github.com/nim-lang/nimony-website/releases">All releases</a>
       &middot; <a href="install.html">Build from source</a>
     </p>
   </div>

## Install

Linux and macOS:

```
tar xf nimony-*-linux_amd64.tar.xz
export PATH="$PWD/nimony/bin:$PATH"
nimony --version
```

Windows: unzip the archive and add the extracted `nimony\bin` to your `PATH`.

The archive ships a
native backend, and `nimony n` goes from your source to a finished executable
using nothing but the tools in `bin/`. `arkham` generates machine code and `nifasm` writes the ELF, Mach-O or
PE image itself. This works on every platform we publish, and it is particularly useful on Window which does not ship with a C compiler.

The C backend (`nimony c`) is still the default and does need a C compiler on
the `PATH` — `gcc` or `clang` on Unix. On Windows, run

```
hastur install
```

from the extracted directory once and it downloads a bundled MinGW + LLVM
toolchain into `external/`.

## First program

```nim
import std / syncio

echo "Hello from Nimony!"
```

Via the native backend — no C compiler involved:

```
nimony n -r hello.nim
```

Or via the C backend:

```
nimony c -r hello.nim
```

See the [manual](language.html) for the language, the
[library index](stdlib/theindex.html) for what is available to import, and
[Tools](tools.html) for the rest of the toolchain — including `pnak`, which
fetches the dependencies of a project.

## What is in the archive

| Path | Contents |
| ---- | -------- |
| `bin/` | `nimony` and every tool it shells out to |
| `lib/` | the Nimony standard library |
| `src/lib/` | NIF libraries used by macros and plugins |
| `NIGHTLY.txt` | the exact nimony commit, date and platform of this build |

Each archive is smoke-tested in CI before it is published: the packaged tree
alone — nothing else installed — has to compile and run a hello-world program.

## Other ways to get Nimony

- [Build from source](install.html) — needs Nim 2.0 or later and one
  `hastur build all` invocation. This is the path to take if you want to hack
  on the compiler itself.
- [All nightly releases](https://github.com/nim-lang/nimony-website/releases) —
  every published build, newest first, with per-commit tags.
