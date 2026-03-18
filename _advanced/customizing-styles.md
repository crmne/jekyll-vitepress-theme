---
title: Customizing Styles
nav_order: 1
description: Override tokens, fonts, and appearance behavior.
---

Use `jekyll_vitepress.tokens.light` and `jekyll_vitepress.tokens.dark` to override VitePress token variables.

```yaml
jekyll_vitepress:
  tokens:
    light:
      --vp-c-brand-1: "#3451b2"
      --vp-c-brand-2: "#3a5ccc"
    dark:
      --vp-c-brand-1: "#a8b1ff"
      --vp-c-brand-2: "#bac2ff"
```
{: data-title="_config.yml"}

Font stacks are controlled with:

- `jekyll_vitepress.typography.body_font_family`
- `jekyll_vitepress.typography.code_font_family`

Appearance mode defaults to system preference and can be overridden by user toggle.
