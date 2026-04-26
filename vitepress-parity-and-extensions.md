# VitePress Parity and Extensions

This theme targets high visual and interaction parity with [VitePress](https://vitepress.dev/), while keeping configuration and authoring idiomatic to [Jekyll](https://jekyllrb.com/). It also uses Turbo Frames for fast static-site navigation, which gives Jekyll docs a more app-like feel without turning the site into a JavaScript app.

## VitePress parity targets

The theme intentionally mirrors these VitePress features:

- Top nav, mobile nav screen, and social links
- Left sidebar + right outline behavior
- Fast doc-to-doc navigation with a persistent shell
- Home layout structure (hero + feature cards)
- Doc footer behavior (edit link, previous/next pager, last-updated label)
- Appearance switcher (`auto` → `dark` → `light`)
- Search trigger UX (`/`, `Ctrl/Cmd+K`)
- Code block UX (copy buttons, language labels, file title bars with icons)
- Header anchors on all headings
- External link icons (arrow indicator on outbound links)
- Table styling (striped rows, bordered cells, responsive scroll)
- Custom containers (tip, warning, danger, info, note, important, caution, details)
- Automatic page title injection

## Jekyll-first differences (intentional)

These are deliberate departures from VitePress internals. The functionality is equivalent, but the implementation uses Jekyll conventions:

- Configuration lives in `_config.yml` under `jekyll_vitepress` instead of a `.vitepress/config.js` file
- Nav, sidebar, social, and version data live in `_data/*.yml` instead of being defined in JavaScript
- Syntax highlighting uses [Rouge](https://github.com/rouge-ruby/rouge) themes instead of Shiki
- Last-updated timestamps are populated via Jekyll plugin hooks instead of Git history
- Extension points are include hooks (`_includes/jekyll_vitepress/*.html`) instead of Vue slots
- Fast page changes use Turbo Frames around the docs content instead of a client-side router

## Extras added on top

These features are not part of baseline VitePress but are included as optional extras:

- **GitHub star widget:** a navbar button showing live star count from the GitHub API, configured via `jekyll_vitepress.github_star`
- **Local search index:** a simple client-side search built from `search.json`, generated at build time from sidebar collection content
- **Version selector:** a data-driven dropdown from `_data/versions.yml` with `current: auto` support for automatic version label resolution
- **Copy page:** a split button offering "Copy page" (copies raw Markdown to clipboard for LLM use) and "View as Markdown" (opens the page as a plain `.md` file). Enabled by default; disable with `jekyll_vitepress.copy_page.enabled: false`.

## Practical guidance

If you want output that looks as close to VitePress as possible, keep the optional extras disabled and rely on the default structure and styling.

If you want productized docs behavior beyond what VitePress ships out of the box, enable extras case by case in `_config.yml`. Each extra is independent. You can use the GitHub star widget without the version selector, or the search without either.
