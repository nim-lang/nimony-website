// Theme switching functionality.
//
// The theme is always pinned as an explicit data-theme ("light" or "dark")
// rather than left unset for light, so that toggling stays in step with the
// OS preference: style.css styles a root with no data-theme as dark when the
// OS asks for dark, and without an explicit value the first click would flip
// the label without changing anything visible.
function applyTheme(theme) {
    const root = document.documentElement;
    const button = document.querySelector('.theme-switcher');

    root.setAttribute('data-theme', theme);

    if (button) {
        button.textContent = theme === 'dark' ? '🌙 Light' : '🌙 Dark';
        button.title = theme === 'dark'
            ? 'Switch to light theme'
            : 'Switch to dark theme';
    }
}

function preferredTheme() {
    const saved = localStorage.getItem('nimony-theme');
    if (saved === 'dark' || saved === 'light') return saved;
    return window.matchMedia &&
           window.matchMedia('(prefers-color-scheme: dark)').matches
        ? 'dark'
        : 'light';
}

function toggleTheme() {
    const next = document.documentElement.getAttribute('data-theme') === 'dark'
        ? 'light'
        : 'dark';
    applyTheme(next);

    // Save preference to localStorage
    localStorage.setItem('nimony-theme', next);
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
    const button = document.querySelector('button.nav-btn[onclick*="toggleNavigation"]');

    if (!hierarchy || !button) return;

    if (hierarchy.classList.contains('active')) {
        hierarchy.classList.remove('active');
        button.textContent = 'Navigation';
        button.classList.remove('expanded');
    } else {
        hierarchy.classList.add('active');
        button.textContent = 'Hide navigation';
        button.classList.add('expanded');
    }
}

// Scroll to section functionality
function scrollToSection(sectionId) {
    const section = document.getElementById(sectionId);
    if (section) {
        section.scrollIntoView({ behavior: 'smooth' });
        // Update URL with anchor
        history.pushState(null, null, `#${sectionId}`);
    }
}

