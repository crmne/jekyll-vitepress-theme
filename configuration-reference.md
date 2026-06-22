# Configuration Reference

This theme follows a Jekyll-native split:

- Behavior and rendering options in `_config.yml` under `jekyll_vitepress`
- Navigation/social/version/sidebar content in `_data/*.yml`



For parity notes compared to VitePress core, see [VitePress Parity](/vitepress-parity/). For optional extras, see [Extensions to VitePress](/extensions-to-vitepress/).

## Minimal setup

```yaml
jekyll_vitepress:
  branding:
    site_title: My Docs
```
{: data-title="_config.yml"}

```yaml
- title: Guide
  url: /getting-started/
  collections: [introduction, core_features, advanced]
```
{: data-title="_data/navigation.yml"}

```yaml
- title: Getting Started
  collection: introduction
```
{: data-title="_data/sidebar.yml"}

## `_config.yml` (`jekyll_vitepress`)

### Branding

- `branding.site_title`
- `branding.logo.default`
- `branding.logo.light`
- `branding.logo.dark`
- `branding.logo.alt`
- `branding.logo.width`
- `branding.logo.height`

```yaml
jekyll_vitepress:
  branding:
    site_title: My Project
    logo:
      default: /assets/images/logo.svg
      light: /assets/images/logo-light.svg
      dark: /assets/images/logo-dark.svg
      alt: My Project
      width: 24
      height: 24
```
{: data-title="_config.yml"}

### Typography and Tokens

- `typography.body_font_family`
- `typography.code_font_family`
- `typography.google_fonts_url` (`false` disables external font loading)
- `tokens.light`
- `tokens.dark`

```yaml
jekyll_vitepress:
  typography:
    body_font_family: "'Inter', ui-sans-serif, system-ui, sans-serif"
    code_font_family: "'JetBrains Mono', ui-monospace, monospace"
    google_fonts_url: "https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap"
  tokens:
    light:
      --vp-c-brand-1: "#3451b2"
      --vp-c-brand-2: "#3a5ccc"
    dark:
      --vp-c-brand-1: "#a8b1ff"
      --vp-c-brand-2: "#bac2ff"
```
{: data-title="_config.yml"}

### Syntax Highlighting (Rouge)

- `syntax.light_theme`
- `syntax.dark_theme`

These values map directly to installed Rouge theme names.

```yaml
jekyll_vitepress:
  syntax:
    light_theme: github
    dark_theme: github.dark
```
{: data-title="_config.yml"}

### Footer and Doc Footer

- `footer.enabled`
- `footer.show_on_docs` (defaults to `false`; footer only shows on home page unless set to `true`)
- `footer.message`
- `footer.copyright`
- `doc_footer.enabled`
- `doc_footer.previous_label`
- `doc_footer.next_label`

```yaml
jekyll_vitepress:
  footer:
    enabled: true
    message: Released under the MIT License.
    copyright: © 2026-present You
    show_on_docs: false
  doc_footer:
    enabled: true
    previous_label: Previous page
    next_label: Next page
```
{: data-title="_config.yml"}

### Edit Link, Last Updated, GitHub Star, GitHub Sponsor, and Gem Downloads

- `edit_link.enabled`
- `edit_link.pattern`
- `edit_link.text`
- `last_updated.enabled`
- `last_updated.text`
- `last_updated.format` (`vitepress` for browser-local VitePress-style formatting, or a Jekyll strftime string)
- `github_star.enabled`
- `github_star.repository` (`owner/repo`)
- `github_star.text`
- `github_star.show_count`
- `github_sponsor.enabled`
- `github_sponsor.user` (GitHub Sponsors account name)
- `github_sponsor.url` (optional custom sponsorship URL)
- `github_sponsor.text`
- `github_sponsor.label`
- `gem_downloads.enabled`
- `gem_downloads.name` or `gem_downloads.gem`
- `gem_downloads.url` (optional custom downloads URL)
- `gem_downloads.text`
- `gem_downloads.label`
- `gem_downloads.show_count`

```yaml
jekyll_vitepress:
  edit_link:
    enabled: true
    pattern: "https://github.com/you/project/edit/main/docs/:path"
    text: Edit this page on GitHub
  last_updated:
    enabled: true
    text: Last updated
    format: vitepress
  github_star:
    enabled: true
    repository: you/project
    text: Star
    show_count: true
  github_sponsor:
    enabled: true
    user: you
    text: Sponsor
  gem_downloads:
    enabled: true
    name: your_gem
    text: Gem downloads
    url: https://rubygems.org/gems/your_gem
    label: View gem downloads
    show_count: true
```
{: data-title="_config.yml"}

If `github_sponsor.url` is omitted, the theme links to `https://github.com/sponsors/:user`.
If `gem_downloads.url` is omitted, the page-level downloads include links to `https://rubygems.org/gems/:name`.
If `last_updated.format` is `vitepress`, the static fallback is replaced in the browser using `Intl.DateTimeFormat` with medium date and medium time, matching VitePress. Use a Jekyll strftime string such as `"%b %-d, %Y, %-I:%M:%S %p"` for a static custom format.

