## We use a simple line-based parsing solution which is only correct for Nim's HTML output.
## But that's fine for another decade or so.

import std / [syncio, strutils, os, parsexml, streams]

const
  mainBegin = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nimony Manual</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <header class="nav-controls" style="font-size: smaller;">
            <button class="nav-btn" onclick="navigateToPage('manual.html')">Single Page</button>
            <button class="nav-btn" onclick="navigateToPage('stdlib/theindex.html')">Library</button>
            <button class="nav-btn" onclick="navigateToPage('faq.html')">FAQ</button>
            <button class="nav-btn theme-switcher" onclick="toggleTheme()">🌙 Dark</button>
            <h1>Nimony Manual</h1>
        </header>

        <main>
"""
  mainEnd = """
        </main>
        <footer class="page-nav" style="display: flex; justify-content: center; gap: 1rem; margin: 2rem 0 1rem;">
            <button class="$1" onclick="navigateToPage('$2')">← Prev</button>
            <button class="$3" onclick="navigateToPage('$4')">Next →</button>
        </footer>
    </div>
"""
  script = """
    <script src="script.js"></script>
"""

proc innerText(s: string): string =
  var s = newStringStream(s)
  var x: XmlParser
  open(x, s, "dummy")
  next(x) # get first event
  result = ""
  var inTag = ""
  try:
    while true:
      case x.kind
      of xmlElementStart, xmlElementOpen:
        if inTag == "": inTag = x.elementName
      of xmlElementEnd:
        if cmpIgnoreCase(x.elementName, inTag) == 0: break
        result.add ' '
      of xmlCharData, xmlWhitespace, xmlSpecial:
        if inTag.len > 0:
          result.add(x.charData)
      of xmlEof: break # end of file reached
      else: discard
      x.next()
  finally:
    x.close()

var currentPage = 0

proc toFilename(s: string): string =
  result = newStringOfCap(s.len)
  var pendingDash = false
  for c in s:
    if pendingDash:
      if result.len > 0 and result[^1] != '-':
        result.add "-"
      pendingDash = false
    case c
    of 'A'..'Z': result.add toLowerAscii(c)
    of 'a'..'z', '0'..'9': result.add c
    else: pendingDash = true

proc combine(a, sep, b: string): string =
  result = a
  if b.len > 0:
    result.add sep
    result.add b

proc pageName(page: int, h1: string): string =
  combine("page" & $page, "-", h1.toFilename()) & ".html"

proc generatePage(destDir, h1: string, content: string;
     prev, next: string) =
  inc currentPage
  let h1content = h1.innerText()
  let page = destDir / pageName(currentPage, h1content)

  let n = if next.len > 0: "nav-btn" else: "nav-btn nav-btn-disabled"
  let p = if currentPage > 1: "nav-btn" else: "nav-btn nav-btn-disabled"

  let endStr = mainEnd % [
    p, pageName(currentPage - 1, prev.innerText()),
    n, pageName(currentPage + 1, next.innerText())
  ]

  writeFile(page, mainBegin & content & endStr &
            script & "\n</body>\n</html>")

proc main(manual: string) =
  let destDir = manual.splitFile().dir
  var inHead = true
  var currentH1 = ""
  var prevH1 = ""
  var content = ""
  for line in lines(manual):
    var i = 0
    while i < line.len and line[i] == ' ': inc i
    if line.continuesWith("<main>", i):
      # Just enter body mode — the source `<main>` (and its closer) are
      # discarded so they don't double up with the wrapper's `<main>` /
      # `</main>` and produce a nested-box border.
      inHead = false
      continue
    if line.continuesWith("</main>", i):
      break
    if line.startsWith("<h1") and currentPage > 0:
      generatePage(destDir, currentH1, content, prevH1, line)
      content.setLen 0
      prevH1 = currentH1
      currentH1 = line
    elif line.startsWith("<h2") and content.len > 600:
      generatePage(destDir, currentH1, content, prevH1, line)
      content.setLen 0
      prevH1 = currentH1
      currentH1 = line

    if not inHead:
      content.add line
      content.add "\n"

  generatePage(destDir, currentH1, content, prevH1, "")

main(paramStr(1))
