## We use a simple line-based parsing solution which is only correct for Nim's HTML output.
## But that's fine for another decade or so.

import std / [syncio, strutils, parsexml, streams]

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
    <!-- Right sidebar with theme switcher and file overview -->
    <div class="right-sidebar" id="rightSidebar">
        <button class="theme-switcher" onclick="toggleTheme()">🌙 Dark</button>

        <button class="$1" onclick="navigateToPage('$2')"> → Next</button>
        <button class="$3" onclick="navigateToPage('$4')"> ← Prev</button>
    </div>

    <!-- Toggle button for sidebar (shown when collapsed) -->
    <button class="sidebar-toggle" id="sidebarToggle" onclick="toggleSidebar()">📋</button>

    <div class="container">
        <header>
            <h1>NIMONY MANUAL - $5</h1>
            <p class="subtitle">The Complete Guide to the programming language</p>
        </header>

        <nav>
            <div class="nav-controls">
                <button class="nav-btn" onclick="toggleNavigation()">🗺️ Navigation</button>
            </div>
            <div class="nav-hierarchy" id="navHierarchy">
                <div class="nav-section">
                    <ul class="section-list" id="sectionList">
                        <!-- Sections will be populated by JavaScript -->
                    </ul>
                </div>
            </div>
        </nav>

        <main>
"""
  mainEnd = """
        </main>
        <footer>
            <p>&copy; 2025 Andreas Rumpf. This manual is a work in progress.</p>
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

proc generatePage(h1: string, content: string;
     prev, next: string) =
  inc currentPage
  let h1content = h1.innerText()
  let page = "copied/htmldocs/" & pageName(currentPage, h1content)

  let n = if next.len > 0: "theme-switcher" else: "theme-switcher-disabled"
  let p = if currentPage > 1: "theme-switcher" else: "theme-switcher-disabled"

  let main = mainBegin % [
    n, pageName(currentPage + 1, next.innerText()),
    p, pageName(currentPage - 1, prev.innerText()),
    h1content
  ]

  writeFile(page, main & content & mainEnd &
            script & "\n</body>\n</html>")

proc main() =
  var inHead = true
  var currentH1 = ""
  var prevH1 = ""
  var content = ""
  for line in lines("copied/htmldocs/manual.html"):
    var i = 0
    while i < line.len and line[i] == ' ': inc i
    if line.continuesWith("<main>", i):
      inHead = false
    elif line.startsWith("<h1"):
      echo "h1: ", line
    elif line.startsWith("<h2"):
      generatePage(currentH1, content, prevH1, line)
      content.setLen 0
      prevH1 = currentH1
      currentH1 = line

    if not inHead:
      content.add line
      content.add "\n"

  generatePage(currentH1, content, prevH1, "")

main()
