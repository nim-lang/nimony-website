## Build the website. Compile with `-d:local` for a local build
## that uses the Nimony sources from the sibling directory.

import std / os

proc exec(cmd: string) =
  if execShellCmd(cmd) != 0:
    quit "FAILURE: " & cmd

proc buildArticles =
  for file in walkFiles("articles/*.md"):
    let dest = file.splitFile.name
    exec "nim md2html -o:site/" & dest & ".html " & file

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
  exec "nim c -r nimony/tools/dagon.nim nimony/doc/stdlib.dgn.md"
  exec "nim md2html -d:man -o:site/manual.html nimony/doc/manual.md"
  exec "nim md2html -o:site/index.html content/index.md"

  exec "nim c -r multipage.nim site/manual.html"
finally:
  when defined(local):
    removeDir "nimony"
