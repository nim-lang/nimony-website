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
                <button class="nav-btn" onclick="navigateToPage('$3')">News</button>
                <button class="nav-btn" onclick="navigateToPage('$4')">Manual</button>
                <button class="nav-btn" onclick="navigateToPage('$5')">Installation</button>
                <button class="nav-btn" onclick="navigateToPage('$6')">Library</button>
                <button class="nav-btn" onclick="navigateToPage('$7')">FAQ</button>
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
$8
        </main>

        <footer>
            <p>&copy; 2025 Andreas Rumpf.</p>
        </footer>
    </div>

    <script src="$9"></script>
</body>
</html>
""" % [
    siteHref(pfx, "style.css"),
    siteHref(pfx, "index.html"),
    siteHref(pfx, "index.html#news"),
    siteHref(pfx, "language.html"),
    siteHref(pfx, "install.html"),
    siteHref(pfx, "stdlib/theindex.html"),
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

proc nimonyExePath(nimonyDir: string): string =
  nimonyDir / "bin" / ("nimony" & ExeExt)

proc hasturExePath(nimonyDir: string): string =
  nimonyDir / "bin" / ("hastur" & ExeExt)

proc ensureNimonyViaHastur(nimonyDir: string): string =
  result = nimonyExePath(nimonyDir)
  if not fileExists(result):
    let hasturExe = hasturExePath(nimonyDir)
    if not fileExists(hasturExe):
      createDir(nimonyDir / "bin")
      # hastur invokes `nim c src/nifler/...`; CWD must be the nimony tree root.
      execInDir(nimonyDir, "nim c -d:release --warning[ProveInit]:off --out:bin/" &
          ("hastur" & ExeExt) & " src/hastur.nim")
    execInDir(nimonyDir, hasturExe.quoteShell & " build all")
    if not fileExists(result):
      quit "FAILURE: hastur build all did not produce " & result

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
  let nimonyExe = ensureNimonyViaHastur(nimonyDir)
  exec nimonyExe & " -f --outdir:site/stdlib doc " & nimonyDir & "/tests/nimony/stdlib/tall.nim"
  postProcessDagonDocs()
  buildLocalConfiguredDoc(nimonyDir & "/doc/language.md", "language.html", man = true)
  buildLocalConfiguredDoc(nimonyDir & "/doc/install.md", "install.html")
  exec "nim md2html -o:site/index.html content/index.md"
  exec "nim md2html -o:site/faq.html content/faq.md"

  exec "nim c -r multipage.nim site/language.html"

main()
