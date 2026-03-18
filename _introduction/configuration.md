---
title: Configuration
nav_order: 3
description: Configure branding, nav, sidebars, edit links, and theme tokens.
---

Theme behavior lives under `jekyll_vitepress` in `_config.yml`.
Navigation and other displayed lists are defined in `_data/*.yml` files.

```yaml
jekyll_vitepress:
  branding:
    site_title: Your Project
    logo:
      default: /assets/images/theme/vitepress-logo-mini.svg
      light: /assets/images/theme/vitepress-logo-mini.svg
      dark: /assets/images/theme/vitepress-logo-mini.svg
      alt: Your Project
      width: 24
      height: 24

  syntax:
    light_theme: github
    dark_theme: github.dark

  typography:
    google_fonts_url: "https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap"
    body_font_family: "'Inter', ui-sans-serif, system-ui, sans-serif"
    code_font_family: "'JetBrains Mono', ui-monospace, monospace"

  tokens:
    light:
      # --vp-c-brand-1: "#3451b2"
    dark:
      # --vp-c-brand-1: "#a8b1ff"

  edit_link:
    enabled: true
    pattern: "https://github.com/you/project/edit/main/:path"
    text: Edit this page on GitHub
```
{: data-title="_config.yml"}

Navigation and sidebar structure:

```yaml
# _data/navigation.yml
- title: Guide
  url: /what-is-jekyll-vitepress-theme/
  collections: [introduction, core_features, advanced]
```

```yaml
# _data/sidebar.yml
- title: Introduction
  collection: introduction
```

For complete keys, see [Configuration Reference]({% link _reference/configuration-reference.md %}).

Social icons come from `_data/social_links.yml` and support built-in icon slugs plus custom inline SVG through `icon_svg`.

Version selector data lives in `/_data/versions.yml`.
Set `current: auto` to resolve to `v#{Jekyll::VitePressTheme::VERSION}` at build time.

Optional GitHub star button:

```yaml
jekyll_vitepress:
  github_star:
    enabled: true
    repository: you/project
    text: Star
    show_count: true
```
{: data-title="_config.yml"}

Need custom `<head>` tags (extra fonts, analytics, verification meta)?
Create `_includes/jekyll_vitepress/head_end.html` in your site.
