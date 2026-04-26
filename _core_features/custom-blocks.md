---
title: Custom Blocks
nav_order: 3
description: Callout boxes for tips, warnings, and other highlighted content.
---

The theme includes styled callout blocks that match VitePress custom containers: colored boxes for tips, warnings, danger notices, and more. They use a built-in `alert.html` include that produces the exact VitePress HTML structure.

## Syntax

```liquid
{% raw %}{% include alert.html type="tip" content="This is a helpful tip." %}{% endraw %}
```

The `type` controls the color and default title. The `content` is processed as Markdown, so inline formatting like backticks and links work naturally.

## Available types

{% include alert.html type="info" content="This is an `info` block. Use it for neutral, supplementary information." %}

{% include alert.html type="note" content="This is a `note` block. Visually identical to info; use whichever label fits better." %}

{% include alert.html type="tip" content="This is a helpful `tip` block." %}

{% include alert.html type="important" content="This is an `important` block. Don't skip this." %}

{% include alert.html type="warning" content="This is a `warning` block. Something could go wrong." %}

{% include alert.html type="danger" content="This is a `danger` block. Data loss or security risk." %}

{% include alert.html type="caution" content="This is a `caution` block. Visually identical to danger." %}

{% include alert.html type="details" content="This is a collapsible `details` block." %}

## Custom titles

Each type has a default title (`TIP`, `WARNING`, etc.). Override it with the `title` parameter:

```liquid
{% raw %}{% include alert.html type="warning" title="Breaking Change" content="The `foo` option was removed in v2.0." %}{% endraw %}
```

{% include alert.html type="warning" title="Breaking Change" content="The `foo` option was removed in v2.0." %}

## Markdown in content

The `content` parameter supports inline Markdown: code, links, bold, and so on:

```liquid
{% raw %}{% include alert.html type="tip" content="Set `layout: home` in your frontmatter. See the [Frontmatter Reference](/frontmatter-reference/) for details." %}{% endraw %}
```

{% include alert.html type="tip" content="Set `layout: home` in your frontmatter. See the [Frontmatter Reference](/frontmatter-reference/) for details." %}
