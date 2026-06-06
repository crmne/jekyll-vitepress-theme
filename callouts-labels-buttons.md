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
{% include rubygems_downloads_button.html %}
```

















  <a class="VPMetricButton VPMetricButtonDownloads no-icon" href="https://rubygems.org/gems/jekyll-vitepress-theme" aria-label="View gem downloads" target="_blank" rel="noreferrer noopener" data-rubygems-downloads-gem="jekyll-vitepress-theme" data-rubygems-downloads-show-count="true" data-rubygems-downloads-label="View gem downloads">
    <span class="VPMetricButtonIcon VPMetricButtonDownloadsIcon" aria-hidden="true">
      <svg viewBox="0 0 16 16" focusable="false">
        <path d="M8 1.75a.75.75 0 0 1 .75.75v5.19l1.72-1.72a.75.75 0 1 1 1.06 1.06l-3 3a.75.75 0 0 1-1.06 0l-3-3a.75.75 0 0 1 1.06-1.06l1.72 1.72V2.5A.75.75 0 0 1 8 1.75ZM3.75 11a.75.75 0 0 1 .75.75v1h7v-1a.75.75 0 0 1 1.5 0v1.5a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-1.5a.75.75 0 0 1 .75-.75Z"></path>
      </svg>
    </span>
    <span class="VPMetricButtonText" hidden>Gem downloads</span>
    <strong class="VPMetricButtonCount" data-vp-rubygems-downloads-count>... downloads</strong>
  </a>



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















  <a class="VPMetricButton VPMetricButtonGithub no-icon" href="https://github.com/crmne/jekyll-vitepress-theme" aria-label="Star crmne/jekyll-vitepress-theme on GitHub" target="_blank" rel="noreferrer noopener" data-github-star-repo="crmne/jekyll-vitepress-theme" data-github-star-show-count="true">
    <span class="VPMetricButtonIcon vpi-social-github" aria-hidden="true"></span>
    <span class="VPMetricButtonText">Star</span>
    <span class="VPMetricButtonCount" data-vp-github-star-count aria-hidden="true">...</span>
  </a>
















  <a class="VPMetricButton VPMetricButtonSponsor no-icon" href="https://github.com/sponsors/crmne" aria-label="Sponsor on GitHub" target="_blank" rel="noreferrer noopener">
    <span class="VPMetricButtonIcon VPMetricButtonSponsorIcon" aria-hidden="true">
      <svg viewBox="0 0 16 16" focusable="false">
        <path d="M7.655 14.916v-.001h-.002l-.006-.003-.018-.01a22.066 22.066 0 0 1-3.744-2.584C2.045 10.731 0 8.35 0 5.5 0 2.836 2.086 1 4.25 1 5.797 1 7.153 1.802 8 3.02 8.847 1.802 10.203 1 11.75 1 13.914 1 16 2.836 16 5.5c0 2.85-2.044 5.231-3.886 6.818a22.094 22.094 0 0 1-3.433 2.414 7.152 7.152 0 0 1-.31.17l-.018.01-.008.004a.75.75 0 0 1-.69 0Z"></path>
      </svg>
    </span>
    <span class="VPMetricButtonText">Sponsor</span>
  </a>



## Lower-Level Custom Blocks

If you need custom titles or collapsible details, use the lower-level Liquid include documented on [Custom Blocks](/custom-blocks/).
