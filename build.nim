## Build the website for local testing purposes

import std / os

proc exec(cmd: string) =
  if execShellCmd(cmd) != 0:
    quit "FAILURE: " & cmd

copyDir "../nimony", "nimony"
try:
  createDir "site"
  copyFile "style.css", "site/style.css"
  copyFile "script.js", "site/script.js"
  exec "nim c -r nimony/tools/dagon.nim nimony/doc/stdlib.dgn.md"
  exec "nim md2html -o:site/manual.html nimony/doc/manual.md"
  exec "nim c -r multipage.nim site/manual.html"
finally:
  removeDir "nimony"
