# Jekyll VitePress Theme

A reusable Jekyll theme gem that reproduces the VitePress default docs experience.

## What it includes

- VitePress-style layout structure (top nav, sidebar, outline, doc footer)
- Appearance toggle with `auto -> dark -> light`
- Local search modal (`/`, `Ctrl/Cmd+K`, `Cmd+K`)
- Code block copy button, language labels, file-title bars and icons
- Rouge-native syntax theme config (`vp_theme.rouge_theme.light/dark`)
- Last-updated hook via plugin
- Slot includes for lightweight theme extension (`_includes/vp_slots/head.html`, `doc_footer.html`, `layout_bottom.html`)

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

3. Add `vp_theme` configuration:

```yaml
vp_theme:
  nav:
    - text: Guide
      link: /what-is-jekyll-vitepress-theme/
      collections: [getting_started, core_features, advanced]
  sidebar_collections:
    - id: getting_started
      text: Introduction
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

- `main` deploys a single docs site at `/`
- No secondary version paths are published in default mode (`/latest/`, `/v/*`, `/next/`)
- Optional multi-version deployment is documented in [_advanced/deployment.md](_advanced/deployment.md)

## Theme configuration

See docs pages:

- [Getting Started](/getting-started/)
- [Configuration Reference](/configuration-reference/)
- [Frontmatter Reference](/frontmatter-reference/)

## Release a gem

```bash
gem build jekyll-vitepress-theme.gemspec
gem push jekyll-vitepress-theme-<version>.gem
```

## License

MIT
