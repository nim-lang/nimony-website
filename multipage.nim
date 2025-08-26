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
        <div class="file-overview">
            <div class="current-section" id="currentSection">Loading...</div>
        </div>
    </div>

    <!-- Toggle button for sidebar (shown when collapsed) -->
    <button class="sidebar-toggle" id="sidebarToggle" onclick="toggleSidebar()">📋</button>

    <div class="container">
        <header>
            <h1>NIMONY MANUAL - $1</h1>
            <p class="subtitle">The Complete Guide to the programming language</p>
        </header>

        <nav>
            <div class="nav-controls">
                <button class="nav-btn" onclick="toggleNavigation()">🗺️ Navigation</button>
                <button class="nav-btn" onclick="scrollToSection('language-guide')">📚 Language Guide</button>
                <button class="nav-btn" onclick="scrollToSection('standard-library')">📚 Standard Library</button>
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

proc generatePage(h1: string, head: string, content: string;
     prev, next: string) =
  inc currentPage
  let h1content = h1.innerText()
  let page = "generated/page" & combine($currentPage, "-", h1content.toFilename()) & ".html"
  writeFile(page, (mainBegin % h1content) & content & mainEnd &
            script & "\n</body>\n</html>")

proc main() =
  var inHead = true
  var head = ""
  var currentH1 = ""
  var prevH1 = ""
  var content = ""
  for line in lines("copied/htmldocs/manual.html"):
    if inHead:
      head.add line
      head.add "\n"
    if line == "</head>":
      inHead = false
    elif line.startsWith("<h1"):
      echo "h1: ", line
    elif line.startsWith("<h2"):
      generatePage(currentH1, head, content, prevH1, line)
      content.setLen 0
      prevH1 = currentH1
      currentH1 = line

    if not inHead:
      content.add line
      content.add "\n"

  generatePage(currentH1, head, content, prevH1, "")

main()
