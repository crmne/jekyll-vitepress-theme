# Customizing Styles

The theme's visual design is built on CSS custom properties (tokens), making it straightforward to adjust colors, fonts, and spacing without touching any CSS files directly.

## Brand colors

The most common customization is changing the brand color. Use `jekyll_vitepress.tokens.light` and `jekyll_vitepress.tokens.dark` to override VitePress CSS variables:

```yaml
jekyll_vitepress:
  tokens:
    light:
      --vp-c-brand-1: "#3451b2"
      --vp-c-brand-2: "#3a5ccc"
      --vp-c-brand-3: "#2f4bab"
    dark:
      --vp-c-brand-1: "#a8b1ff"
      --vp-c-brand-2: "#bac2ff"
      --vp-c-brand-3: "#939eff"
```
{: data-title="_config.yml"}

Brand tokens affect links, the active nav highlight, the hero button, and other accent elements throughout the theme. The numbered variants (`brand-1`, `brand-2`, `brand-3`) control different states. `brand-1` is the primary color, `brand-2` is used for hover states, and `brand-3` for active/pressed states.

Any VitePress CSS variable can be overridden this way. To discover available tokens, inspect the theme's `assets/css/vitepress-overrides.css` or refer to the [VitePress theme configuration docs](https://vitepress.dev/reference/default-theme-config).

## Fonts

Font stacks are controlled through typography settings:

```yaml
jekyll_vitepress:
  typography:
    body_font_family: "'Inter', ui-sans-serif, system-ui, sans-serif"
    code_font_family: "'JetBrains Mono', ui-monospace, monospace"
    google_fonts_url: "https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap"
```
{: data-title="_config.yml"}

The `google_fonts_url` is loaded as a stylesheet in `<head>`. Set it to `false` to disable external font loading. This is useful if you're self-hosting fonts or prefer system fonts.

## Appearance mode

The theme ships with three appearance modes: **auto** (follows system preference), **dark**, and **light**. Users cycle through them with the appearance toggle in the navbar.

The user's choice is persisted in `localStorage`, so it sticks across page loads. When set to "auto", the theme tracks the operating system's `prefers-color-scheme` media query in real time.

No configuration is needed. This works out of the box. The toggle labels are customizable via `jekyll_vitepress.labels.appearance_menu`, `switch_to_dark`, and `switch_to_light`.
