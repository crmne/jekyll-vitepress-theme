# SEO and Discovery

Jekyll VitePress Theme makes the indexing signals for a documentation site part of the theme instead of an optional assembly of plugins. The HTML head, JSON-LD graph, sitemap, and robots file all use the same canonical URL resolver, including `baseurl` when the site is published below a path.

## What is generated

Each indexable HTML page receives:

- A unique title and description, with build warnings when either is missing
- An absolute self-referential canonical URL
- A complete robots directive with unrestricted image, text, and video previews
- Open Graph locale, title, description, URL, type, and image metadata
- Twitter card, title, description, image, and optional account metadata
- One JSON-LD graph containing `WebSite`, `WebPage` and an optional `Article`, plus publisher and author identity, the primary image, and a breadcrumb trail built from nested sidebar parents
- Optional language alternates and webmaster verification tags

At site level, the plugin creates `sitemap.xml` and `robots.txt`. Redirects, `404` pages, pages with an external canonical, `noindex` pages, and pages with `sitemap: false` stay out of the sitemap. Modification dates appear only when supplied explicitly; a fresh deployment is not misrepresented as a content update. When Copy Page is enabled, its plain `.md` companions remain available to people and LLM tools, while `nofollow` links and a robots rule keep crawlers focused on the canonical HTML pages.

The plugin also creates `llms.txt` and `llms-full.txt`. The concise file is an index of canonical pages grouped in documentation order; the full companion contains their resolved Markdown in one document. This follows the proposed [llms.txt convention](https://llmstxt.org/) for inference-time documentation discovery. It complements the search files above but is not an SEO ranking signal.

## Production minimum

```yaml
title: My Project Docs
description: Install, configure, and use My Project.
url: https://docs.example.com
lang: en-US

jekyll_vitepress:
  seo:
    image:
      path: /assets/images/social-card.png
      alt: My Project documentation
      width: 1200
      height: 630
```
{: data-title="_config.yml"}

Use an absolute production `url` without a trailing slash or `baseurl`. If you deploy to `https://example.com/docs/`, configure `url: https://example.com` and `baseurl: /docs`.

Write a specific `description` for every important page. The site description is a safe fallback, but unique summaries give search engines and link previews a more useful explanation of each result.

## Publishers, authors, and technical articles

The default structured page type is `WebPage`. Documentation projects with article-style guides can opt into Google's supported `Article` type and identify the responsible publisher:

```yaml
author:
  name: Your Name
  url: https://example.com/about/

jekyll_vitepress:
  seo:
    page_type: Article
    publisher:
      type: Organization
      name: My Project
      url: https://example.com
      logo: /assets/images/logo.png
      same_as:
        - https://github.com/example/project
```
{: data-title="_config.yml"}

Set `seo.type` in page frontmatter when only a subset of pages should be articles. Add accurate `date_published` or `date_modified` values when you have them. The theme intentionally does not turn checkout/build timestamps into content dates.

## Control indexing and canonicalization

Use `noindex: true` for a page that should remain reachable but absent from search results. It is automatically omitted from the sitemap. Use `canonical_url` instead when the content is a duplicate or cross-publication and another URL should consolidate its signals:

```yaml
---
title: Legacy Setup
canonical_url: https://docs.example.com/setup/
---
```

For a staging build, set `jekyll_vitepress.seo.index: false`. This emits `noindex` on every themed page, writes a site-wide `Disallow: /`, and suppresses sitemap discovery. This setting is an explicit deployment control; remember to leave it `true` in production.

## Multilingual pages

Set the page's own `lang` and list every equivalent URL, including the current language and an optional `x-default` entry:

```yaml
lang: de-DE
alternates:
  - lang: en
    url: /guide/
  - lang: de
    url: /de/anleitung/
  - lang: x-default
    url: /guide/
```

The theme emits both `hreflang` links and Open Graph alternate locales. Each translated page should point back to the full same set.

## Avoid duplicate generators

Do not also render `{% seo %}` or enable another sitemap/robots generator unless you disable the theme layer with `jekyll_vitepress.seo.enabled: false`. A source `sitemap.xml` or `robots.txt` intentionally overrides the corresponding generated file.

After publishing, submit `/sitemap.xml` in Google Search Console and Bing Webmaster Tools. Validate representative pages with the rendered HTML, a structured-data validator, and each platform's link-preview debugger; those external tools evaluate the deployed response, including redirects and HTTP headers that a static build cannot verify.
