---
title: Configuration
nav_order: 3
description: Configure branding, nav, sidebars, edit links, and theme tokens.
---

All theme options live under `vp_theme` in `_config.yml`.

```yaml
vp_theme:
  logo: /assets/images/theme/vitepress-logo-mini.svg
  logo_light: /assets/images/theme/vitepress-logo-mini.svg
  logo_dark: /assets/images/theme/vitepress-logo-mini.svg
  site_title: Your Project

  nav:
    - text: Guide
      link: /what-is-jekyll-vitepress-theme/
      collections: [getting_started, core_features, advanced]

  version:
    current: auto
    items:
      - text: v1.0.0 (current)
        link: /
      - text: Changelog
        link: https://github.com/you/project/releases
        external: true

  social_links:
    - icon: github
      link: https://github.com/you/project
      aria_label: GitHub

  rouge_theme:
    light: github
    dark: github.dark

  google_fonts_url: "https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap"

  css_vars:
    light:
      # --vp-c-brand-1: "#3451b2"
    dark:
      # --vp-c-brand-1: "#a8b1ff"
```
{: data-title="_config.yml"}

For complete keys, see [Configuration Reference]({% link _reference/configuration-reference.md %}).

Social icons support a curated built-in set (GitHub, X/Twitter, Discord, YouTube, etc.) and also custom SVG via `icon.svg` for anything else.

Need custom `<head>` tags (extra fonts, analytics, verification meta)?
Create `_includes/vp_slots/head.html` in your site and add your tags there.

If `/_data/versions.yml` exists, it overrides `vp_theme.version` and drives the version selector.
Use this only for advanced multi-version docs setups.

`vp_theme.version.current` can be set to `auto` to use the gem version from `Jekyll::VitePressTheme::VERSION`.
