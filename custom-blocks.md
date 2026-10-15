# Custom Blocks

Custom blocks are the VitePress-style containers behind the theme's callout UI. They render colored boxes for tips, warnings, danger notices, and other highlighted content. They are part of [VitePress Parity](/vitepress-parity/); Markdown-friendly callouts, labels, and project buttons are covered in [Extensions to VitePress](/extensions-to-vitepress/).

> **TIP**
>
> For everyday Markdown authoring, use the Just the Docs-style syntax on [Callouts, Labels, and Buttons](/callouts-labels-buttons/). Use this page when you need the lower-level Liquid include, custom titles, or collapsible details.

## Liquid Include Syntax

Use the built-in `alert.html` include when you need explicit control over the block type, title, or content:

```liquid
{% include alert.html type="tip" content="This is a helpful tip." %}
```

The `type` controls the color and default title. The `content` is processed as Markdown, so formatting like backticks, links, and multiple paragraphs work naturally.

## Available Types

> **INFO**
>
> This is an `info` block. Use it for neutral, supplementary information.

> **NOTE**
>
> This is a `note` block. Visually identical to info; use whichever label fits better.

> **TIP**
>
> This is a helpful `tip` block.

> **IMPORTANT**
>
> This is an `important` block. Do not skip this.

> **WARNING**
>
> This is a `warning` block. Something could go wrong.

> **DANGER**
>
> This is a `danger` block. Data loss or security risk.

> **CAUTION**
>
> This is a `caution` block. Visually identical to danger.

> **Details**
>
> This is a collapsible `details` block.

## Custom Titles

Each type has a default title (`TIP`, `WARNING`, etc.). Override it with the `title` parameter:

```liquid
{% include alert.html type="warning" title="Breaking Change" content="The `foo` option was removed in v2.0." %}
```

> **Breaking Change**
>
> The `foo` option was removed in v2.0.

## Markdown In Content

The `content` parameter supports Markdown: code, links, bold, even multiple paragraphs:

```liquid
{% include alert.html type="tip" content="Set `layout: home` in your frontmatter. See the [Frontmatter Reference](/frontmatter-reference/) for details." %}
```

> **TIP**
>
> Set `layout: home` in your frontmatter. See the [Frontmatter Reference](/frontmatter-reference/) for details.

For multi-paragraph content, build the string with `capture` first:

```liquid
{% capture upgrade_note %}
Upgrade with `bundle update jekyll-vitepress-theme`.

Then rebuild your site to pick up the new assets.
{% endcapture %}
{% include alert.html type="note" content=upgrade_note %}
```

> **NOTE**
>
> Upgrade with `bundle update jekyll-vitepress-theme`.
>
> Then rebuild your site to pick up the new assets.
