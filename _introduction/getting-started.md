---
title: Getting Started
nav_order: 2
description: Install and run Jekyll VitePress Theme in a few minutes.
---

Install the theme gem and enable it as both `theme` and plugin.

## 1. Add the gem

```ruby
gem "jekyll-vitepress-theme"
```
{: data-title="Gemfile"}

Then install:

```sh
bundle install
```

## 2. Enable theme and plugin

```yaml
theme: jekyll-vitepress-theme
plugins:
  - jekyll-vitepress-theme
```
{: data-title="_config.yml"}

## 3. Add Jekyll-native config and data

Theme behavior lives in `_config.yml` under `jekyll_vitepress`:

```yaml
jekyll_vitepress:
  branding:
    site_title: My Project
  syntax:
    light_theme: github
    dark_theme: github.dark
```
{: data-title="_config.yml"}

Navigation and sidebar structure live in `_data`:

```yaml
# _data/navigation.yml
- title: Guide
  url: /getting-started/
  collections: [introduction, core_features, advanced]
- title: Reference
  url: /configuration-reference/
  collections: [reference]
```

```yaml
# _data/sidebar.yml
- title: Introduction
  collection: introduction
- title: Core Features
  collection: core_features
- title: Advanced
  collection: advanced
- title: Reference
  collection: reference
```

## 4. Run locally

```sh
bundle exec jekyll serve --livereload
```

Open `http://127.0.0.1:4000`.

<div class="tip custom-block">
  <p class="custom-block-title">TIP</p>
  <p>Set <code>layout: home</code> on your home page front matter to render the VitePress-style hero/features home without sidebar.</p>
</div>
