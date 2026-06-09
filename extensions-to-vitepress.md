# Extensions to VitePress

Extensions to VitePress are optional features that go beyond baseline VitePress behavior while preserving the same visual language. Enable them case by case in `_config.yml` or use their Liquid includes directly in page content.








<div class="info custom-block">
  <p class="custom-block-title">INFO</p>
  <p>For features that intentionally mirror VitePress itself, see <a href="/vitepress-parity/">VitePress Parity</a>.</p>

</div>



## Optional Extras

These features are not part of baseline VitePress:

- **[GitHub star widget](/configuration/#github-and-rubygems-buttons):** a navbar or page-level button showing a live star count from the GitHub API, configured via `jekyll_vitepress.github_star`.
- **[GitHub Sponsors widget](/configuration/#github-and-rubygems-buttons):** a navbar or page-level button linking to GitHub Sponsors or a custom sponsorship URL, configured via `jekyll_vitepress.github_sponsor`.
- **[RubyGems downloads button](/callouts-labels-buttons/#rubygems-downloads-button):** a reusable page-level button showing live gem download counts from the RubyGems API, configured via `jekyll_vitepress.gem_downloads`.
- **[Just the Docs-style callouts](/callouts-labels-buttons/#callouts):** kramdown attribute syntax such as `{: .note }` rendered with VitePress-style custom block UI.
- **[Inline labels](/callouts-labels-buttons/#inline-labels):** Just the Docs-style labels such as `{: .label .label-green }` rendered as compact badges.
- **[Local search index](/search-and-outline/#local-search):** a generated `search.json` index for client-side search across sidebar collection content.
- **[Version selector](/configuration/#version-selector):** a data-driven dropdown from `_data/versions.yml`, including `current: auto` support.
- **[Copy page](/configuration-reference/#copy-page):** a split button offering "Copy page" and "View as Markdown" for LLM-friendly docs workflows.

## Configuration Model

Most extensions are independent. You can enable the GitHub star widget without enabling RubyGems downloads, or use Just the Docs-style labels without using page metric buttons.

```yaml
jekyll_vitepress:
  github_star:
    enabled: true
    repository: owner/repo
  gem_downloads:
    enabled: true
    name: your_gem
```
{: data-title="_config.yml"}

For the complete list of configuration keys, see the [Configuration Reference](/configuration-reference/).

## Page-Level Includes

Some extensions are available as Liquid includes so they can be used anywhere in Markdown:

```liquid
{% include github_star_button.html repository="owner/repo" %}
{% include github_sponsor_button.html user="owner" %}
{% include rubygems_downloads_button.html gem="your_gem" %}
```

When an include has explicit parameters, it can render a one-off button even if the corresponding global navbar widget is disabled.
