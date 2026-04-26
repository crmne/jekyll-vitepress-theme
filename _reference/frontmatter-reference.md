---
title: Frontmatter Reference
nav_order: 2
description: Page-level frontmatter options used by the theme.
---

## Layouts

- `layout: default`: standard docs page with sidebar and outline.
- `layout: home`: VitePress-style landing page with hero and feature cards. Sidebar and outline are hidden.

## Home layout keys

The home layout supports a `hero` section and a `features` list:

```yaml
layout: home
hero:
  name: Project Name
  text: Project Tagline
  tagline: Supporting sentence
  image:
    src: /path/to/image.svg
    alt: Logo
    width: 320
    height: 320
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started/
    - theme: alt
      text: GitHub
      link: https://github.com/you/project
features:
  - icon: ⚡
    title: Fast
    details: Feature description
    link_text: Learn more
    link: /getting-started/
```
{: data-title="index.md"}

Action buttons support two themes: `brand` (solid, primary color) and `alt` (outlined, secondary). Feature cards can optionally include `link` and `link_text` to make them clickable.

## Optional page keys

These keys can be set in any page's frontmatter to control theme behavior on a per-page basis:

- `description`: used in `<meta name="description">` and search results.
- `nav_order`: controls sort order within sidebar groups. Lower numbers appear first.
- `markdown_styles: false`: renders body content without the `.vp-doc` markdown wrapper styles. Useful for home pages with custom HTML.
- `jekyll_vitepress.auto_title: false`: disables the automatic `<h1>` injection. By default, if a page has a `title` but no `<h1>` in its content, the theme renders one automatically.
- `jekyll_vitepress.footer: false`: hides the global footer on this page.
- `jekyll_vitepress.doc_footer: false`: hides the entire doc footer (prev/next pager, edit link, last updated).
- `jekyll_vitepress.edit_link: false`: hides the edit link for this page only.
- `jekyll_vitepress.last_updated: false`: hides the last-updated timestamp for this page only.
- `jekyll_vitepress.last_updated_at`: manually override the last-updated timestamp instead of using the file's modification time.
- `jekyll_vitepress.prev: false` / `jekyll_vitepress.next: false`: disables one side of the pager navigation.

## Custom prev / next links

You can override the auto-computed pager links with custom titles and URLs:

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
