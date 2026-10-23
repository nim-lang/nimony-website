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

**Nimony** is a new compiler for Nim and the home of the **Nim 3** language: borrow checking, explicit nilability, sum types, checked generics and more, with **incremental** and **parallel** builds from the start. For how it relates to Nim 2, see the [FAQ](faq.html).

.. raw:: html

   <div class="spice-panel" data-tabs>
     <p class="spice-kicker">Nimony for&hellip;</p>
     <div class="spice-tabs" role="tablist" aria-label="Nimony for" hidden>
       <button class="spice-tab" role="tab" id="spice-tab-embedded" aria-controls="spice-embedded" aria-selected="true">Embedded</button>
       <button class="spice-tab" role="tab" id="spice-tab-games" aria-controls="spice-games" aria-selected="false" tabindex="-1">Games</button>
       <button class="spice-tab" role="tab" id="spice-tab-fullstack" aria-controls="spice-fullstack" aria-selected="false" tabindex="-1">Full stack</button>
       <button class="spice-tab" role="tab" id="spice-tab-compiler" aria-controls="spice-compiler" aria-selected="false" tabindex="-1">Compiler devs</button>
     </div>
     <section class="spice-pane" role="tabpanel" id="spice-embedded" aria-labelledby="spice-tab-embedded">
       <p class="spice-title">Embedded development</p>
       <ul>
         <li><strong>Native code generation</strong> for x86_64, ARM64, ARM32, AVR and RISC-V &mdash; independent of LLVM and GCC, so there are fewer surprises from the implicit assumptions about C&rsquo;s undefined behavior that plague these toolchains.</li>
         <li>A runtime <strong>hardened against heap exhaustion</strong>: running out of memory is a condition you handle, not a crash.</li>
         <li>A <strong>structured, typesafe inline assembler</strong> that uses Nim&rsquo;s own syntax.</li>
         <li><strong>Memory safe</strong> thanks to optimized automatic reference counting and a variant of borrow checking that is easy to understand.</li>
         <li><strong>Provable absence of out-of-bounds indexing.</strong> Indexing into arrays, <code>seq</code>s and <code>string</code>s is a <code>requires</code> contract checked at the call site: an index that is provably out of range is a compile-time error, and a module with <code>{.feature: "staticContracts".}</code> must prove <em>every</em> access in bounds &mdash; no buffer overruns and no run-time checks left in the binary. Your own routines state their preconditions the same way.</li>
       </ul>
     </section>
     <section class="spice-pane" role="tabpanel" id="spice-games" aria-labelledby="spice-tab-games">
       <p class="spice-title">Game development</p>
       <ul>
         <li><strong>Standalone binaries</strong> optimized for your target architecture.</li>
         <li><code>.passive</code> procs turn <strong>linear code into state machines</strong> &mdash; ideal for splitting game logic across frames.</li>
         <li><strong>Mutable state</strong> is well supported, not an afterthought.</li>
         <li><strong>Short feedback loops.</strong> Incremental and parallel builds keep the edit&ndash;compile&ndash;fix cycle fast.</li>
       </ul>
     </section>
     <section class="spice-pane" role="tabpanel" id="spice-fullstack" aria-labelledby="spice-tab-fullstack">
       <p class="spice-title">Full stack development</p>
       <ul>
         <li><strong>A single language for the full stack.</strong> No matter how low level or high level your tasks are: get familiar with Nimony and end up with readable, maintainable code. The same code base compiles to C, to native code, to JavaScript and to WebAssembly &mdash; from microcontrollers to the browser.</li>
         <li><strong>Batteries included.</strong> The standard library ships what applications need: linear-time regular expressions, sockets with a TLS&nbsp;1.3 client written in Nim, an HTTP client and server, JSON and a math library.</li>
         <li><strong>The compiler as a reviewer.</strong> Generics are type checked where they are <em>defined</em>, sum types are matched exhaustively, and the borrow checker rejects mutation under active borrows. Whole classes of plausible-looking mistakes become compile errors, pointing at the line that caused them.</li>
         <li><strong>Little ceremony.</strong> Nim&rsquo;s concise, indentation-based syntax means less code to write and less code to review.</li>
       </ul>
     </section>
     <section class="spice-pane" role="tabpanel" id="spice-compiler" aria-labelledby="spice-tab-compiler">
       <p class="spice-title">Compiler and tool developers</p>
       <ul>
         <li><strong>Built around <a href="https://github.com/nim-lang/nifspec">NIF</a></strong>, an interchange format that every stage of the pipeline reads and writes. You can inspect, diff and transform the output of any stage &mdash; and it is what makes incremental and parallel builds possible.</li>
         <li><strong>Plugins</strong> go far beyond what a macro system can accomplish easily:
           <ul>
             <li><strong>Custom validators</strong> that look for possible <strong>deadlocks</strong>, <strong>race conditions</strong> or risky <strong>recursion</strong> (embedded targets often have very small stacks).</li>
             <li><strong>Custom code generators</strong> that compile a <strong>subset of Nim to GPUs</strong> or target <strong>FPGAs</strong>.</li>
             <li><strong>Custom DSLs</strong>, supported more cleanly than in Nim today &mdash; for example <strong>lexer</strong> and <strong>parser generators</strong>.</li>
           </ul>
         </li>
       </ul>
     </section>
   </div>

Here is a taste of the language.

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
