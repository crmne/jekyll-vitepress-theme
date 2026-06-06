---
title: Callouts, Labels, and Buttons
nav_order: 4
description: Just the Docs-style callouts, inline labels, and reusable project buttons.
---

{% assign extensions_link = '/extensions-to-vitepress/' | relative_url %}

Use these Markdown-friendly patterns for everyday docs authoring:

- Callouts use Just the Docs-style kramdown attributes and render as VitePress-style custom blocks.
- Labels use the same kramdown attribute style and render as compact badges.
- Project buttons use Liquid includes when they need dynamic URLs or live counts.

These features go beyond baseline VitePress and are summarized in [Extensions to VitePress]({{ extensions_link }}).

## Callouts

Use a kramdown block attribute on a paragraph or blockquote:

```markdown
Using this theme? [Share your story](https://example.com)! Takes 5 minutes.
{: .note }
```

Using this theme? [Share your story](https://example.com)! Takes 5 minutes.
{: .note }

Supported callout classes are `.info`, `.note`, `.tip`, `.important`, `.warning`, `.danger`, and `.caution`.

## Available Callouts

This is an `info` block. Use it for neutral, supplementary information.
{: .info }

This is a `note` block. Visually identical to info; use whichever label fits better.
{: .note }

This is a helpful `tip` block.
{: .tip }

This is an `important` block. Do not skip this.
{: .important }

This is a `warning` block. Something could go wrong.
{: .warning }

This is a `danger` block. Data loss or security risk.
{: .danger }

This is a `caution` block. Visually identical to danger.
{: .caution }

## Inline Labels

Labels follow the Just the Docs authoring style and render as compact VitePress-style badges:

```markdown
### Labels
{: .d-inline-block }

v1.9.0+
{: .label .label-green }
```

<!-- markdownlint-disable MD022 -->
### Labels
{: .d-inline-block }

v1.9.0+
{: .label .label-green }
<!-- markdownlint-enable MD022 -->

Available label colors are `.label-blue`, `.label-green`, `.label-purple`, `.label-yellow`, and `.label-red`.

## RubyGems Downloads Button

Configure the gem once in `_config.yml`:

```yaml
jekyll_vitepress:
  gem_downloads:
    enabled: true
    name: jekyll-vitepress-theme
    text: Gem downloads
    show_count: true
```
{: data-title="_config.yml"}

Then render a live downloads button anywhere in Markdown:

```liquid
{% raw %}{% include rubygems_downloads_button.html %}{% endraw %}
```

{% include rubygems_downloads_button.html %}

You can also configure each button inline:

```liquid
{% raw %}{% include rubygems_downloads_button.html gem="jekyll-vitepress-theme" text="Gem downloads" %}{% endraw %}
```

The button fetches `https://rubygems.org/api/v1/gems/:name.json` and displays a compact count like `3.3K downloads`.

## Other Project Buttons

GitHub Star and GitHub Sponsors buttons are also available outside the navbar:

```liquid
{% raw %}{% include github_star_button.html repository="crmne/jekyll-vitepress-theme" %}
{% include github_sponsor_button.html user="crmne" %}{% endraw %}
```

{% include github_star_button.html repository="crmne/jekyll-vitepress-theme" %}
{% include github_sponsor_button.html user="crmne" %}

## Lower-Level Custom Blocks

If you need custom titles or collapsible details, use the lower-level Liquid include documented on [Custom Blocks]({% link _core_features/custom-blocks.md %}).
