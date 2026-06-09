# VitePress Parity

This theme targets high visual and interaction parity with [VitePress](https://vitepress.dev/) while keeping configuration and authoring idiomatic to [Jekyll](https://jekyllrb.com/).








<div class="tip custom-block">
  <p class="custom-block-title">TIP</p>
  <p>This page covers behavior that mirrors VitePress. Features added on top of baseline VitePress are documented on <a href="/extensions-to-vitepress/">Extensions to VitePress</a>.</p>

</div>



## Mirrored Features

The theme intentionally mirrors these VitePress documentation features:

- **[Top nav, mobile nav, and social links](/navigation-layout/):** persistent header navigation with responsive mobile behavior.
- **[Left sidebar and right outline](/navigation-layout/):** docs shell layout with collection-driven sidebar navigation and page-local outline.
- **[Fast doc-to-doc navigation](/overview/#theme-assets):** Turbo Frames keep the surrounding docs shell mounted between page changes.
- **[Home layout](/frontmatter-reference/#home-layout):** VitePress-style hero, actions, image, and feature cards from frontmatter.
- **[Doc footer behavior](/configuration-reference/#footer-and-doc-footer):** previous/next pager, edit link, and last-updated metadata.
- **[Appearance switcher](/configuration-reference/#labels-and-behavior):** `auto`, `dark`, and `light` modes with persisted preference.
- **[Search trigger UX](/search-and-outline/#local-search):** keyboard search with `/`, `Ctrl+K`, and `Cmd+K`.
- **[Code block UX](/code-blocks/):** copy buttons, language labels, file title bars, file icons, and syntax palettes.
- **[Markdown enhancements](/markdown-extensions/):** heading anchors, external link indicators, and table styling.
- **[Custom containers](/custom-blocks/):** `info`, `note`, `tip`, `important`, `warning`, `danger`, `caution`, and `details` blocks.
- **[Automatic page title injection](/frontmatter-reference/#layouts):** doc pages render the frontmatter `title` as the page heading.

## Jekyll-First Differences

These differences are intentional. The functionality is equivalent where possible, but the implementation uses Jekyll conventions:

- **[Configuration](/configuration/):** theme options live in `_config.yml` under `jekyll_vitepress`, not in `.vitepress/config.js`.
- **[Navigation data](/navigation-layout/#top-navigation):** nav, sidebar, social, and version data live in `_data/*.yml`, not JavaScript config.
- **[Syntax highlighting](/code-blocks/#syntax-highlighting):** highlighting uses Rouge themes instead of Shiki.
- **[Last updated](/configuration-reference/#edit-link-last-updated-github-star-github-sponsor-and-gem-downloads):** timestamps are populated by Jekyll plugin hooks instead of Git history.
- **[Extension hooks](/extending-behavior/):** customization uses layout/include overrides and custom scripts instead of Vue slots.
- **[Turbo navigation](/overview/#theme-assets):** fast page changes use Turbo Frames around the docs content instead of a client-side router.

## Practical Guidance

If you want output that looks as close to VitePress as possible, keep the optional extras disabled and rely on the default structure, styling, and frontmatter patterns.

If you want productized docs behavior beyond VitePress parity, enable the extras documented on [Extensions to VitePress](/extensions-to-vitepress/).
