---
title: Search and Outline
nav_order: 4
description: Keyboard search, generated index, and active heading tracking.
---

## Local search

The theme includes a built-in search modal that works entirely client-side. No external service is required.

Open search with any of these shortcuts:

- `/` (when not focused on an input)
- `Ctrl+K` (Windows/Linux)
- `Cmd+K` (macOS)

The plugin generates `/search.json` automatically at build time. It includes the home page and all documents from your sidebar collections. Results show matching page titles and content excerpts.

On docs pages, clicking a search result uses the same Turbo Frame navigation as sidebar links, so the result opens without tearing down the surrounding docs shell.

If you need custom indexing behavior, add your own `search.json` page to the site and it will override the generated default.

{% include alert.html type="tip" content="If search doesn't seem to find certain pages, make sure those pages belong to a collection listed in your `_data/sidebar.yml`. Only sidebar collections are indexed." %}

## Right-side outline

The "On this page" outline appears on the right side of docs pages and lists all `h2` and `h3` headings on the current page.

As you scroll, the outline highlights the heading that's currently at the top of the viewport. Clicking an outline link scrolls to that heading, offset so it's visible below the fixed navbar. The offset distance is configurable:

```yaml
jekyll_vitepress:
  behavior:
    scroll_offset: 134
```
{: data-title="_config.yml"}

The outline label defaults to "On this page" and can be changed via `jekyll_vitepress.labels.outline`.

On narrow screens, the outline collapses to keep the content area readable.