// File overview functionality
function updateFileOverview() {
    const sections = document.querySelectorAll('h1, h2, h3');
    const sectionList = document.getElementById('sectionList');

    if (!sectionList) return;

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
                // Update URL with anchor
                history.pushState(null, null, `#${item.id}`);
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

// Navigation functionality
function navigateToPage(filename) {
    window.location.href = filename;
}

function getPageNavTarget(button) {
    const onclick = button.getAttribute('onclick');
    if (!onclick) return null;
    const match = onclick.match(/navigateToPage\('([^']+)'\)/);
    return match ? match[1] : null;
}

function triggerPageNavButton(button) {
    if (!button || button.classList.contains('nav-btn-disabled')) return;
    const target = getPageNavTarget(button);
    if (target) navigateToPage(target);
}

// Mark the nav chip for the page currently open, so the nav bar reads as a
// tab bar. Every page's nav is generated from a different template (nimdoc.cfg
// twice, multipage.nim, build.nim's dagon wrapper) and sits at a different
// depth under site/, so the target is resolved against the current URL rather
// than string-compared.
function markCurrentPageNav() {
    const buttons = document.querySelectorAll('.nav-controls button.nav-btn');

    buttons.forEach(function(button) {
        const target = getPageNavTarget(button);
        if (!target) return;

        const targetUrl = new URL(target, window.location.href);
        // A directory URL is served by its index.html; without this the Home
        // chip would never light up when the site is visited at its root.
        const here = window.location.pathname.endsWith('/')
            ? window.location.pathname + 'index.html'
            : window.location.pathname;
        let current = targetUrl.pathname === here;

        // The library index stands in for every module page below it.
        if (!current && targetUrl.pathname.endsWith('/theindex.html')) {
            const dir = targetUrl.pathname.slice(0, -'theindex.html'.length);
            current = here.startsWith(dir);
        }

        if (current) {
            button.classList.add('nav-btn-current');
            button.setAttribute('aria-current', 'page');
        }
    });
}

function setupPageNavKeyboard() {
    const pageNav = document.querySelector('.page-nav');
    if (!pageNav) return;

    const buttons = pageNav.querySelectorAll('button.nav-btn');
    if (buttons.length < 2) return;

    const prevBtn = buttons[0];
    const nextBtn = buttons[1];

    document.addEventListener('keydown', function(event) {
        if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;

        const target = event.target;
        const tagName = target.tagName;
        if (tagName === 'INPUT' || tagName === 'TEXTAREA' || tagName === 'SELECT' || target.isContentEditable) {
            return;
        }

        if (event.key === 'ArrowLeft') {
            if (prevBtn.classList.contains('nav-btn-disabled')) return;
            event.preventDefault();
            triggerPageNavButton(prevBtn);
        } else if (event.key === 'ArrowRight') {
            if (nextBtn.classList.contains('nav-btn-disabled')) return;
            event.preventDefault();
            triggerPageNavButton(nextBtn);
        }
    });
}

// ---------------------------------------------------------------------------
// Nightly download links.
//
// nightly.yml cuts ONE release per nimony commit, tagged
// `nightly-<version>-<short sha>`, with four assets named
// `nimony-<version>-<short>-<os>_<cpu>.<ext>`. There is deliberately no
// rolling "latest" tag — a URL someone tested keeps pointing at the build they
// tested — so the newest one has to be looked up. The `[data-nightly]` links
// therefore ship pointing at the releases page and are upgraded in place to
// direct asset URLs once the API answers. If the request fails, is rate
// limited, or JavaScript is off, the panel keeps working: the fallback href is
// the releases page, which is where the manual answer lives anyway.
// ---------------------------------------------------------------------------
const NIGHTLY_RELEASES_API =
    'https://api.github.com/repos/nim-lang/nimony-website/releases?per_page=10';

function nightlyAssetPlatform(name) {
    // `nimony-0.6.2-abc123def-linux_amd64.tar.xz` -> `linux_amd64`
    const match = name.match(/-((?:linux|macos|windows)_(?:amd64|arm64))\./);
    return match ? match[1] : null;
}

function applyNightlyRelease(release) {
    const assets = {};
    (release.assets || []).forEach(function(asset) {
        const platform = nightlyAssetPlatform(asset.name);
        if (platform) assets[platform] = asset;
    });

    let linked = 0;
    document.querySelectorAll('a[data-nightly]').forEach(function(link) {
        const asset = assets[link.getAttribute('data-nightly')];
        if (!asset) return;
        link.href = asset.browser_download_url;
        link.title = asset.name;
        linked++;
    });
    if (linked === 0) return false;

    // `nightly-0.6.2-abc123def` -> version and commit, without trusting the
    // release title, which is free text.
    const tag = (release.tag_name || '').match(/^nightly-([0-9.]+)-([0-9a-f]+)$/);
    const published = release.published_at
        ? new Date(release.published_at).toISOString().slice(0, 10)
        : null;

    document.querySelectorAll('[data-nightly-version]').forEach(function(el) {
        if (!tag) return;
        el.textContent = 'Nimony ' + tag[1] + ' — built from master @ ' +
            tag[2] + (published ? ' on ' + published : '');
    });
    return true;
}

function loadNightlyLinks() {
    if (!document.querySelector('a[data-nightly]')) return;

    fetch(NIGHTLY_RELEASES_API, { headers: { Accept: 'application/vnd.github+json' } })
        .then(function(response) {
            if (!response.ok) throw new Error('HTTP ' + response.status);
            return response.json();
        })
        .then(function(releases) {
            if (!Array.isArray(releases)) return;
            // The API orders by creation, which is NOT the order the archives
            // appear in: a run that created its release and then failed to
            // upload sits at the top of the list with zero assets, and a
            // re-run of an older commit creates nothing new. So: keep only
            // nightly tags, sort by publication date, and take the newest one
            // whose assets actually cover the platforms on this page.
            releases
                .filter(function(release) {
                    return /^nightly-/.test(release.tag_name || '') &&
                           (release.assets || []).length > 0;
                })
                .sort(function(a, b) {
                    return Date.parse(b.published_at || b.created_at || 0) -
                           Date.parse(a.published_at || a.created_at || 0);
                })
                .some(applyNightlyRelease);
        })
        .catch(function() {
            // Keep the fallback links. Nothing to report to the reader.
        });
}

// Load saved preferences and initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    // Saved preference, else whatever the OS asks for
    applyTheme(preferredTheme());

    // Load saved sidebar preference
    const savedSidebarCollapsed = localStorage.getItem('nimony-sidebar-collapsed');
    const sidebar = document.getElementById('rightSidebar');
    const toggleBtn = document.getElementById('sidebarToggle');

    if (savedSidebarCollapsed === 'true' && sidebar && toggleBtn) {
        sidebar.classList.add('collapsed');
        toggleBtn.style.display = 'block';
    }

    // Initialize file overview
    updateFileOverview();
    setupIntersectionObserver();
    setupPageNavKeyboard();
    markCurrentPageNav();
    loadNightlyLinks();

    // Update current section on scroll
    window.addEventListener('scroll', updateCurrentSection);
});