### Copy Page

- `copy_page.enabled` (defaults to `true`)

Copy page adds a split button to each doc page header. The main button copies the page as raw Markdown. The dropdown includes a "View as Markdown" link that opens the page as a plain `.md` file (generated alongside the HTML at build time).

To disable:

```yaml
jekyll_vitepress:
  copy_page:
    enabled: false
```
{: data-title="_config.yml"}

Per-page disable via frontmatter:

```yaml
jekyll_vitepress:
  copy_page: false
```
{: data-title="page frontmatter"}

### Labels and Behavior

- `labels.outline`
- `labels.sidebar_menu`
- `labels.return_to_top`
- `labels.skip_to_content`
- `labels.appearance_menu`
- `labels.switch_to_dark`
- `labels.switch_to_light`
- `behavior.scroll_offset`

```yaml
jekyll_vitepress:
  labels:
    outline: On this page
    sidebar_menu: Menu
    return_to_top: Return to top
    skip_to_content: Skip to content
    appearance_menu: Appearance
    switch_to_dark: Switch to dark theme
    switch_to_light: Switch to light theme
  behavior:
    scroll_offset: 134
```
{: data-title="_config.yml"}

## `_data` files

### Navigation (`_data/navigation.yml`)

Top navbar links:

```yaml
- title: Guide
  url: /what-is-jekyll-vitepress-theme/
  collections: [introduction, core_features, advanced]
- title: Reference
  url: /configuration-reference/
  collections: [reference]
```
{: data-title="_data/navigation.yml"}

### Sidebar (`_data/sidebar.yml`)

Collection-driven sidebar groups:

```yaml
- title: Introduction
  collection: introduction
- title: Core Features
  collection: core_features
- title: Advanced
  collection: advanced
- title: Reference
  collection: reference
```
{: data-title="_data/sidebar.yml"}

Within each collection, page frontmatter controls hierarchy:

```yaml
---
title: Tools
nav_order: 2
has_children: true
---
```

```yaml
---
title: Tool Parameters
parent: Tools
nav_order: 1
---
```

The theme supports nested items using `parent`, optional `grand_parent`, and `nav_order`, matching common Jekyll documentation conventions while rendering a VitePress-style sidebar tree. Set `collapsed: true` on a parent page to close that branch by default.

### Social links (`_data/social_links.yml`)

- `icon`: built-in icon slug
- `url`: link target
- `label`: aria label
- `icon_svg`: optional custom inline SVG

```yaml
- icon: github
  url: https://github.com/you/project
  label: GitHub
- icon: x
  url: https://x.com/you
  label: X
- icon: custom
  url: https://bsky.app/profile/you
  label: Bluesky
  icon_svg: '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M12 11.388c0-.756 1.676-3.35 3.43-4.594 2.296-1.627 3.726-1.348 4.3-.225.672 1.316-.53 4.77-2.257 6.48-.958.949-1.786 1.433-2.84 1.356-.67-.05-1.167-.35-1.586-.824-.49-.554-.732-1.346-1.047-2.193-.315.847-.557 1.64-1.047 2.193-.419.474-.916.775-1.586.824-1.054.077-1.882-.407-2.84-1.356C5.8 11.339 4.6 7.885 5.271 6.57c.574-1.124 2.004-1.402 4.3.225 1.754 1.243 3.43 3.838 3.43 4.594Z"/></svg>'
```
{: data-title="_data/social_links.yml"}

Built-in icon slugs are:
`github`, `gitlab`, `bitbucket`, `discord`, `slack`, `x`, `twitter`,
`mastodon`, `linkedin`, `youtube`, `facebook`, `instagram`, `reddit`,
`bluesky`, `telegram`, `twitch`, `npm`, `medium`, `devdotto`, `dribbble`,
`stackoverflow`, `rss`, and `blog` (alias of `rss`).

### Versions (`_data/versions.yml`)

If this file exists, it drives the version selector:

```yaml
current: auto
items:
  - id: v2.0.0
    title: v2.0.0 (latest)
    url: /
  - id: v1.0.0
    title: v1.0.0
    url: /v1.0.0/
  - title: Changelog
    url: https://github.com/you/project/releases
    external: true
```
{: data-title="_data/versions.yml"}

`current: auto` resolves to `v#{Jekyll::VitePressTheme::VERSION}` at build time.

## Theme hooks (Jekyll include overrides)

Use these optional include files to inject custom markup without forking layouts:

- `_includes/jekyll_vitepress/head_end.html`
- `_includes/jekyll_vitepress/doc_footer_end.html`
- `_includes/jekyll_vitepress/layout_end.html`

If the files are absent in your site, the theme's empty defaults are used.

```html
<div class="my-doc-footer">
  Need help? <a href="/support/">Contact support</a>.
</div>
```
{: data-title="_includes/jekyll_vitepress/doc_footer_end.html"}
