## Build the website. Compile with `-d:local` for a local build
## that uses the Nimony sources from the sibling directory.

import std / [os, strutils]

proc exec(cmd: string) =
  if execShellCmd(cmd) != 0:
    quit "FAILURE: " & cmd

proc execInDir(dir: string; cmd: string) =
  let old = getCurrentDir()
  setCurrentDir(dir)
  try:
    exec(cmd)
  finally:
    setCurrentDir(old)

proc relToSiteRoot(path: string): string =
  let dir = path.splitFile.dir
  var rel = relativePath("site", dir).replace('\\', '/')
  if rel.len == 0: rel = "."
  rel

proc siteHref(prefix, page: string): string =
  if prefix == ".":
    page
  else:
    prefix & "/" & page

proc extractBody(html: string): string =
  let bodyStart = html.find("<body>")
  let bodyEnd = html.find("</body>")
  if bodyStart >= 0 and bodyEnd > bodyStart:
    html[bodyStart + "<body>".len ..< bodyEnd].strip()
  else:
    html

proc wrapDagonPage(path: string) =
  let raw = readFile(path)
  let content = extractBody(raw)
  let pfx = relToSiteRoot(path)

  let wrapped = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nimony Manual</title>
    <link rel="stylesheet" href="$1">
</head>
<body>
    <div class="container">
        <header>
            <h1>Nimony</h1>
            <p class="subtitle">The road to Nim 3</p>
        </header>

        <nav>
            <div class="nav-controls">
                <button class="nav-btn" onclick="navigateToPage('$2')">Home</button>
                <button class="nav-btn nav-btn-cta" onclick="navigateToPage('$3')">Download</button>
                <button class="nav-btn" onclick="navigateToPage('$4')">News</button>
                <button class="nav-btn" onclick="navigateToPage('$5')">Manual</button>
                <button class="nav-btn" onclick="navigateToPage('$6')">Library</button>
                <button class="nav-btn" onclick="navigateToPage('$7')">Tools</button>
                <button class="nav-btn" onclick="navigateToPage('$8')">FAQ</button>
                <button class="nav-btn theme-switcher" onclick="toggleTheme()">🌙 Dark</button>
            </div>
            <div class="nav-hierarchy" id="navHierarchy">
                <div class="nav-section">
                    <ul class="section-list" id="sectionList">
                    </ul>
                </div>
            </div>
        </nav>

        <main>
$9
        </main>

        <footer>
            <p>&copy; 2025 Andreas Rumpf.</p>
        </footer>
    </div>

    <script src="$10"></script>
