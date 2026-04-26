<div align="center">

<img src="assets/images/theme/vitepress-logo-large.svg" alt="Jekyll VitePress Theme" height="96">

# Jekyll VitePress Theme

<strong>VitePress-style docs for Jekyll, without leaving Ruby.</strong>

[![Gem Version](https://img.shields.io/gem/v/jekyll-vitepress-theme.svg)](https://rubygems.org/gems/jekyll-vitepress-theme)
[![CI](https://github.com/crmne/jekyll-vitepress-theme/actions/workflows/main.yml/badge.svg)](https://github.com/crmne/jekyll-vitepress-theme/actions/workflows/main.yml)
[![Docs](https://img.shields.io/badge/docs-jekyll--vitepress.dev-blue)](https://jekyll-vitepress.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

---

Ruby projects should not need a JavaScript app just to get beautiful documentation.

`jekyll-vitepress-theme` brings the VitePress documentation experience to Jekyll: familiar navigation, sidebars, outlines, search, dark mode, code blocks, callouts, and doc footers, packaged as a Ruby gem.

The unusual part is navigation. Jekyll VitePress uses Turbo Frames like a Rails app, swapping only the content frame while the nav, sidebar, and shell stay in place. Page changes feel as fast as VitePress, while the output remains plain Jekyll: Markdown, Liquid, YAML, Ruby, and static files.

## Why Use It

- **As fast as VitePress:** Turbo Frames swap only the docs content while the nav, sidebar, and shell stay mounted.
- **Jekyll-native setup:** keep your existing pages, add the gem, configure the handful of Jekyll settings your site needs, and start publishing.
- **Familiar VitePress UX:** top nav, sidebar, right outline, search, dark mode, code blocks, callouts, and doc footers come ready to use.
- **More than VitePress:** add GitHub Star and Sponsor buttons, a version selector, generated local search, and Copy Page/View as Markdown for LLM workflows.
- **Static Ruby output:** build with Jekyll and deploy the generated HTML to GitHub Pages, any CDN, or any static host.

## Quick Start

Add the gem:

```rb
gem "jekyll-vitepress-theme"
```

Enable the theme and plugin:

```yaml
theme: jekyll-vitepress-theme
plugins:
  - jekyll-vitepress-theme
```

Add basic theme config:

```yaml
jekyll_vitepress:
  branding:
    site_title: My Docs
  syntax:
    light_theme: github
    dark_theme: github.dark
```

Define navigation and sidebar data:

```yaml
# _data/navigation.yml
- title: Guide
  url: /getting-started/
  collections: [guides]
```

```yaml
# _data/sidebar.yml
- title: Guide
  collection: guides
```

Run Jekyll:

```sh
bundle install
bundle exec jekyll serve --livereload
```

## Screenshots

| Home | Docs |
| --- | --- |
| ![Home page in light mode](assets/images/screenshots/home-light.png) | ![Docs page in light mode](assets/images/screenshots/getting-started-light.png) |

## Docs

Read the full documentation at **[jekyll-vitepress.dev](https://jekyll-vitepress.dev)**.

Start here:

- [Getting Started](https://jekyll-vitepress.dev/getting-started/)
- [Configuration](https://jekyll-vitepress.dev/configuration/)
- [Navigation and Layout](https://jekyll-vitepress.dev/navigation-layout/)
- [Search and Outline](https://jekyll-vitepress.dev/search-and-outline/)
- [Configuration Reference](https://jekyll-vitepress.dev/configuration-reference/)

## Development

```sh
bundle install
npm install
bundle exec jekyll serve --livereload
```

Run the local verification suite:

```sh
bundle exec rake verify
```

## License

MIT
