---
title: Overview
nav_order: 4
description: How the theme is structured and where Turbo, Jekyll, and VitePress-style UI meet.
---

Jekyll VitePress Theme is distributed as a single gem with two jobs: it is a **theme** that provides layouts, includes, and assets, and it is a **plugin** that registers Jekyll hooks for build-time behavior.

That split keeps the runtime simple. Jekyll renders static HTML. The theme adds a small amount of JavaScript for UI behavior, including Turbo Frame navigation for doc-to-doc page changes.

## Theme assets

The gem ships everything needed to render a VitePress-like site:

- **Layouts** (`_layouts/default.html`, `_layouts/home.html`) that compose the page structure: navbar, sidebar, content area, outline, and footer.
- **Includes** for each UI component: navigation, search modal, sidebar, doc footer, and more.
- **Stylesheets** (`assets/css/`) split into core layout styles, component styles, and token overrides.
- **JavaScript** (`assets/js/vitepress-theme.js`) for interactive behavior: sidebar toggle, scroll-tracked outline, search modal, appearance switcher, code block copy buttons, page-level "Copy page", and Turbo Frame refresh hooks.
- **Turbo runtime** (`assets/vendor/turbo.js`) for fast internal docs navigation without a full page reload.

There is no app bundle to build. The shipped assets are plain HTML, CSS, JavaScript, and a vendored Turbo runtime.

## Plugin behavior

The plugin side registers Jekyll hooks that run automatically at build time:

- **Last-updated timestamps:** before each page renders, the plugin reads the source file's modification time and sets `last_updated_at` in frontmatter. This means your doc footers can show "Last updated" dates without you touching frontmatter manually.
- **Rouge syntax theme generation:** after reading site config, the plugin validates your configured Rouge theme names and generates scoped CSS for light and dark modes. Invalid theme names fall back to defaults with a warning.
- **Version label resolution:** if `_data/versions.yml` sets `current: auto`, the plugin replaces it with the gem's version string (e.g., `v1.0.0`) at build time.
- **Copy page markdown export:** before doc pages render, the plugin captures their raw Markdown for the "Copy page" button. After the site is written, it emits a plain `.md` sibling for each generated HTML doc page so "View as Markdown" works without external hosting assumptions. Disable this with `jekyll_vitepress.copy_page.enabled: false`.

## VitePress parity scope

The project targets high visual and interaction parity with VitePress for the features that matter most in documentation:

- Top nav, sidebar, local nav, and right outline
- Fast internal page navigation with a persistent docs shell
- Header anchors and scroll tracking
- External link icons
- Styled tables (striped rows, responsive scroll)
- Custom containers (tip, warning, danger, info, and more)
- Doc footer pager and edit-link support
- Appearance switcher (auto, dark, light)
- Code block copy buttons, language labels, title bars, and file icons
- Rouge-native light/dark syntax themes
- Automatic page title injection

It intentionally stays Jekyll-first for configuration and page authoring: no `.vue` files, no Vite config, and no frontmatter DSL that only exists in another toolchain.

For a detailed feature checklist comparing what's mirrored from VitePress versus what's added on top, see [VitePress Parity and Extensions]({% link _reference/vitepress-parity-and-extensions.md %}).
