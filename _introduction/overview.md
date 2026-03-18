---
title: Overview
nav_order: 4
description: How the theme is structured and what it aims to replicate from VitePress.
---

Jekyll VitePress Theme is a **theme + plugin gem**.

## Theme assets

The gem ships:

- `_layouts` and `_includes` for VitePress-like layout structure.
- `assets/css/*` with core/theme/override styles.
- `assets/js/vitepress-theme.js` for interactive behavior.

## Plugin behavior

The gem plugin registers Jekyll hooks for last-updated timestamps so docs footers can show `Last updated` without extra manual front matter.

## VitePress parity scope

The project targets parity for:

- top nav, sidebar, local nav, right outline
- header anchors and scroll tracking
- doc footer pager and edit-link support
- appearance switcher and system-theme mode
- code block copy buttons, language labels, title bars, and file icons
- Rouge-native light/dark syntax themes

It intentionally stays Jekyll-first for config and page authoring.

For an explicit checklist of parity vs theme-specific additions, see [VitePress Parity and Extensions]({% link _reference/vitepress-parity-and-extensions.md %}).
