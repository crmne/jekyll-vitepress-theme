---
title: Custom Blocks
nav_order: 3
description: VitePress-style custom containers for tips, warnings, details, and other highlighted content.
---

{% capture vitepress_parity_link %}{% link _reference/vitepress-parity.md %}{% endcapture %}
{% capture extensions_link %}{% link _reference/extensions-to-vitepress.md %}{% endcapture %}

Custom blocks are the VitePress-style containers behind the theme's callout UI. They render colored boxes for tips, warnings, danger notices, and other highlighted content. They are part of [VitePress Parity]({{ vitepress_parity_link }}); Markdown-friendly callouts, labels, and project buttons are covered in [Extensions to VitePress]({{ extensions_link }}).

{% capture callouts_page_link %}{% link _core_features/callouts-labels-buttons.md %}{% endcapture %}
{% capture custom_blocks_tip %}For everyday Markdown authoring, use the Just the Docs-style syntax on [Callouts, Labels, and Buttons]({{ callouts_page_link }}). Use this page when you need the lower-level Liquid include, custom titles, or collapsible details.{% endcapture %}
{% include alert.html type="tip" content=custom_blocks_tip %}

## Liquid Include Syntax

Use the built-in `alert.html` include when you need explicit control over the block type, title, or content:

```liquid
{% raw %}{% include alert.html type="tip" content="This is a helpful tip." %}{% endraw %}
```

The `type` controls the color and default title. The `content` is processed as Markdown, so formatting like backticks, links, and multiple paragraphs work naturally.

## Available Types

{% include alert.html type="info" content="This is an `info` block. Use it for neutral, supplementary information." %}

{% include alert.html type="note" content="This is a `note` block. Visually identical to info; use whichever label fits better." %}

{% include alert.html type="tip" content="This is a helpful `tip` block." %}

{% include alert.html type="important" content="This is an `important` block. Do not skip this." %}

{% include alert.html type="warning" content="This is a `warning` block. Something could go wrong." %}

{% include alert.html type="danger" content="This is a `danger` block. Data loss or security risk." %}

{% include alert.html type="caution" content="This is a `caution` block. Visually identical to danger." %}

{% include alert.html type="details" content="This is a collapsible `details` block." %}

## Custom Titles

Each type has a default title (`TIP`, `WARNING`, etc.). Override it with the `title` parameter:

```liquid
{% raw %}{% include alert.html type="warning" title="Breaking Change" content="The `foo` option was removed in v2.0." %}{% endraw %}
```

{% include alert.html type="warning" title="Breaking Change" content="The `foo` option was removed in v2.0." %}

## Markdown In Content

The `content` parameter supports Markdown: code, links, bold, even multiple paragraphs:

```liquid
{% raw %}{% include alert.html type="tip" content="Set `layout: home` in your frontmatter. See the [Frontmatter Reference](/frontmatter-reference/) for details." %}{% endraw %}
```

{% include alert.html type="tip" content="Set `layout: home` in your frontmatter. See the [Frontmatter Reference](/frontmatter-reference/) for details." %}

For multi-paragraph content, build the string with `capture` first:

```liquid
{% raw %}{% capture upgrade_note %}
Upgrade with `bundle update jekyll-vitepress-theme`.

Then rebuild your site to pick up the new assets.
{% endcapture %}
{% include alert.html type="note" content=upgrade_note %}{% endraw %}
```

{% capture upgrade_note %}
Upgrade with `bundle update jekyll-vitepress-theme`.

Then rebuild your site to pick up the new assets.
{% endcapture %}
{% include alert.html type="note" content=upgrade_note %}
