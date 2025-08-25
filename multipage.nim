## We use a simple line-based parsing solution which is only correct for Nim's HTML output.
## But that's fine for another decade or so.

import std / [syncio, strutils, parsexml, streams]

const
  mainBegin = """
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
    <script>
        // Theme switching functionality
        function toggleTheme() {
            const root = document.documentElement;
            const button = document.querySelector('.theme-switcher');

            if (root.getAttribute('data-theme') === 'dark') {
                // Switch to light theme
                root.removeAttribute('data-theme');
                button.textContent = '🌙 Dark';
                button.title = 'Switch to dark theme';
            } else {
                // Switch to dark theme
                root.setAttribute('data-theme', 'dark');
                button.textContent = '🌙 Light';
                button.title = 'Switch to light theme';
            }

            // Save preference to localStorage
            localStorage.setItem('nimony-theme', root.getAttribute('data-theme') || 'light');
        }

        // Sidebar toggle functionality
        function toggleSidebar() {
            const sidebar = document.getElementById('rightSidebar');
            const toggleBtn = document.getElementById('sidebarToggle');

            if (sidebar.classList.contains('collapsed')) {
                sidebar.classList.remove('collapsed');
                toggleBtn.style.display = 'none';
            } else {
                sidebar.classList.add('collapsed');
                toggleBtn.style.display = 'block';
            }

            // Save preference to localStorage
            localStorage.setItem('nimony-sidebar-collapsed', sidebar.classList.contains('collapsed'));
        }

        // Navigation toggle functionality
        function toggleNavigation() {
            const hierarchy = document.getElementById('navHierarchy');
            const button = document.querySelector('.nav-btn');

            if (hierarchy.classList.contains('active')) {
                hierarchy.classList.remove('active');
                button.textContent = '🗺️ Navigation';
                button.classList.remove('expanded');
            } else {
                hierarchy.classList.add('active');
                button.textContent = '🗺️ Hide Navigation';
                button.classList.add('expanded');
            }
        }

        // Scroll to section functionality
        function scrollToSection(sectionId) {
            const section = document.getElementById(sectionId);
            if (section) {
                section.scrollIntoView({ behavior: 'smooth' });
            }
        }

        // File overview functionality
        function updateFileOverview() {
            const sections = document.querySelectorAll('h1, h2, h3');
            const sectionList = document.getElementById('sectionList');
            const currentSection = document.getElementById('currentSection');

            if (!sectionList || !currentSection) return;

            // Clear existing list
            sectionList.innerHTML = '';

            // Create hierarchical structure
            const hierarchy = [];
            let currentH1 = null;
            let currentH2 = null;

            // Filter out the header h1
            const contentSections = Array.from(sections).filter(section => {
                return !(section.tagName === 'H1' && section.closest('header'));
            });

            contentSections.forEach((section, index) => {
                const sectionText = section.textContent.trim();
                const sectionId = section.id || `section-${index}`;
                const tagName = section.tagName.toLowerCase();

                if (tagName === 'h1') {
                    currentH1 = {
                        text: sectionText,
                        id: sectionId,
                        children: []
                    };
                    hierarchy.push(currentH1);
                    currentH2 = null;
                } else if (tagName === 'h2') {
                    if (currentH1) {
                        currentH2 = {
                            text: sectionText,
                            id: sectionId,
                            children: []
                        };
                        currentH1.children.push(currentH2);
                    } else {
                        // H2 without parent H1
                        currentH2 = {
                            text: sectionText,
                            id: sectionId,
                            children: []
                        };
                        hierarchy.push(currentH2);
                    }
                } else if (tagName === 'h3') {
                    const h3Item = {
                        text: sectionText,
                        id: sectionId
                    };

                    if (currentH2) {
                        currentH2.children.push(h3Item);
                    } else if (currentH1) {
                        currentH1.children.push(h3Item);
                    } else {
                        // H3 without parent H1 or H2
                        hierarchy.push(h3Item);
                    }
                }
            });

            // Build nested HTML structure
            function createListItem(item) {
                const li = document.createElement('li');
                const a = document.createElement('a');

                a.href = `#${item.id}`;
                a.textContent = item.text;
                a.title = item.text;

                // Add click handler for smooth scrolling
                a.addEventListener('click', function(e) {
                    e.preventDefault();
                    const targetSection = document.getElementById(item.id);
                    if (targetSection) {
                        targetSection.scrollIntoView({ behavior: 'smooth' });
                    }
                });

                li.appendChild(a);

                // Add nested list if there are children
                if (item.children && item.children.length > 0) {
                    const ul = document.createElement('ul');
                    item.children.forEach(child => {
                        ul.appendChild(createListItem(child));
                    });
                    li.appendChild(ul);
                }

                return li;
            }

            // Add all top-level items to the section list
            hierarchy.forEach(item => {
                sectionList.appendChild(createListItem(item));
            });

            // Update current section based on scroll position
            updateCurrentSection();
        }

        // Update current section based on scroll position
        function updateCurrentSection() {
            const sections = document.querySelectorAll('h1, h2, h3');
            const currentSection = document.getElementById('currentSection');

            if (!currentSection || sections.length === 0) return;

            const scrollPosition = window.scrollY + 100; // Offset for better detection

            let currentSectionText = 'Introduction';

            for (let i = sections.length - 1; i >= 0; i--) {
                const section = sections[i];
                const sectionTop = section.offsetTop;

                if (scrollPosition >= sectionTop) {
                    currentSectionText = section.textContent.trim();
                    break;
                }
            }

            currentSection.textContent = currentSectionText;
        }

        // Intersection Observer for better current section detection
        function setupIntersectionObserver() {
            const sections = document.querySelectorAll('h1, h2, h3');
            const currentSection = document.getElementById('currentSection');

            if (!currentSection || sections.length === 0) return;

            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        currentSection.textContent = entry.target.textContent.trim();
                    }
                });
            }, {
                rootMargin: '-20% 0px -70% 0px'
            });

            sections.forEach(section => observer.observe(section));
        }

        // Load saved preferences and initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            // Load saved theme preference
            const savedTheme = localStorage.getItem('nimony-theme');
            const button = document.querySelector('.theme-switcher');

            if (savedTheme === 'dark') {
                document.documentElement.setAttribute('data-theme', 'dark');
                button.textContent = '🌙 Light';
                button.title = 'Switch to light theme';
            } else {
                button.textContent = '🌙 Dark';
                button.title = 'Switch to dark theme';
            }

            // Load saved sidebar preference
            const savedSidebarCollapsed = localStorage.getItem('nimony-sidebar-collapsed');
            const sidebar = document.getElementById('rightSidebar');
            const toggleBtn = document.getElementById('sidebarToggle');

            if (savedSidebarCollapsed === 'true') {
                sidebar.classList.add('collapsed');
                toggleBtn.style.display = 'block';
            }

            // Initialize file overview
            updateFileOverview();
            setupIntersectionObserver();

            // Update current section on scroll
            window.addEventListener('scroll', updateCurrentSection);
        });
    </script>
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

proc generatePage(h1: string, head: string, content: string;
     prev, next: string) =
  inc currentPage
  let h1content = h1.innerText()
  let page = "generated/page" & $currentPage & "-" & h1content.toFilename() & ".html"
  writeFile(page, head & "\n<body>\n" & (mainBegin % h1content) & content & mainEnd &
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
