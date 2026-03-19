# Jekyll VitePress Theme

A reusable Jekyll theme gem that reproduces the VitePress default docs experience.

## What it includes

- VitePress-style layout structure (top nav, sidebar, outline, doc footer)
- Appearance toggle with `auto -> dark -> light`
- Local search modal (`/`, `Ctrl/Cmd+K`, `Cmd+K`)
- Optional GitHub star button with live count (`jekyll_vitepress.github_star`)
- Code block copy button, language labels, file-title bars and icons
- Rouge-native syntax theme config (`jekyll_vitepress.syntax.light_theme/dark_theme`)
- Last-updated hook via plugin
- Jekyll-native extension hooks (`_includes/jekyll_vitepress/head_end.html`, `doc_footer_end.html`, `layout_end.html`)

## Installation

1. Add the gem to your `Gemfile`:

```ruby
gem "jekyll-vitepress-theme"
```

2. Enable it in `_config.yml`:

```yaml
theme: jekyll-vitepress-theme
plugins:
  - jekyll-vitepress-theme
```

3. Add theme behavior config in `_config.yml`:

```yaml
jekyll_vitepress:
  branding:
    site_title: My Docs
  syntax:
    light_theme: github
    dark_theme: github.dark
```

4. Add navigation and sidebar data files:

```yaml
# _data/navigation.yml
- title: Guide
  url: /getting-started/
  collections: [introduction, core_features, advanced]
```

```yaml
# _data/sidebar.yml
- title: Getting Started
  collection: introduction
```

## Local development (this repo)

```bash
bundle install
npm install
bundle exec jekyll serve --livereload
```

Open `http://127.0.0.1:4000`.

## Local Quality Gates

```bash
# one-shot verification
bundle exec rake verify

# regenerate built-in social icon assets after changing icon list
npm run build:social-icons

# install and run git hooks
bundle exec overcommit --install
bundle exec overcommit --sign pre-commit
bundle exec overcommit --sign pre-push
bundle exec overcommit --run
```

## Docs deployment (this repo)

- `master` deploys a single docs site at `/`
- No secondary version paths are published in default mode (`/latest/`, `/v/*`, `/next/`)
- Optional multi-version deployment is documented in [_advanced/deployment.md](_advanced/deployment.md)

## Theme configuration

See docs pages:

- [Getting Started](/getting-started/)
- [Configuration Reference](/configuration-reference/)
- [Frontmatter Reference](/frontmatter-reference/)
- [VitePress Parity and Extensions](/vitepress-parity-and-extensions/)

## Release a gem

```bash
gem build jekyll-vitepress-theme.gemspec
gem push jekyll-vitepress-theme-<version>.gem
```

## License

MIT
