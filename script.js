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
        // Update URL with anchor
        history.pushState(null, null, `#${sectionId}`);
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

// Load saved preferences and initialize on page load
document.addEventListener('DOMContentLoaded', function() {
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
