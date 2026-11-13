---
title: Deployment
nav_order: 3
description: Publish your docs to GitHub Pages, with the latest release at the root, the default branch at /next/, and older major versions kept online.
---

## Build command

The theme ships a `jekyll-vitepress` command. Run it from the directory that
holds your docs `_config.yml` and `Gemfile`:

```sh
bundle exec jekyll-vitepress build
```

Without any version settings, it is an ordinary `jekyll build` into `_site`.
With [versions](#versioned-docs) configured, it builds every version and puts
them together in one `_site`. Pass `--baseurl /repo` when the site is served
under a path, and anything after `--` goes to each `jekyll build`:

```sh
bundle exec jekyll-vitepress build --baseurl /repo -- --trace
```

To preview, serve the site instead:

```sh
bundle exec jekyll-vitepress serve
```

It builds the same site, serves it at `http://127.0.0.1:4000`, and rebuilds
the checkout's version when you change a file (`/next/` with versions on).
`--host` and `--port` choose where it listens. `bundle exec jekyll serve`
still works too, for the checkout alone.

## Versioned docs

Most readers use the latest release, so it belongs at the root of your docs.
Work on the default branch goes to `/next/`, so documentation for unreleased
features is online without readers mistaking it for what they installed.
Configure this in `_config.yml`:

```yaml
jekyll_vitepress:
  versions:
    next: true
```
{: data-title="_config.yml"}

`jekyll-vitepress build` then builds:

| Path | Version | Built from |
| --- | --- | --- |
| `/` | Stable | The newest release tag, such as `v2.1.0` |
| `/next/` | Next (unreleased) | The checkout being built, the default branch in CI |

Release tags are `vX.Y.Z` or `X.Y.Z`; prereleases such as `v2.0.0.rc1` are
skipped. Each release is checked out in a Git worktree and built with your
current docs `Gemfile`, so theme fixes reach every version. CI needs the full
history and tags (`fetch-depth: 0` with `actions/checkout`).

Every version gets:

- the version selector in the navigation bar, listing every version, plus any
  external links (a changelog, say) from `_data/versions.yml`;
- a banner on `/next/` and older versions that says which version the reader
  is on and links to the stable docs;
- page titles that name the version, such as "Getting Started | MyGem Next",
  so search results and link previews tell the versions apart;
- canonical URLs, search, and Markdown pages of its own.

Search engines index only the stable docs: pages in `/next/` and older
versions say `noindex,follow`, their sitemaps and `llms.txt` stay empty, and
`robots.txt` lists the stable sitemap. Most of their pages repeat the stable
ones, and indexing them splits a page's ranking across copies. Set
`seo.index_versions: true` under `jekyll_vitepress` to index them too, which
also lists their sitemaps in `robots.txt`.

Until the first release tag exists, the command builds the checkout once, at
the root.

### Keeping an older major version online

When a major release changes the API, readers on the old one still need their
docs. List the major versions to keep:

```yaml
jekyll_vitepress:
  versions:
    next: true
    keep:
      - major: 1
        redirect_missing: true
```
{: data-title="_config.yml"}

This adds the newest `1.x.y` release at `/v1/`. With `redirect_missing`, URLs
that only exist in 1.x, such as pages removed in 2.0, redirect into `/v1/`
instead of returning 404. Each entry takes:

| Key | Default | Meaning |
| --- | --- | --- |
| `major` | (required) | The major version to keep |
| `id` | `v<major>` | Its id in the version selector |
| `path` | `/<id>/` | Where it is published |
| `title` | the release, such as `1.16.0` | Its name in the version selector; `:version` is replaced with the release |
| `label` | the id | Added to page titles, such as "MyGem v1" |
| `redirect_missing` | `false` | Redirect URLs that only exist in this version into it |
| `overlay` | none | Extra files for this version only (see below) |

### Version settings

| Key | Default | Meaning |
| --- | --- | --- |
| `next` | `true` | `false` publishes only releases. A hash takes `path` (`/next/`), `title` (`Next (unreleased)`), `label` (`Next`), and `id` (`next`) |
| `stable` | | A hash with `title` (`:version (stable)`) and `id` (`stable`) |
| `keep` | none | Older major versions, as above |
| `tag_prefix` | `v` or nothing | The text before `X.Y.Z` in release tags, for a repository that tags `mygem-v1.2.3` |
| `overlay` | none | Files copied from the current docs into every release before it is built |

Older releases are built from their own Markdown, layouts, and plugins. When
they need something only the current docs have, such as a plugin added since,
list it under `overlay`, as a path relative to the docs directory:

```yaml
jekyll_vitepress:
  versions:
    overlay:
      - _plugins/social_cards.rb
      - _data/llms_areas.yml
```
{: data-title="_config.yml"}

### Build hooks

Some docs need more than Jekyll: API reference pages, a generated page, or a
file copied into the finished site. Run commands around each build:

```yaml
jekyll_vitepress:
  build:
    before_build: bin/render-models-page
    after_build: bin/build-api-docs
    after_assemble: cp ../models.json "$VITEPRESS_SITE/"
```
{: data-title="_config.yml"}

`before_build` and `after_build` run once per version, and `after_assemble`
once, after the versions are put together. Each value is a shell command, or a
list of them, run from the docs directory, and they also run for a site
without versions. Hooks run outside the docs bundle, with the environment
`bundle exec` started from, so a hook can use the repository's own bundle.
`serve` runs them in its first build only. They get these environment
variables:

| Variable | Value |
| --- | --- |
| `VITEPRESS_VERSION_ID` | `stable`, `next`, `v1`, … (`current` without versions) |
| `VITEPRESS_VERSION_KIND` | `stable`, `next`, `older`, or `current` |
| `VITEPRESS_VERSION_REF` | The release tag, or `HEAD` for the checkout |
| `VITEPRESS_VERSION_SOURCE` | The docs directory being built: a worktree for releases |
| `VITEPRESS_VERSION_ROOT` | The repository root for that version |
| `VITEPRESS_VERSION_OUTPUT` | Where that version's site is built |
| `VITEPRESS_VERSION_BASEURL` | Its base URL, such as `/next` |
| `VITEPRESS_VERSION_URL` | Its full URL, such as `https://example.com/next/` |
| `VITEPRESS_SITE` | The finished site |
| `VITEPRESS_DOCS` | Your current docs directory |

### Banner text

The banner reads `labels` from `_config.yml`. `:site`, `:branch`,
`:version`, and `:stable` are replaced:

```yaml
jekyll_vitepress:
  labels:
    version_banner_next: "You're reading the docs for unreleased :site from :branch."
    version_banner_older: "You're reading the docs for :site :version."
    version_banner_link: "Read the :stable docs"
```
{: data-title="_config.yml"}

## GitHub Pages

The theme's repository has a reusable workflow that installs your docs bundle,
runs `jekyll-vitepress build`, deploys to GitHub Pages, and submits changed
pages to [IndexNow](https://www.indexnow.org/) when the repository has
`.github/scripts/indexnow.rb`. Add `.github/workflows/docs.yml`:

```yaml
name: Docs

on:
  push:
    branches: [main]
    paths:
      - docs/**
      - .github/workflows/docs.yml
  release:
    types: [published]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  docs:
    uses: crmne/jekyll-vitepress-theme/.github/workflows/publish-docs.yml@v1
```
{: data-title=".github/workflows/docs.yml"}

Publishing on a release updates the stable docs as soon as the tag is out;
pushes to the default branch update `/next/`. Then set **Settings → Pages →
Build and deployment → Source** to **GitHub Actions**.

The workflow takes these inputs:

| Input | Default | Meaning |
| --- | --- | --- |
| `docs-directory` | `docs` | Where `_config.yml` and the docs `Gemfile` are; `.` for a site at the repository root |
| `ruby-version` | `4.0` | Ruby for the build |
| `root-bundle` | `false` | Also install the repository's own `Gemfile`, for hooks that need it |
| `apt-packages` | none | Ubuntu packages the build needs, such as `libvips-tools` |

`@v1` follows the newest 1.x release of the theme. Your docs `Gemfile.lock`
still decides which theme version builds the site.
