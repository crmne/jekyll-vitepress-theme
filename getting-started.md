# Getting Started

This guide walks you through installing the theme and getting a working documentation site running locally. By the end, you'll have a Jekyll site with VitePress-style navigation, sidebar, and styling.

## Add the gem

Add the theme to your `Gemfile`:

```ruby
gem "jekyll-vitepress-theme"
```
{: data-title="Gemfile"}

Then install it:

```sh
bundle install
```

## Enable theme and plugin

The gem serves double duty — it provides layouts and assets as a **theme**, and registers Jekyll hooks as a **plugin**. You need to enable both:

```yaml
theme: jekyll-vitepress-theme
plugins:
  - jekyll-vitepress-theme
```
{: data-title="_config.yml"}

## Define your collections

Jekyll VitePress Theme uses [collections](https://jekyllrb.com/docs/collections/) to organize your documentation into groups. Define them in `_config.yml`:

```yaml
collections:
  guides:
    output: true
    permalink: "/:name/"
  reference:
    output: true
    permalink: "/:name/"

defaults:
  - scope:
      path: ""
    values:
      layout: default
```
{: data-title="_config.yml"}

Each collection becomes a folder (e.g., `_guides/`, `_reference/`) where you place your Markdown files. The `permalink: "/:name/"` setting gives each document a clean URL based on its filename.

## Configure branding and data files

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

Navigation and sidebar structure live in `_data/` files. The **navigation** defines your top navbar links and maps them to collections (so the correct nav item highlights when viewing pages from those collections):

```yaml
- title: Guide
  url: /getting-started/
  collections: [guides]
- title: Reference
  url: /api-reference/
  collections: [reference]
```
{: data-title="_data/navigation.yml"}

The **sidebar** defines the left-hand navigation groups. Each group pulls its entries from a collection, sorted by `nav_order` frontmatter:

```yaml
- title: Guides
  collection: guides
- title: Reference
  collection: reference
```
{: data-title="_data/sidebar.yml"}

## Create your first page

Create a document inside one of your collection folders:

```markdown
---
title: Introduction
nav_order: 1
---

Welcome to My Project! This is your first documentation page.
```
{: data-title="_guides/introduction.md"}

The `nav_order` value controls the sort order in the sidebar. Lower numbers appear first.

## Run locally

```sh
bundle exec jekyll serve --livereload
```

Open `http://127.0.0.1:4000` and you should see your site with the VitePress layout — top nav, sidebar, and your content in the center.

{% include alert.html type="tip" content="To add a VitePress-style landing page with a hero section and feature cards, set `layout: home` in your `index.md` frontmatter. See the [Frontmatter Reference](/frontmatter-reference/) for the full set of home layout keys." %}
