---
title: VitePress Parity
nav_order: 3
description: What this theme mirrors from VitePress and where the Jekyll implementation intentionally differs.
redirect_from:
  - /vitepress-parity-and-extensions/
---

This theme targets high visual and interaction parity with [VitePress](https://vitepress.dev/) while keeping configuration and authoring idiomatic to [Jekyll](https://jekyllrb.com/).

{% capture extensions_page_link %}{% link _reference/extensions-to-vitepress.md %}{% endcapture %}
{% capture parity_tip %}This page covers behavior that mirrors VitePress. Features added on top of baseline VitePress are documented on [Extensions to VitePress]({{ extensions_page_link }}).{% endcapture %}
{% include alert.html type="tip" content=parity_tip %}

## Mirrored Features

The theme intentionally mirrors these VitePress documentation features:

- **[Top nav, mobile nav, and social links]({% link _core_features/navigation-layout.md %}):** persistent header navigation with responsive mobile behavior.
- **[Left sidebar and right outline]({% link _core_features/navigation-layout.md %}):** docs shell layout with collection-driven sidebar navigation and page-local outline.
- **[Fast doc-to-doc navigation]({% link _introduction/overview.md %}#theme-assets):** Turbo Frames keep the surrounding docs shell mounted between page changes.
- **[Home layout]({% link _reference/frontmatter-reference.md %}#home-layout):** VitePress-style hero, actions, image, and feature cards from frontmatter.
- **[Doc footer behavior]({% link _reference/configuration-reference.md %}#footer-and-doc-footer):** previous/next pager, edit link, and last-updated metadata.
- **[Appearance switcher]({% link _reference/configuration-reference.md %}#labels-and-behavior):** `auto`, `dark`, and `light` modes with persisted preference.
- **[Search trigger UX]({% link _core_features/search-and-outline.md %}#local-search):** keyboard search with `/`, `Ctrl+K`, and `Cmd+K`.
- **[Code block UX]({% link _core_features/code-blocks.md %}):** copy buttons, language labels, file title bars, file icons, and syntax palettes.
- **[Markdown enhancements]({% link _core_features/markdown-extensions.md %}):** heading anchors, external link indicators, and table styling.
- **[Custom containers]({% link _core_features/custom-blocks.md %}):** `info`, `note`, `tip`, `important`, `warning`, `danger`, `caution`, and `details` blocks.
- **[Automatic page title injection]({% link _reference/frontmatter-reference.md %}#layouts):** doc pages render the frontmatter `title` as the page heading.

## Jekyll-First Differences

These differences are intentional. The functionality is equivalent where possible, but the implementation uses Jekyll conventions:

- **[Configuration]({% link _introduction/configuration.md %}):** theme options live in `_config.yml` under `jekyll_vitepress`, not in `.vitepress/config.js`.
- **[Navigation data]({% link _core_features/navigation-layout.md %}#top-navigation):** nav, sidebar, social, and version data live in `_data/*.yml`, not JavaScript config.
- **[Syntax highlighting]({% link _core_features/code-blocks.md %}#syntax-highlighting):** highlighting uses Rouge themes instead of Shiki.
- **[Last updated]({% link _reference/configuration-reference.md %}#edit-link-last-updated-github-star-github-sponsor-and-gem-downloads):** timestamps are populated by Jekyll plugin hooks instead of Git history.
- **[Extension hooks]({% link _advanced/extending-behavior.md %}):** customization uses layout/include overrides and custom scripts instead of Vue slots.
- **[Turbo navigation]({% link _introduction/overview.md %}#theme-assets):** fast page changes use Turbo Frames around the docs content instead of a client-side router.

## Practical Guidance

If you want output that looks as close to VitePress as possible, keep the optional extras disabled and rely on the default structure, styling, and frontmatter patterns.

If you want productized docs behavior beyond VitePress parity, enable the extras documented on [Extensions to VitePress]({% link _reference/extensions-to-vitepress.md %}).
