---
title: Extending Behavior
nav_order: 2
description: Extend via layout/include overrides and custom scripts.
---

Because this is Jekyll, extension points are straightforward:

- override `_layouts/default.html`
- override specific includes (e.g. `nav.html`, `doc_footer.html`)
- use hook includes for additive markup:
  - `_includes/jekyll_vitepress/head_end.html`
  - `_includes/jekyll_vitepress/doc_footer_end.html`
  - `_includes/jekyll_vitepress/layout_end.html`
- add your own JS/CSS assets

For behavior customizations, you can fork/extend `assets/js/vitepress-theme.js` while keeping the HTML structure intact.

<div class="warning custom-block">
  <p class="custom-block-title">WARNING</p>
  <p>Keep class names and DOM structure stable if you rely on built-in JS for sidebar, outline, and search interactions.</p>
</div>