</body>
</html>
""" % [
    siteHref(pfx, "style.css"),
    siteHref(pfx, "index.html"),
    siteHref(pfx, "download.html"),
    siteHref(pfx, "news.html"),
    siteHref(pfx, "language.html"),
    siteHref(pfx, "stdlib/theindex.html"),
    siteHref(pfx, "tools.html"),
    siteHref(pfx, "faq.html"),
    content,
    siteHref(pfx, "script.js")
  ]
  writeFile(path, wrapped)

proc postProcessDagonDocs() =
  for path in walkDirRec("site/stdlib"):
    if path.endsWith(".html"):
      wrapDagonPage(path)

proc buildArticles =
  for file in walkFiles("articles/*.md"):
    let dest = file.splitFile.name
    exec "nim md2html -o:site/" & dest & ".html " & file
  for file in walkFiles("articles/*.gif"):
    let dest = file.splitFile.name
    copyFile file, "site/" & dest & ".gif"
  # An article that ships its own images lives in a directory of its own:
  # `articles/<slug>/post.md` plus `articles/<slug>/images/*`. The page is
  # generated as `site/<slug>.html` at the site root and the images land in
  # the shared `site/images/`, so the `images/foo.png` links the author wrote
  # relative to `post.md` keep resolving in the built site. Directories
  # without a `post.md` (e.g. `articles/untracked`) are drafts and skipped.
  for dir in walkDirs("articles/*"):
    let source = dir / "post.md"
    if not fileExists(source): continue
    let dest = dir.lastPathPart
    exec "nim md2html -o:site/" & dest & ".html " & source
    let imageDir = dir / "images"
    if dirExists(imageDir):
      createDir "site/images"
      for image in walkFiles(imageDir / "*"):
        copyFile image, "site/images" / image.lastPathPart

proc buildLocalConfiguredDoc(src, dest: string; man = false) =
  let tempName = "content/tmp_" & dest.splitFile.name & ".md"
  writeFile(tempName, readFile(src))
  let manFlag = if man: " -d:man" else: ""
  try:
    exec "nim md2html" & manFlag & " -o:site/" & dest & " " & tempName
  finally:
    try:
      removeFile(tempName)
    except:
      discard

proc toolExePath(nimonyDir, tool: string): string =
  nimonyDir / "bin" / (tool & ExeExt)

## Every binary the doc build ends up shelling out to. Generating the stdlib
## docs is a FULL compile, not just a parse: `tall.nim` pulls in stdlib modules
## that use a macro plugin, so nimony compiles `lib/std/deps/smartcli.nim`
## through the entire C pipeline (nifler -> nimsem -> hexer -> cc -> niflink)
## before it can sem the modules being documented.
##
## A missing tool is not reported as a missing tool: `findTool` (src/lib/
## tooldirs.nim) falls back to the bare name, so the generated build file gets
## `hexer` instead of `<nimony>/bin/hexer` and the build dies deep inside
## nifmake with `/bin/sh: 1: hexer: not found`. That is exactly what broke CI
## while this list was maintained by hand here and drifted behind the
## compiler's pipeline.
const docTools = ["nifler", "nimsem", "nimony", "hexer", "lengc", "niflink",
                  "nifmake", "shoggoth", "validator", "dagon"]

proc ensureNimonyDocTools(nimonyDir: string): string =
  var missing: seq[string] = @[]
  for tool in docTools:
    if not fileExists(toolExePath(nimonyDir, tool)):
      missing.add tool

  if missing.len > 0:
    # Delegate to hastur — the canonical toolchain build, the same command
    # nightly.yml runs — instead of re-listing `nim c` invocations here. That
    # keeps the produced binaries in sync with whatever the compiler shells out
    # to, which a hand-written list here cannot do.
    #
    # `build all` also wants arkham + nifasm from the sibling `../nativenif`
    # checkout; it prints a skip notice and succeeds when that is absent, which
    # is the case in this repo's CI and is fine — the docs use the C backend.
    echo "[build] building the Nimony toolchain in ", nimonyDir,
         " (missing: ", missing.join(", "), ")"
    execInDir(nimonyDir, "nim c -r src/hastur/hastur --release build all")

    for tool in missing:
      if not fileExists(toolExePath(nimonyDir, tool)):
        quit "FAILURE: `hastur build all` did not produce " &
             toolExePath(nimonyDir, tool)

  result = toolExePath(nimonyDir, "nimony")

when defined(local):
  const nimonyDir = "../nimony"
else:
  const nimonyDir = "nimony"

proc main() =
  try:
    removeDir "site"
  except:
    discard "fine"
  createDir "site"
  buildArticles()
  copyFile "style.css", "site/style.css"
  copyFile "script.js", "site/script.js"
  # The header band in style.css references this by a URL relative to the
  # stylesheet, so one copy at the site root serves every page, including the
  # ones a directory down under site/stdlib. Guarded: the styling degrades to
  # its gradient scrim when the image is absent, so a checkout without the
  # asset still builds.
  if fileExists("assets/background.jpg"):
    copyFile "assets/background.jpg", "site/background.jpg"
  else:
    echo "[build] assets/background.jpg not found - header uses the gradient fallback"
  let nimonyExe = ensureNimonyDocTools(nimonyDir)
  exec nimonyExe & " -f --outdir:site/stdlib doc " & nimonyDir & "/tests/nimony/stdlib/tall.nim"
  postProcessDagonDocs()
  buildLocalConfiguredDoc(nimonyDir & "/doc/language.md", "language.html", man = true)
  buildLocalConfiguredDoc(nimonyDir & "/doc/install.md", "install.html")
  exec "nim md2html -o:site/index.html content/index.md"
  exec "nim md2html -o:site/download.html content/download.md"
  exec "nim md2html -o:site/news.html content/news.md"
  exec "nim md2html -o:site/tools.html content/tools.md"
  exec "nim md2html -o:site/faq.html content/faq.md"

  exec "nim c -r multipage.nim site/language.html"

main()
