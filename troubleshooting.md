# Troubleshooting

## Search modal does not open

- Confirm `search.json` is generated and reachable at `/search.json`. You can test this by visiting `http://127.0.0.1:4000/search.json` in your browser during local development.
- Confirm `assets/js/vitepress-theme.js` is loaded. Check your browser's DevTools console for 404 errors.
- If search works but misses certain pages, make sure those pages belong to a collection listed in `_data/sidebar.yml`. Only sidebar collections are indexed.

## Sidebar is empty

- Verify `_data/sidebar.yml` exists and each entry points to a valid collection name that matches a collection defined in `_config.yml`.
- Ensure each collection has at least one document with frontmatter (the `---` block at the top of the file). Files without frontmatter are not processed by Jekyll.
- Check that your collections are configured with `output: true` in `_config.yml`.

## Nav links do not render

- Verify `_data/navigation.yml` exists.
- Ensure each item has both `title` and `url` keys.
- If nav items don't highlight correctly, check that the `collections` array references valid collection names.

## Last updated does not appear

- Ensure the plugin is enabled in `_config.yml`:

```yaml
plugins:
  - jekyll-vitepress-theme
```
{: data-title="_config.yml"}

- Check that `jekyll_vitepress.last_updated.enabled` is not set to `false`.
- If a specific page has `jekyll_vitepress.last_updated: false` in its frontmatter, the timestamp is hidden for that page only.

## Theme looks unstyled

- Confirm the gem is installed: run `bundle list | grep vitepress` and check the output.
- Make sure `theme: jekyll-vitepress-theme` is set in `_config.yml` (not just in `plugins`).
- Check your browser's DevTools Network tab for 404s on CSS files. The theme expects these paths:
  - `assets/css/vitepress-core.css`
  - `assets/css/vitepress-components.css`
  - `assets/css/vitepress-overrides.css`

## Code blocks have no syntax colors

- Verify your Rouge theme names are valid. Invalid names produce a build warning and fall back to `github` / `github.dark`.
- Ensure `plugins: [jekyll-vitepress-theme]` is set — the Rouge CSS generation happens in the plugin hooks.
- Check that your Kramdown config uses Rouge as the syntax highlighter (this is the Jekyll default, but a custom `_config.yml` might override it).

## Dark mode code blocks use the wrong colors

- Make sure you've set both `light_theme` and `dark_theme` under `jekyll_vitepress.syntax`. If only one is set, both modes may use the same palette.

## Appearance toggle doesn't persist

- The toggle stores its state in `localStorage`. If your browser blocks localStorage (private/incognito mode in some browsers), the preference won't persist across page loads.

## Build fails with "Unknown Rouge theme" warning

- This is a warning, not an error — the build will still succeed, falling back to the default themes. To fix it, check your `jekyll_vitepress.syntax.light_theme` and `dark_theme` values against the list of [available Rouge themes](https://github.com/rouge-ruby/rouge/tree/master/lib/rouge/themes).
