---
title: Configuration Reference
nav_order: 1
description: Complete `vp_theme` key reference with practical examples.
---

All theme configuration lives in your site root `_config.yml`, under the `vp_theme` key.

## Minimal setup

```yaml
vp_theme:
  logo: /assets/images/theme/vitepress-logo-mini.svg
  site_title: My Docs
  nav:
    - text: Guide
      link: /what-is-jekyll-vitepress-theme/
      collections: [getting_started, core_features, advanced]
  sidebar_collections:
    - id: getting_started
      text: Introduction
```
{: data-title="_config.yml"}

## Branding

- `logo`, `logo_light`, `logo_dark`
- `logo_width`, `logo_height`, `logo_alt`
- `site_title`

```yaml
vp_theme:
  logo_light: /assets/images/theme/vitepress-logo-mini.svg
  logo_dark: /assets/images/theme/vitepress-logo-mini.svg
  logo_width: 24
  logo_height: 24
  logo_alt: My Project
  site_title: My Project
```
{: data-title="_config.yml"}

## Navigation

- `nav`: top navbar links
- `version`: fallback version selector config
- `social_links`: right-side social links

```yaml
vp_theme:
  nav:
    - text: Guide
      link: /what-is-jekyll-vitepress-theme/
      collections: [getting_started, core_features, advanced]
    - text: Reference
      link: /configuration-reference/
      collections: [reference]

  version:
    current: auto
    items:
      - text: v0.9.0 (current)
        link: /
      - text: Changelog
        link: https://github.com/you/project/releases
        external: true

  social_links:
    - icon: github
      link: https://github.com/you/project
      aria_label: GitHub
    - icon: x
      link: https://x.com/you
      aria_label: X
    - icon:
        title: Bluesky
        svg: '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M12 11.388c0-.756 1.676-3.35 3.43-4.594 2.296-1.627 3.726-1.348 4.3-.225.672 1.316-.53 4.77-2.257 6.48-.958.949-1.786 1.433-2.84 1.356-.67-.05-1.167-.35-1.586-.824-.49-.554-.732-1.346-1.047-2.193-.315.847-.557 1.64-1.047 2.193-.419.474-.916.775-1.586.824-1.054.077-1.882-.407-2.84-1.356C5.8 11.339 4.6 7.885 5.271 6.57c.574-1.124 2.004-1.402 4.3.225 1.754 1.243 3.43 3.838 3.43 4.594Z"/></svg>'
      link: https://bsky.app/profile/you
      aria_label: Bluesky
```
{: data-title="_config.yml"}

If `/_data/versions.yml` exists, it becomes the source of truth for the version selector and overrides `vp_theme.version`.
This is intended for optional multi-version docs setups.

`vp_theme.version.current: auto` resolves to `v#{Jekyll::VitePressTheme::VERSION}` at build time.

Built-in icon slugs are:
`github`, `gitlab`, `bitbucket`, `discord`, `slack`, `x`, `twitter`,
`mastodon`, `linkedin`, `youtube`, `facebook`, `instagram`, `reddit`,
`bluesky`, `telegram`, `twitch`, `npm`, `medium`, `devdotto`, `dribbble`,
`stackoverflow`, `rss`, and `blog` (alias of `rss`).

For anything else, pass a custom inline SVG via `icon.svg` (VitePress-style).

## Sidebar

- `sidebar_collections`: controls left sidebar groups and ordering

```yaml
vp_theme:
  sidebar_collections:
    - id: getting_started
      text: Introduction
    - id: core_features
      text: Core Features
    - id: advanced
      text: Advanced
    - id: reference
      text: Reference
```
{: data-title="_config.yml"}

## Footer and Doc Footer

- `footer.message`, `footer.copyright`
- `footer.show_on_docs` (defaults to `false` to match VitePress behavior)
- `doc_footer.prev`, `doc_footer.next` (or `doc_footer: false`)
- `edit_link` and `last_updated` are independent from `doc_footer`

```yaml
vp_theme:
  footer:
    message: Released under the MIT License.
    copyright: © 2026-present You
    show_on_docs: false
  doc_footer:
    prev: Previous page
    next: Next page
```
{: data-title="_config.yml"}

`footer` is shown on pages without a sidebar by default (VitePress parity).
Set `footer.show_on_docs: true` if you want it on docs pages as well.

## Edit Link and Last Updated

- `edit_link.pattern`, `edit_link.text`
- `last_updated.text`, `last_updated.format`

```yaml
vp_theme:
  edit_link:
    pattern: "https://github.com/you/project/edit/main/docs/:path"
    text: Edit this page on GitHub
  last_updated:
    text: Last updated
    format: "%-d %b %Y, %H:%M"
```
{: data-title="_config.yml"}

## Appearance Labels and Behavior

- `outline_title`
- `scroll_offset`
- `sidebar_menu_label`
- `return_to_top_label`
- `skip_to_content_label`
- `dark_mode_switch_label`
- `dark_mode_switch_title`
- `light_mode_switch_title`

```yaml
vp_theme:
  outline_title: On this page
  scroll_offset: 134
  sidebar_menu_label: Menu
  return_to_top_label: Return to top
  skip_to_content_label: Skip to content
  dark_mode_switch_label: Appearance
  dark_mode_switch_title: Switch to dark theme
  light_mode_switch_title: Switch to light theme
```
{: data-title="_config.yml"}

## Typography

- `font_family_base`
- `font_family_mono`
- `google_fonts_url` (set to `false` to disable external font loading)

```yaml
vp_theme:
  font_family_base: "'Inter', ui-sans-serif, system-ui, sans-serif"
  font_family_mono: "'JetBrains Mono', ui-monospace, monospace"
  google_fonts_url: "https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap"
```
{: data-title="_config.yml"}

## Syntax Highlighting (Rouge)

- `rouge_theme.light`
- `rouge_theme.dark`

These values map directly to installed Rouge theme names.

```yaml
vp_theme:
  rouge_theme:
    light: github
    dark: github.dark
```
{: data-title="_config.yml"}

## CSS Variables

- `css_vars.light`
- `css_vars.dark`

Use this to override any VitePress token variable in a Jekyll-friendly way.

```yaml
vp_theme:
  css_vars:
    light:
      --vp-c-brand-1: "#3451b2"
      --vp-c-brand-2: "#3a5ccc"
    dark:
      --vp-c-brand-1: "#a8b1ff"
      --vp-c-brand-2: "#bac2ff"
```
{: data-title="_config.yml"}

## Theme Slots (Jekyll-style extension points)

Use these optional include files to inject custom markup without forking layouts:

- `_includes/vp_slots/head.html`: rendered at the end of `<head>` (fonts, analytics, custom meta tags).
- `_includes/vp_slots/doc_footer.html`: rendered after doc footer on docs pages.
- `_includes/vp_slots/layout_bottom.html`: rendered at the bottom of the main layout.

If the files are absent in your site, the theme’s empty defaults are used.

```html
<!-- _includes/vp_slots/doc_footer.html -->
<div class="my-doc-footer">
  Need help? <a href="/support/">Contact support</a>.
</div>
```
{: data-title="_includes/vp_slots/doc_footer.html"}
