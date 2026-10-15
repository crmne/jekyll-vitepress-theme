# Callouts, Labels, and Buttons

Use these Markdown-friendly patterns for everyday docs authoring:

- Callouts use Just the Docs-style kramdown attributes and render as VitePress-style custom blocks.
- Labels use the same kramdown attribute style and render as compact badges.
- Project buttons use Liquid includes when they need dynamic URLs or live counts.

These features go beyond baseline VitePress and are summarized in [Extensions to VitePress](/extensions-to-vitepress/).

## Callouts

Use a kramdown block attribute on a paragraph or blockquote:

```markdown
Using this theme? [Share your story](https://example.com)! Takes 5 minutes.
{: .note }
```

Using this theme? [Share your story](https://example.com)! Takes 5 minutes.

Supported callout classes are `.info`, `.note`, `.tip`, `.important`, `.warning`, `.danger`, and `.caution`.

## Available Callouts

This is an `info` block. Use it for neutral, supplementary information.

This is a `note` block. Visually identical to info; use whichever label fits better.

This is a helpful `tip` block.

This is an `important` block. Do not skip this.

This is a `warning` block. Something could go wrong.

This is a `danger` block. Data loss or security risk.

This is a `caution` block. Visually identical to danger.

## Inline Labels

Labels follow the Just the Docs authoring style and render as compact VitePress-style badges:

```markdown
### Labels
{: .d-inline-block }

v1.9.0+
{: .label .label-green }
```

### Labels

v1.9.0+

Available label colors are `.label-blue`, `.label-green`, `.label-purple`, `.label-yellow`, and `.label-red`.

## RubyGems Downloads Button

Configure the gem once in `_config.yml`:

**_config.yml**

```yaml
jekyll_vitepress:
  gem_downloads:
    enabled: true
    name: jekyll-vitepress-theme
    text: Gem downloads
    show_count: true
```

Then render a live downloads button anywhere in Markdown:

```liquid
{% include rubygems_downloads_button.html %}
```

[Gem downloads **... downloads**](https://rubygems.org/gems/jekyll-vitepress-theme)

You can also configure each button inline:

```liquid
{% include rubygems_downloads_button.html gem="jekyll-vitepress-theme" text="Gem downloads" %}
```

The button fetches `https://rubygems.org/api/v1/gems/:name.json` and displays a compact count like `3.3K downloads`.

## Other Project Buttons

GitHub Star and GitHub Sponsors buttons are also available outside the navbar:

```liquid
{% include github_star_button.html repository="crmne/jekyll-vitepress-theme" %}
{% include github_sponsor_button.html user="crmne" %}
```

[Star](https://github.com/crmne/jekyll-vitepress-theme)

[Sponsor](https://github.com/sponsors/crmne)

## Lower-Level Custom Blocks

If you need custom titles or collapsible details, use the lower-level Liquid include documented on [Custom Blocks](/custom-blocks/).
