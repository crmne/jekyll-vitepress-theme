# Frontmatter Reference




## Layouts

- `layout: default`: standard docs page with sidebar and outline.
- `layout: home`: VitePress-style landing page with hero and feature cards. Sidebar and outline are hidden. This belongs to [VitePress Parity](/vitepress-parity/); optional additions beyond VitePress are documented in [Extensions to VitePress](/extensions-to-vitepress/).

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
- `canonical_url`: overrides the page's self-referential canonical URL. A page canonicalized to another URL is omitted from the generated sitemap.
- `image`: social/structured-data image as a path or an object with `path` (or `src`), `alt`, `width`, and `height`.
- `author`: page author as a name or an object with `name`, `url`, and optional `twitter`.
- `lang` or `locale`: overrides the page language, HTML `lang`, and Open Graph locale.
- `robots`: overrides the complete robots directive; `noindex: true` and `nofollow: true` are convenient boolean alternatives.
- `alternates`: language variants, each with `lang` (or `hreflang`) and `url`.
- `date_published`, `date_modified`, or `last_modified_at`: explicit structured-data dates. The sitemap uses only explicit modification dates instead of unreliable build-time file timestamps.
- `seo.title`, `seo.description`, `seo.canonical_url`, `seo.image`, `seo.author`, `seo.robots`, `seo.noindex`, `seo.nofollow`, `seo.type`, and `seo.alternates`: grouped forms of the page-level SEO overrides.
- `seo: false`: disables theme-owned metadata for the page, so a custom head integration can take over.
- `sitemap: false`: omits the URL from `sitemap.xml` without changing its robots directive.
- `llms: false`: excludes the page from both `llms.txt` and `llms-full.txt` without changing normal search indexing.
- `nav_order`: controls sort order within sidebar groups. Lower numbers appear first.
- `parent`: nests the page under another page in the same collection, matched by title.
- `grand_parent`: disambiguates `parent` when the same parent title appears in more than one branch.
- `has_children`: optional compatibility marker for parent pages. Child pages are discovered from their `parent` value.
- `collapsed: true`: renders this page's child branch closed by default, unless the active page is inside it.
- `markdown_styles: false`: renders body content without the `.vp-doc` markdown wrapper styles. Useful for home pages with custom HTML.
- `jekyll_vitepress.auto_title: false`: disables the automatic `<h1>` injection. By default, if a page has a `title` but no `<h1>` in its content, the theme renders one automatically.
- `jekyll_vitepress.footer: false`: hides the global footer on this page.
- `jekyll_vitepress.doc_footer: false`: hides the entire doc footer (prev/next pager, edit link, last updated).
- `jekyll_vitepress.edit_link: false`: hides the edit link for this page only.
- `jekyll_vitepress.last_updated: false`: hides the last-updated timestamp for this page only.
- `jekyll_vitepress.last_updated_at`: manually override the last-updated timestamp instead of using the file's modification time.
- `jekyll_vitepress.prev: false` / `jekyll_vitepress.next: false`: disables one side of the pager navigation.

## SEO example

```yaml
---
title: API Authentication
description: Authenticate API requests with scoped access tokens.
image:
  path: /assets/images/api-auth-card.png
  alt: API authentication flow
  width: 1200
  height: 630
seo:
  type: Article
alternates:
  - lang: en
    url: /api/authentication/
  - lang: de
    url: /de/api/authentifizierung/
  - lang: x-default
    url: /api/authentication/
---
```
{: data-title="page frontmatter"}

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
