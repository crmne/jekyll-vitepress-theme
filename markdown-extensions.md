# Markdown Extensions

Beyond standard Markdown, the theme automatically enhances several elements to match VitePress behavior. These work out of the box with no configuration.

## Header anchors

Every heading (`h1` through `h6`) that has an `id` attribute automatically gets a clickable anchor link. Hover over any heading on this page to see the `#` appear — clicking it updates the URL hash so you can share a direct link to that section.

Kramdown generates heading IDs from the heading text by default. You can also set a custom anchor:

```markdown
## My Custom Section {#custom-id}
```

## Links

### Internal links

Standard Markdown links work as expected. Use relative paths or absolute paths:

```markdown
[Getting Started](/getting-started/)
[Configuration]({% raw %}{% link _reference/configuration-reference.md %}{% endraw %})
```

The second form uses Jekyll's `{% raw %}{% link %}{% endraw %}` tag, which validates that the target file exists at build time — if you rename or delete a page, the build will fail instead of producing a broken link.

### External links

Links pointing to external URLs automatically get a visual indicator — a small arrow icon appears after the link text, signaling to readers that clicking will take them away from the docs. This is applied via CSS to any link whose `href` contains `://`.

[VitePress documentation](https://vitepress.dev/) — notice the arrow icon.

## Tables

Standard GitHub-flavored Markdown tables render with VitePress styling — striped rows, bordered cells, and horizontal scroll on narrow screens:

```markdown
| Feature        | Status    | Notes             |
|----------------|-----------|-------------------|
| Header anchors | Automatic | No config needed  |
| External links | Automatic | Arrow icon added  |
| Tables         | Automatic | Striped rows      |
```

| Feature        | Status    | Notes             |
|----------------|-----------|-------------------|
| Header anchors | Automatic | No config needed  |
| External links | Automatic | Arrow icon added  |
| Tables         | Automatic | Striped rows      |

Column alignment works with the standard `:` syntax:

```markdown
| Left | Center | Right |
|:-----|:------:|------:|
| a    |   b    |     c |
```

| Left | Center | Right |
|:-----|:------:|------:|
| a    |   b    |     c |

## Frontmatter

The theme uses standard Jekyll/YAML frontmatter for page metadata. At minimum, each doc page should have a `title` and `nav_order`:

```yaml
---
title: My Page
nav_order: 1
description: A brief description for search and meta tags.
---
```

See the [Frontmatter Reference]({% link _reference/frontmatter-reference.md %}) for all available keys.

## Automatic title injection

If a page has a `title` in its frontmatter but no `<h1>` in its content, the theme automatically renders the title as an `h1` at the top of the page. This keeps your Markdown clean — you don't need to repeat the title as a heading.

To disable this behavior on a specific page, set `jekyll_vitepress.auto_title: false` in the frontmatter.
