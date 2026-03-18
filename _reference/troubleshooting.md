---
title: Troubleshooting
nav_order: 4
description: Common setup and runtime issues.
---

## Search modal does not open

- Confirm `search.json` is generated and reachable at `/search.json`.
- Confirm `assets/js/vitepress-theme.js` is loaded.

## Sidebar is empty

- Verify `/_data/sidebar.yml` exists and points to valid collection names.
- Ensure each collection has documents with front matter.

## Nav links do not render

- Verify `/_data/navigation.yml` exists.
- Ensure each item has `title` and `url`.

## Last updated does not appear

- Ensure plugin is enabled:

```yaml
plugins:
  - jekyll-vitepress-theme
```
{: data-title="_config.yml"}

## Theme looks unstyled

- Confirm these files are present and served:
  - `assets/css/vitepress-core.css`
  - `assets/css/vitepress-components.css`
  - `assets/css/vitepress-overrides.css`
