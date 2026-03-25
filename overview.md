# Overview

Jekyll VitePress Theme is distributed as a single gem that acts as both a **theme** (providing layouts, includes, and assets) and a **plugin** (registering Jekyll hooks for build-time behavior). Understanding this dual role helps when you want to customize or extend things.

## Theme assets

The gem ships everything needed to render a VitePress-like site:

- **Layouts** (`_layouts/default.html`, `_layouts/home.html`) that compose the page structure — navbar, sidebar, content area, outline, and footer.
- **Includes** for each UI component — navigation, search modal, sidebar, doc footer, and more.
- **Stylesheets** (`assets/css/`) split into core layout styles, component styles, and token overrides.
- **JavaScript** (`assets/js/vitepress-theme.js`) for interactive behavior — sidebar toggle, scroll-tracked outline, search modal, appearance switcher, code block copy buttons, and the page-level "Copy page" control.

All of this is vanilla HTML, CSS, and JavaScript. There's no build step, no bundler, and no framework dependency.

## Plugin behavior

The plugin side registers Jekyll hooks that run automatically at build time:

- **Last-updated timestamps** — Before each page renders, the plugin reads the source file's modification time and sets `last_updated_at` in frontmatter. This means your doc footers can show "Last updated" dates without you touching frontmatter manually.
- **Rouge syntax theme generation** — After reading site config, the plugin validates your configured Rouge theme names and generates scoped CSS for light and dark modes. Invalid theme names fall back to defaults with a warning.
- **Version label resolution** — If `_data/versions.yml` sets `current: auto`, the plugin replaces it with the gem's version string (e.g., `v1.0.0`) at build time.
- **Copy page markdown export** — Before doc pages render, the plugin captures their raw Markdown for the "Copy page" button. After the site is written, it emits a plain `.md` sibling for each generated HTML doc page so "View as Markdown" works without external hosting assumptions. Disable this with `jekyll_vitepress.copy_page.enabled: false`.

## VitePress parity scope

The project targets high visual and interaction parity with VitePress for the features that matter most in documentation:

- Top nav, sidebar, local nav, and right outline
- Header anchors and scroll tracking
- External link icons
- Styled tables (striped rows, responsive scroll)
- Custom containers (tip, warning, danger, info, and more)
- Doc footer pager and edit-link support
- Appearance switcher (auto, dark, light)
- Code block copy buttons, language labels, title bars, and file icons
- Rouge-native light/dark syntax themes
- Automatic page title injection

It intentionally stays Jekyll-first for configuration and page authoring — no `.vue` files, no Node.js, no frontmatter DSLs that don't exist in standard Jekyll.

For a detailed feature checklist comparing what's mirrored from VitePress versus what's added on top, see [VitePress Parity and Extensions]({% link _reference/vitepress-parity-and-extensions.md %}).
