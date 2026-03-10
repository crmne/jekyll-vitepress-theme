(function () {
  'use strict';

  var storageKey = 'vitepress-theme-appearance';
  var mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
  var root = document.documentElement;
  var validModes = ['auto', 'dark', 'light'];

  function normalizeMode(mode) {
    return validModes.indexOf(mode) >= 0 ? mode : 'auto';
  }

  function readMode() {
    try {
      return normalizeMode(localStorage.getItem(storageKey) || 'auto');
    } catch (error) {
      return 'auto';
    }
  }

  function writeMode(mode) {
    var normalizedMode = normalizeMode(mode);
    try {
      if (normalizedMode === 'auto') {
        localStorage.removeItem(storageKey);
      } else {
        localStorage.setItem(storageKey, normalizedMode);
      }
    } catch (error) {
      // Ignore storage errors.
    }
  }

  function getAppearanceLabel(mode, isDark) {
    if (mode === 'dark') {
      return 'Appearance: Dark (forced). Click to force light.';
    }

    if (mode === 'light') {
      return 'Appearance: Light (forced). Click to follow system.';
    }

    return isDark
      ? 'Appearance: Auto (system dark). Click to force dark.'
      : 'Appearance: Auto (system light). Click to force dark.';
  }

  function applyMode(mode) {
    var normalizedMode = normalizeMode(mode);
    var dark = normalizedMode === 'dark' || (normalizedMode === 'auto' && mediaQuery.matches);
    root.classList.toggle('dark', dark);
    root.classList.toggle('light', !dark);
    root.setAttribute('data-appearance-mode', normalizedMode);

    document.querySelectorAll('.theme-toggle').forEach(function (toggle) {
      toggle.setAttribute('aria-checked', String(dark));
      toggle.setAttribute('data-appearance-mode', normalizedMode);
      toggle.setAttribute('title', getAppearanceLabel(normalizedMode, dark));
      toggle.setAttribute('aria-label', getAppearanceLabel(normalizedMode, dark));
    });

    window.dispatchEvent(new CustomEvent('vp:appearance-change', { detail: { dark: dark, mode: normalizedMode } }));
  }

  var mode = readMode();
  applyMode(mode);

  function cycleMode() {
    if (mode === 'auto') {
      mode = 'dark';
    } else if (mode === 'dark') {
      mode = 'light';
    } else {
      mode = 'auto';
    }
    writeMode(mode);
    applyMode(mode);
  }

  document.querySelectorAll('.theme-toggle').forEach(function (toggle) {
    toggle.addEventListener('click', function (event) {
      if (event.altKey) {
        mode = 'auto';
        writeMode(mode);
        applyMode(mode);
        return;
      }

      cycleMode();
    });
  });

  if (typeof mediaQuery.addEventListener === 'function') {
    mediaQuery.addEventListener('change', function () {
      if (mode === 'auto') {
        applyMode('auto');
      }
    });
  }

  window.__vpAppearance = {
    getMode: function () {
      return mode;
    },
    setMode: function (nextMode) {
      mode = normalizeMode(nextMode);
      writeMode(mode);
      applyMode(mode);
    },
    clearMode: function () {
      mode = 'auto';
      writeMode(mode);
      applyMode(mode);
    }
  };

  var navBar = document.getElementById('vp-nav-bar');
  var sidebar = document.getElementById('vp-sidebar');
  var backdrop = document.getElementById('vp-backdrop');
  var hamburger = document.getElementById('vp-nav-hamburger');
  var localMenuButton = document.getElementById('vp-local-menu-button');
  var navScreen = document.getElementById('VPNavScreen');
  var versionSelector = document.getElementById('vp-version-selector');
  var versionButton = document.getElementById('vp-version-button');
  var versionMenu = document.getElementById('vp-version-menu');

  var menuOpen = false;
  var versionOpen = false;

  function setVersionOpen(open) {
    if (!versionSelector || !versionButton || !versionMenu) {
      versionOpen = false;
      return;
    }

    versionOpen = open;
    versionSelector.classList.toggle('open', open);
    versionButton.setAttribute('aria-expanded', String(open));
    versionMenu.hidden = !open;
  }

  if (versionButton && versionMenu) {
    versionButton.addEventListener('click', function (event) {
      event.preventDefault();
      event.stopPropagation();
      setVersionOpen(!versionOpen);
    });

    versionMenu.addEventListener('click', function (event) {
      if (event.target.closest('a')) {
        setVersionOpen(false);
      }
    });

    document.addEventListener('click', function (event) {
      if (versionOpen && versionSelector && !versionSelector.contains(event.target)) {
        setVersionOpen(false);
      }
    });
  }

  function setMenuOpen(open) {
    menuOpen = open;

    if (open && versionOpen) {
      setVersionOpen(false);
    }

    if (sidebar) {
      sidebar.classList.toggle('open', open);
    }

    if (navBar) {
      navBar.classList.toggle('screen-open', open);
    }

    if (backdrop) {
      backdrop.classList.toggle('is-active', open);
    }

    if (hamburger) {
      hamburger.classList.toggle('active', open);
      hamburger.setAttribute('aria-expanded', String(open));
    }

    if (localMenuButton) {
      localMenuButton.setAttribute('aria-expanded', String(open));
    }

    if (navScreen) {
      navScreen.hidden = !open;
    }

    document.body.classList.toggle('vp-nav-screen-open', open);
  }

  function toggleMenu() {
    setMenuOpen(!menuOpen);
  }

  if (hamburger) {
    hamburger.addEventListener('click', toggleMenu);
  }

  if (localMenuButton) {
    localMenuButton.addEventListener('click', toggleMenu);
  }

  if (backdrop) {
    backdrop.addEventListener('click', function () {
      setMenuOpen(false);
    });
  }

  if (navScreen) {
    navScreen.addEventListener('click', function (event) {
      if (event.target === navScreen || event.target.closest('a')) {
        setMenuOpen(false);
      }
    });
  }

  window.addEventListener('resize', function () {
    if (window.innerWidth >= 768 && menuOpen) {
      setMenuOpen(false);
    }
    if (window.innerWidth < 768 && versionOpen) {
      setVersionOpen(false);
    }
  });

  function syncNavTop() {
    if (!navBar) {
      return;
    }
    navBar.classList.toggle('top', window.scrollY < 4);
  }

  syncNavTop();
  window.addEventListener('scroll', syncNavTop, { passive: true });

  document.querySelectorAll('.VPSidebarItem.level-0.collapsible').forEach(function (section) {
    var item = section.querySelector(':scope > .item');
    var caret = section.querySelector(':scope > .item .caret');

    function toggleSection() {
      section.classList.toggle('collapsed');
    }

    if (item) {
      item.addEventListener('click', function (event) {
        if (event.target.closest('a')) {
          return;
        }
        toggleSection();
      });

      item.addEventListener('keydown', function (event) {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          toggleSection();
        }
      });
    }

    if (caret) {
      caret.addEventListener('click', function (event) {
        event.stopPropagation();
        toggleSection();
      });
      caret.addEventListener('keydown', function (event) {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          event.stopPropagation();
          toggleSection();
        }
      });
    }
  });

  var searchRoot = document.getElementById('vp-search');
  var searchButton = document.getElementById('vp-search-button');
  var searchBackdrop = document.getElementById('vp-search-backdrop');
  var searchInput = document.getElementById('vp-search-input');
  var searchResults = document.getElementById('vp-search-results');
  var searchIndexUrl = searchRoot ? searchRoot.getAttribute('data-search-index-url') : null;

  var searchOpen = false;
  var searchItems = [];
  var searchIndexPromise = null;
  var activeResultIndex = -1;

  function loadSearchIndex() {
    if (!searchIndexUrl) {
      return Promise.resolve([]);
    }

    if (searchItems.length > 0) {
      return Promise.resolve(searchItems);
    }

    if (searchIndexPromise) {
      return searchIndexPromise;
    }

    searchIndexPromise = fetch(searchIndexUrl, { credentials: 'same-origin' })
      .then(function (response) {
        if (!response.ok) {
          throw new Error('Search index load failed');
        }
        return response.json();
      })
      .then(function (items) {
        if (Array.isArray(items)) {
          searchItems = items;
        }
        return searchItems;
      })
      .catch(function () {
        searchItems = [];
        return searchItems;
      });

    return searchIndexPromise;
  }

  function escapeHtml(value) {
    return String(value || '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  function scoreSearchItem(item, terms, query) {
    var title = String(item.title || '').toLowerCase();
    var content = String(item.content || '').toLowerCase();

    var score = 0;
    for (var i = 0; i < terms.length; i += 1) {
      var term = terms[i];
      var titleIndex = title.indexOf(term);
      var contentIndex = content.indexOf(term);

      if (titleIndex < 0 && contentIndex < 0) {
        return -1;
      }

      if (titleIndex >= 0) {
        score += titleIndex === 0 ? 100 : 40;
      }

      if (contentIndex >= 0) {
        score += contentIndex < 120 ? 20 : 10;
      }
    }

    if (title.indexOf(query) >= 0) {
      score += 60;
    }

    return score;
  }

  function buildSnippet(item, terms) {
    var content = String(item.content || '').replace(/\s+/g, ' ').trim();
    if (!content) {
      return '';
    }

    var lower = content.toLowerCase();
    var index = -1;

    for (var i = 0; i < terms.length; i += 1) {
      var hit = lower.indexOf(terms[i]);
      if (hit >= 0 && (index < 0 || hit < index)) {
        index = hit;
      }
    }

    if (index < 0) {
      index = 0;
    }

    var start = Math.max(0, index - 60);
    var end = Math.min(content.length, start + 180);
    var snippet = content.slice(start, end).trim();

    if (start > 0) {
      snippet = '... ' + snippet;
    }

    if (end < content.length) {
      snippet += ' ...';
    }

    return snippet;
  }

  function setActiveSearchResult(index) {
    if (!searchResults) {
      return;
    }

    var links = Array.from(searchResults.querySelectorAll('.VPSearchResult'));
    if (!links.length) {
      activeResultIndex = -1;
      return;
    }

    activeResultIndex = Math.max(0, Math.min(index, links.length - 1));

    links.forEach(function (link, linkIndex) {
      var active = linkIndex === activeResultIndex;
      link.classList.toggle('active', active);
      if (active) {
        link.scrollIntoView({ block: 'nearest' });
      }
    });
  }

  function renderSearchResults(query) {
    if (!searchResults) {
      return;
    }

    var normalized = String(query || '').trim().toLowerCase();

    if (!normalized) {
      searchResults.innerHTML = '<p class="VPSearchEmpty">Type to search documentation</p>';
      activeResultIndex = -1;
      return;
    }

    var terms = normalized.split(/\s+/).filter(Boolean);

    var ranked = searchItems
      .map(function (item) {
        return {
          item: item,
          score: scoreSearchItem(item, terms, normalized)
        };
      })
      .filter(function (entry) {
        return entry.score >= 0;
      })
      .sort(function (a, b) {
        return b.score - a.score;
      })
      .slice(0, 20);

    if (!ranked.length) {
      searchResults.innerHTML = '<p class="VPSearchEmpty">No matches found</p>';
      activeResultIndex = -1;
      return;
    }

    var html = ranked
      .map(function (entry) {
        var item = entry.item;
        var title = escapeHtml(item.title || item.url || 'Untitled');
        var url = escapeHtml(item.url || '/');
        var snippet = escapeHtml(buildSnippet(item, terms));

        return (
          '<a class="VPSearchResult" role="option" href="' +
          url +
          '">' +
          '<span class="title">' +
          title +
          '</span>' +
          '<span class="snippet">' +
          snippet +
          '</span>' +
          '</a>'
        );
      })
      .join('');

    searchResults.innerHTML = html;
    setActiveSearchResult(0);
  }

  function closeSearch() {
    if (!searchRoot) {
      return;
    }

    searchOpen = false;
    searchRoot.hidden = true;
    document.body.classList.remove('vp-search-open');

    if (searchButton) {
      searchButton.setAttribute('aria-expanded', 'false');
    }
  }

  function openSearch() {
    if (!searchRoot || !searchInput) {
      return;
    }

    if (versionOpen) {
      setVersionOpen(false);
    }

    if (menuOpen) {
      setMenuOpen(false);
    }

    searchOpen = true;
    searchRoot.hidden = false;
    document.body.classList.add('vp-search-open');

    if (searchButton) {
      searchButton.setAttribute('aria-expanded', 'true');
    }

    loadSearchIndex().then(function () {
      renderSearchResults(searchInput.value);
    });

    window.requestAnimationFrame(function () {
      searchInput.focus();
      searchInput.select();
    });
  }

  if (searchButton) {
    searchButton.addEventListener('click', function () {
      if (searchOpen) {
        closeSearch();
      } else {
        openSearch();
      }
    });
  }

  if (searchBackdrop) {
    searchBackdrop.addEventListener('click', closeSearch);
  }

  if (searchResults) {
    searchResults.addEventListener('click', function (event) {
      if (event.target.closest('a')) {
        closeSearch();
      }
    });
  }

  if (searchInput) {
    searchInput.addEventListener('input', function (event) {
      renderSearchResults(event.target.value);
    });

    searchInput.addEventListener('keydown', function (event) {
      if (event.key === 'ArrowDown') {
        event.preventDefault();
        setActiveSearchResult(activeResultIndex + 1);
        return;
      }

      if (event.key === 'ArrowUp') {
        event.preventDefault();
        setActiveSearchResult(activeResultIndex - 1);
        return;
      }

      if (event.key === 'Enter') {
        var links = searchResults ? Array.from(searchResults.querySelectorAll('.VPSearchResult')) : [];
        if (links.length && activeResultIndex >= 0) {
          window.location.href = links[activeResultIndex].getAttribute('href');
        }
      }
    });
  }

  function shouldOpenSearchFromKeyboard(event) {
    if (event.defaultPrevented || event.metaKey || event.ctrlKey || event.altKey || event.shiftKey) {
      return false;
    }

    var target = event.target;
    if (!target) {
      return true;
    }

    var tagName = String(target.tagName || '').toLowerCase();
    if (tagName === 'input' || tagName === 'textarea' || tagName === 'select') {
      return false;
    }

    if (target.isContentEditable) {
      return false;
    }

    return event.key === '/';
  }

  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') {
      if (searchOpen) {
        event.preventDefault();
        closeSearch();
        return;
      }

      if (versionOpen) {
        event.preventDefault();
        setVersionOpen(false);
        return;
      }

      setMenuOpen(false);
      return;
    }

    var isSearchShortcut = (event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k';
    if (isSearchShortcut) {
      event.preventDefault();
      if (versionOpen) {
        setVersionOpen(false);
      }
      openSearch();
      return;
    }

    if (shouldOpenSearchFromKeyboard(event)) {
      event.preventDefault();
      if (versionOpen) {
        setVersionOpen(false);
      }
      openSearch();
    }
  });

  function writeToClipboard(text) {
    if (navigator.clipboard && typeof navigator.clipboard.writeText === 'function') {
      return navigator.clipboard.writeText(text);
    }

    return new Promise(function (resolve, reject) {
      try {
        var textarea = document.createElement('textarea');
        textarea.value = text;
        textarea.setAttribute('readonly', '');
        textarea.style.position = 'fixed';
        textarea.style.top = '-9999px';
        document.body.appendChild(textarea);
        textarea.select();

        var copied = document.execCommand('copy');
        document.body.removeChild(textarea);

        if (copied) {
          resolve();
        } else {
          reject(new Error('Copy command failed'));
        }
      } catch (error) {
        reject(error);
      }
    });
  }

  var fileIconAliases = {
    rb: 'ruby',
    rake: 'ruby',
    erb: 'ruby',
    ruby: 'ruby',

    js: 'javascript',
    mjs: 'javascript',
    cjs: 'javascript',
    jsx: 'javascript',
    javascript: 'javascript',

    ts: 'typescript',
    mts: 'typescript',
    cts: 'typescript',
    tsx: 'typescript',
    typescript: 'typescript',

    json: 'json',
    jsonc: 'json',
    json5: 'json',

    md: 'markdown',
    markdown: 'markdown',
    mdx: 'markdown',

    html: 'html',
    htm: 'html',

    css: 'css',
    scss: 'css',
    sass: 'css',
    less: 'css',

    vue: 'vue',
    yml: 'yaml',
    yaml: 'yaml',
    toml: 'toml',

    sh: 'shell',
    bash: 'shell',
    zsh: 'shell',
    fish: 'shell',
    shell: 'shell',

    py: 'python',
    python: 'python',

    go: 'go',
    golang: 'go',
    rs: 'rust',
    rust: 'rust',
    java: 'java',

    kt: 'kotlin',
    kts: 'kotlin',
    kotlin: 'kotlin',

    php: 'php',
    sql: 'sql',
    xml: 'xml',

    docker: 'docker',
    dockerfile: 'docker',
    containerfile: 'docker',

    make: 'make',
    makefile: 'make',

    env: 'env',
    '.env': 'env',

    txt: 'text',
    text: 'text',
    plaintext: 'text'
  };

  var specialFileIconAliases = {
    gemfile: 'ruby',
    rakefile: 'ruby',
    '.ruby-version': 'ruby',
    dockerfile: 'docker',
    containerfile: 'docker',
    makefile: 'make',
    '.env': 'env'
  };

  function normalizeFileIconKey(value) {
    var key = (value || '').toLowerCase().trim();
    return fileIconAliases[key] || '';
  }

  function inferFileIconFromTitle(title) {
    var raw = (title || '').trim().toLowerCase();
    if (!raw) {
      return '';
    }

    var clean = raw.split(/[?#]/)[0];
    var base = clean.split('/').pop();
    if (!base) {
      return '';
    }

    var directMatch = specialFileIconAliases[base];
    if (directMatch) {
      return directMatch;
    }

    if (base.indexOf('.env.') === 0) {
      return 'env';
    }

    var dotIndex = base.lastIndexOf('.');
    if (dotIndex > 0 && dotIndex < base.length - 1) {
      var ext = base.slice(dotIndex + 1);
      return normalizeFileIconKey(ext);
    }

    return normalizeFileIconKey(base);
  }

  function inferFileIconFromLanguage(language) {
    return normalizeFileIconKey(language);
  }

  function addCopyButtons() {
    document.querySelectorAll('.vp-doc div.highlighter-rouge').forEach(function (block) {
      var code = block.querySelector('pre code');
      if (!code) {
        return;
      }

      var button = block.querySelector(':scope > button.copy');
      if (!button) {
        button = document.createElement('button');
        button.className = 'copy';
        button.type = 'button';
        block.insertBefore(button, block.firstChild);
      }
      button.setAttribute('aria-label', 'Copy code');
      button.setAttribute('title', 'Copy code');

      var language = '';
      Array.from(block.classList).forEach(function (className) {
        if (!language && className.indexOf('language-') === 0) {
          language = className.slice(9).trim().toLowerCase();
        }
      });
      if (language === 'plaintext') {
        language = 'text';
      }

      var languageTag = block.querySelector(':scope > span.lang');
      if (!languageTag && language) {
        languageTag = document.createElement('span');
        languageTag.className = 'lang';
        languageTag.textContent = language;
        if (button.nextSibling) {
          block.insertBefore(languageTag, button.nextSibling);
        } else {
          block.appendChild(languageTag);
        }
      }

      var title = block.getAttribute('data-title') || '';
      if (!title) {
        var previous = block.previousElementSibling;
        if (previous && previous.classList.contains('vp-code-title')) {
          title = previous.textContent ? previous.textContent.trim() : '';
          previous.remove();
        }
      }

      if (title && (!block.parentElement || !block.parentElement.classList.contains('vp-code-block-title'))) {
        var wrapper = document.createElement('div');
        wrapper.className = 'vp-code-block-title';

        var iconKey = inferFileIconFromTitle(title) || inferFileIconFromLanguage(language) || 'default';
        var titleBar = document.createElement('div');
        titleBar.className = 'vp-code-block-title-bar';

        var titleText = document.createElement('span');
        titleText.className = 'vp-code-block-title-text';
        titleText.setAttribute('data-title', title);
        if (iconKey) {
          titleText.setAttribute('data-icon', iconKey);
        }
        titleText.textContent = title;

        titleBar.appendChild(titleText);

        var parent = block.parentNode;
        if (parent) {
          parent.insertBefore(wrapper, block);
          wrapper.appendChild(titleBar);
          wrapper.appendChild(block);
          block.classList.add('has-title');
        }
      }

      button.addEventListener('click', function () {
        var text = code.textContent || '';

        writeToClipboard(text)
          .then(function () {
            button.classList.add('copied');
            if (button._copyTimeout) {
              window.clearTimeout(button._copyTimeout);
            }
            button._copyTimeout = window.setTimeout(function () {
              button.classList.remove('copied');
            }, 2000);
          })
          .catch(function () {
            // Ignore copy errors so UI remains interactive.
          });
      });
    });
  }

  addCopyButtons();

  var content = document.querySelector('.vp-doc');
  if (!content) {
    return;
  }

  content.querySelectorAll('h1[id], h2[id], h3[id], h4[id], h5[id], h6[id]').forEach(function (heading) {
    if (heading.querySelector('.header-anchor')) {
      return;
    }

    var title = heading.textContent ? heading.textContent.trim() : heading.id;
    var anchor = document.createElement('a');
    anchor.className = 'header-anchor';
    anchor.href = '#' + heading.id;
    anchor.setAttribute('aria-label', 'Permalink to "' + title + '"');
    anchor.textContent = '\u200B';

    heading.appendChild(document.createTextNode(' '));
    heading.appendChild(anchor);
  });

  var headings = Array.from(content.querySelectorAll('h2[id], h3[id]'));
  var asideOutline = document.querySelector('.VPDocAsideOutline');
  var localNav = document.getElementById('vp-local-nav');
  var localOutlineDropdown = document.getElementById('vp-local-outline-dropdown');

  var localOutlineButton = document.getElementById('vp-local-outline-button');
  var localOutlineItems = document.querySelector('#vp-local-outline-dropdown .items');
  var localOutlineContainer = document.querySelector('#vp-local-outline-dropdown .outline .VPDocOutlineItem');
  var localTopLink = document.getElementById('vp-local-top-link');
  var returnToTopLabel = (localTopLink && localTopLink.textContent ? localTopLink.textContent.trim() : 'Return to top');

  function syncLocalOutlineViewportHeight() {
    if (!localOutlineDropdown) {
      return;
    }

    var viewportHeight = window.innerHeight;
    if (window.visualViewport && window.visualViewport.height) {
      viewportHeight = window.visualViewport.height;
    }

    localOutlineDropdown.style.setProperty('--vp-vh', String(Math.round(viewportHeight)) + 'px');
  }

  syncLocalOutlineViewportHeight();
  window.addEventListener('resize', syncLocalOutlineViewportHeight, { passive: true });
  if (window.visualViewport && typeof window.visualViewport.addEventListener === 'function') {
    window.visualViewport.addEventListener('resize', syncLocalOutlineViewportHeight, { passive: true });
  }

  function createOutlineTree(list) {
    var tree = [];
    var currentGroup = null;

    list.forEach(function (heading) {
      if (heading.tagName === 'H2') {
        currentGroup = {
          heading: heading,
          children: []
        };
        tree.push(currentGroup);
        return;
      }

      if (!currentGroup) {
        currentGroup = {
          heading: heading,
          children: []
        };
        tree.push(currentGroup);
        return;
      }

      currentGroup.children.push({
        heading: heading,
        children: []
      });
    });

    return tree;
  }

  function buildOutlineNodes(entries, isRoot) {
    var ul = document.createElement('ul');
    ul.className = 'VPDocOutlineItem ' + (isRoot ? 'root' : 'nested');

    entries.forEach(function (entry) {
      if (!entry.heading) {
        return;
      }

      var li = document.createElement('li');
      var link = document.createElement('a');
      var label = entry.heading.textContent ? entry.heading.textContent.trim() : entry.heading.id;

      link.className = 'outline-link';
      link.href = '#' + entry.heading.id;
      link.title = label;
      link.textContent = label;

      li.appendChild(link);

      if (entry.children && entry.children.length) {
        li.appendChild(buildOutlineNodes(entry.children, false));
      }

      ul.appendChild(li);
    });

    return ul;
  }

  function replaceOutline(selector, tree, isRoot) {
    var target = document.querySelector(selector);
    if (!target) {
      return;
    }

    target.innerHTML = '';
    var outline = buildOutlineNodes(tree, isRoot);

    while (outline.firstChild) {
      target.appendChild(outline.firstChild);
    }
  }

  var hasOutline = headings.length > 0;

  if (!hasOutline) {
    if (asideOutline) {
      asideOutline.classList.remove('has-outline');
    }

    if (localNav) {
      localNav.classList.add('empty');
    }

    if (localOutlineButton) {
      var text = localOutlineButton.querySelector('.menu-text');
      var icon = localOutlineButton.querySelector('.icon');
      if (text) {
        text.textContent = returnToTopLabel;
      }
      if (icon) {
        icon.style.display = 'none';
      }
    }
  } else {
    var tree = createOutlineTree(headings);
    replaceOutline('.VPDocAsideOutline .VPDocOutlineItem.root', tree, true);
    replaceOutline('#vp-local-outline-dropdown .outline .VPDocOutlineItem', tree, true);
  }

  var localOutlineOpen = false;

  function closeLocalOutline() {
    localOutlineOpen = false;
    if (localOutlineItems) {
      localOutlineItems.hidden = true;
    }
    if (localOutlineButton) {
      localOutlineButton.classList.remove('open');
      localOutlineButton.setAttribute('aria-expanded', 'false');
    }
  }

  if (localOutlineButton) {
    localOutlineButton.setAttribute('aria-expanded', 'false');

    localOutlineButton.addEventListener('click', function () {
      if (!hasOutline) {
        window.scrollTo({ top: 0, left: 0, behavior: 'smooth' });
        return;
      }

      localOutlineOpen = !localOutlineOpen;
      if (localOutlineItems) {
        localOutlineItems.hidden = !localOutlineOpen;
      }
      localOutlineButton.classList.toggle('open', localOutlineOpen);
      localOutlineButton.setAttribute('aria-expanded', String(localOutlineOpen));
    });
  }

  if (localTopLink) {
    localTopLink.addEventListener('click', function (event) {
      event.preventDefault();
      closeLocalOutline();
      window.scrollTo({ top: 0, left: 0, behavior: 'smooth' });
    });
  }

  document.addEventListener('click', function (event) {
    if (!localOutlineDropdown || !localOutlineOpen) {
      return;
    }
    if (!localOutlineDropdown.contains(event.target)) {
      closeLocalOutline();
    }
  });

  if (localOutlineContainer) {
    localOutlineContainer.addEventListener('click', function (event) {
      if (event.target.classList.contains('outline-link')) {
        closeLocalOutline();
      }
    });
  }

  var marker = document.getElementById('vp-outline-marker');

  function getConfiguredScrollOffset() {
    var bodyScrollOffset = document.body ? document.body.getAttribute('data-vp-scroll-offset') : null;
    var offset = bodyScrollOffset ? parseFloat(bodyScrollOffset) : NaN;
    if (!Number.isNaN(offset)) {
      return offset;
    }
    return 134;
  }

  function scrollToHashWithOffset(hash, smooth) {
    if (!hash) {
      return;
    }

    var target = null;
    try {
      target = document.getElementById(decodeURIComponent(hash).slice(1));
    } catch (error) {
      target = null;
    }

    if (!target) {
      return;
    }

    var targetTop = window.scrollY +
      target.getBoundingClientRect().top -
      getConfiguredScrollOffset() +
      (parseInt(window.getComputedStyle(target).paddingTop, 10) || 0);

    var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var behavior = 'auto';
    if (!reduceMotion && smooth && Math.abs(targetTop - window.scrollY) <= window.innerHeight) {
      behavior = 'smooth';
    }

    window.scrollTo({ left: 0, top: targetTop, behavior: behavior });

    target.focus({ preventScroll: true });
    if (document.activeElement === target || target.hasAttribute('tabindex')) {
      return;
    }

    var restoreTabindex = function () {
      target.removeAttribute('tabindex');
      target.removeEventListener('blur', restoreTabindex);
    };

    target.setAttribute('tabindex', '-1');
    target.addEventListener('blur', restoreTabindex);
    target.focus({ preventScroll: true });
    if (document.activeElement !== target) {
      restoreTabindex();
    }
  }

  function handleOutlineLinkClick(event) {
    var link = event.currentTarget;
    if (!link) {
      return;
    }

    var hash = link.getAttribute('href');
    if (!hash || hash.charAt(0) !== '#') {
      return;
    }

    event.preventDefault();

    if (window.history && typeof window.history.pushState === 'function') {
      window.history.pushState(null, '', hash);
    } else {
      window.location.hash = hash;
    }

    scrollToHashWithOffset(hash, true);
  }

  document.querySelectorAll('.outline-link').forEach(function (link) {
    link.addEventListener('click', handleOutlineLinkClick);
  });

  if (window.location.hash) {
    window.requestAnimationFrame(function () {
      scrollToHashWithOffset(window.location.hash, false);
    });
  }

  window.addEventListener('hashchange', function () {
    if (window.location.hash) {
      scrollToHashWithOffset(window.location.hash, false);
    }
  });

  function getAbsoluteTop(element) {
    var offsetTop = 0;
    var current = element;

    while (current && current !== document.body) {
      offsetTop += current.offsetTop;
      current = current.offsetParent;
    }

    if (!current) {
      return NaN;
    }

    return offsetTop;
  }

  function getOutlineScrollOffset() {
    var styles = window.getComputedStyle(root);
    var navHeight = parseFloat(styles.getPropertyValue('--vp-nav-height')) || 0;
    var layoutTopHeight = parseFloat(styles.getPropertyValue('--vp-layout-top-height')) || 0;
    return navHeight + layoutTopHeight;
  }

  function activateOutlineHash(activeHash) {
    document.querySelectorAll('.outline-link').forEach(function (link) {
      var isActive = activeHash !== null && link.getAttribute('href') === activeHash;
      link.classList.toggle('active', isActive);
    });

    if (!marker) {
      return;
    }

    var activeAsideLink = document.querySelector('.VPDocAsideOutline .outline-link.active');
    if (activeAsideLink) {
      marker.style.top = String(activeAsideLink.offsetTop + 39) + 'px';
      marker.style.opacity = '1';
    } else {
      marker.style.top = '33px';
      marker.style.opacity = '0';
    }
  }

  function syncActiveHeading() {
    if (!hasOutline) {
      return;
    }

    var scrollY = window.scrollY || window.pageYOffset || 0;
    var innerHeight = window.innerHeight || 0;
    var offsetHeight = document.body ? document.body.offsetHeight : 0;
    var isBottom = Math.abs(scrollY + innerHeight - offsetHeight) < 1;

    var resolvedHeadings = headings
      .map(function (heading) {
        return {
          hash: '#' + heading.id,
          top: getAbsoluteTop(heading)
        };
      })
      .filter(function (entry) {
        return !Number.isNaN(entry.top);
      })
      .sort(function (a, b) {
        return a.top - b.top;
      });

    if (!resolvedHeadings.length) {
      activateOutlineHash(null);
      return;
    }

    if (scrollY < 1) {
      activateOutlineHash(null);
      return;
    }

    if (isBottom) {
      activateOutlineHash(resolvedHeadings[resolvedHeadings.length - 1].hash);
      return;
    }

    var threshold = scrollY + getOutlineScrollOffset() + 4;
    var activeHash = null;

    resolvedHeadings.forEach(function (entry) {
      if (entry.top > threshold) {
        return;
      }
      activeHash = entry.hash;
    });

    activateOutlineHash(activeHash);
  }

  syncActiveHeading();
  window.addEventListener('scroll', syncActiveHeading, { passive: true });

  if (localOutlineContainer) {
    localOutlineContainer.querySelectorAll('a').forEach(function (link) {
      link.addEventListener('click', function () {
        closeLocalOutline();
      });
    });
  }
})();
