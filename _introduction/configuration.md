---
title: Configuration
nav_order: 3
description: Configure branding, nav, sidebars, edit links, and theme tokens.
---

All theme configuration follows a Jekyll-native pattern: rendering options go in `_config.yml` under `jekyll_vitepress`, while navigation and other displayed lists go in `_data/*.yml` files. There's nothing custom to learn. If you know Jekyll, you already know how this works.

## Branding and syntax highlighting

At minimum, set your site title. You can also configure a logo and syntax highlighting themes:

```yaml
jekyll_vitepress:
  branding:
    site_title: Your Project
    logo:
      default: /assets/images/logo.svg
      light: /assets/images/logo-light.svg
      dark: /assets/images/logo-dark.svg
      alt: Your Project
      width: 24
      height: 24

  syntax:
    light_theme: github
    dark_theme: github.dark
```
{: data-title="_config.yml"}

The `light_theme` and `dark_theme` values accept any installed [Rouge](https://github.com/rouge-ruby/rouge) theme name. The theme automatically generates scoped CSS for both modes at build time, so your code blocks look right in light and dark mode without any extra work.

## Typography and tokens

You can customize fonts and override VitePress CSS variables (tokens) for branding:

```yaml
jekyll_vitepress:
  typography:
    google_fonts_url: "https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap"
    body_font_family: "'Inter', ui-sans-serif, system-ui, sans-serif"
    code_font_family: "'JetBrains Mono', ui-monospace, monospace"

  tokens:
    light:
      --vp-c-brand-1: "#3451b2"
    dark:
      --vp-c-brand-1: "#a8b1ff"
```
{: data-title="_config.yml"}

Set `google_fonts_url: false` to disable external font loading entirely (useful if you want to serve fonts locally or use system fonts).

## Navigation and sidebar

Navigation links appear in the top navbar. Each link has a `title`, a `url` (where clicking it navigates), and a list of `collections` it "owns". This controls which nav item stays highlighted as the user browses pages within those collections:

```yaml
- title: Guide
  url: /what-is-jekyll-vitepress-theme/
  collections: [introduction, core_features, advanced]
- title: Reference
  url: /configuration-reference/
  collections: [reference]
```
{: data-title="_data/navigation.yml"}

Sidebar groups map directly to collections. Documents within each collection are sorted by their `nav_order` frontmatter value:

```yaml
- title: Introduction
  collection: introduction
- title: Core Features
  collection: core_features
```
{: data-title="_data/sidebar.yml"}

## Social links

Social icons appear in the top navbar. Use a built-in icon slug, or provide custom inline SVG:

```yaml
- icon: github
  url: https://github.com/you/project
  label: GitHub
- icon: x
  url: https://x.com/you
  label: X
```
{: data-title="_data/social_links.yml"}

For a full list of built-in icon slugs and custom SVG support, see the [Configuration Reference]({% link _reference/configuration-reference.md %}).

## Edit link

Point users to the source file on GitHub with an edit link in the doc footer:

```yaml
jekyll_vitepress:
  edit_link:
    enabled: true
    pattern: "https://github.com/you/project/edit/main/:path"
    text: Edit this page on GitHub
```
{: data-title="_config.yml"}

The `:path` placeholder is replaced with the source file's path at build time.

## Version selector

If `_data/versions.yml` exists, the theme renders a version selector dropdown in the navbar:

```yaml
current: auto
items:
  - title: v1.0.0 (current)
    url: /
  - title: Changelog
    url: https://github.com/you/project/releases
    external: true
```
{: data-title="_data/versions.yml"}

Set `current: auto` to automatically resolve to `v#{Jekyll::VitePressTheme::VERSION}` at build time. This is handy if your docs version should track your gem version.

## GitHub buttons

Show a GitHub star button with live count in the navbar:

```yaml
jekyll_vitepress:
  github_star:
    enabled: true
    repository: you/project
    text: Star
    show_count: true
```
{: data-title="_config.yml"}

You can also show a GitHub Sponsors button next to it:

```yaml
jekyll_vitepress:
  github_sponsor:
    enabled: true
    user: you
    text: Sponsor
```
{: data-title="_config.yml"}

Use `url` instead of `user` if you want to point to a custom sponsorship page.

## Extension hooks

Need custom `<head>` tags (analytics, verification meta, extra fonts)? Create any of these include files in your site to inject markup without forking the theme's layouts:

- `_includes/jekyll_vitepress/head_end.html`: appended inside `<head>`
- `_includes/jekyll_vitepress/doc_footer_end.html`: appended after the doc footer
- `_includes/jekyll_vitepress/layout_end.html`: appended before `</body>`

If these files don't exist in your site, the theme's empty defaults are used.

For complete configuration keys and detailed examples, see the [Configuration Reference]({% link _reference/configuration-reference.md %}).
