---
title: Frontmatter Reference
nav_order: 2
description: Page-level frontmatter options used by the theme.
---

## Layouts

- `layout: default` for docs pages.
- `layout: home` for VitePress-style home pages.

## Home layout keys

```yaml
layout: home
hero:
  name: Project Name
  text: Project Tagline
  tagline: Supporting sentence
  image:
    src: /path/to/image.svg
    alt: Logo
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started/
features:
  - icon: ⚡
    title: Fast
    details: Feature description
    link_text: Learn more
    link: /getting-started/
```
{: data-title="index.md"}

For home pages, `markdown_styles: false` renders body content without `.vp-doc` markdown wrapper styles.

## Optional page keys

- `description`
- `nav_order`
- `jekyll_vitepress.last_updated_at` (manual override)
- `jekyll_vitepress.auto_title: false` (disable automatic `<h1>` injection when the page has a title)
- `jekyll_vitepress.footer: false` (hide global footer)
- `jekyll_vitepress.doc_footer: false` (hide prev/next pager)
- `jekyll_vitepress.edit_link: false` (hide edit link for this page)
- `jekyll_vitepress.last_updated: false` (hide last updated for this page)
- `jekyll_vitepress.prev: false` / `jekyll_vitepress.next: false` (disable pager side)

## Custom prev / next links

You can override auto-computed pager links:

```yaml
jekyll_vitepress:
  prev:
    text: Custom previous title
    link: /some/page/
  next:
    text: Custom next title
    link: /another/page/
```
{: data-title="example-page.md"}
