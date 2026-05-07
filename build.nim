## Build the website. Compile with `-d:local` for a local build
## that uses the Nimony sources from the sibling directory.

import std / [os, strutils]

proc exec(cmd: string) =
  if execShellCmd(cmd) != 0:
    quit "FAILURE: " & cmd

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

when defined(local):
  copyDir "../nimony", "nimony"

try:
  removeDir "site"
except:
  discard "fine"
try:
  createDir "site"
  buildArticles()
  copyFile "style.css", "site/style.css"
  copyFile "script.js", "site/script.js"
  exec "nimony/bin/nimony -f --outdir:site/stdlib doc nimony/tests/nimony/stdlib/tall.nim"
  postProcessDagonDocs()
  exec "nim md2html -d:man -o:site/language.html nimony/doc/language.md"
  exec "nim md2html -o:site/install.html nimony/doc/install.md"
  exec "nim md2html -o:site/index.html content/index.md"
  exec "nim md2html -o:site/faq.html content/faq.md"

  exec "nim c -r multipage.nim site/language.html"
finally:
  when defined(local):
    removeDir "nimony"
