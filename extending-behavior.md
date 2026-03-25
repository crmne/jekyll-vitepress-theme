# Extending Behavior

Because this is Jekyll, extension is straightforward — override a file and you're done. The theme provides several levels of customization, from simple hooks to full layout overrides.

## Hook includes (non-destructive)

The easiest way to add custom markup is through the theme's hook includes. Create any of these files in your site and they'll be injected at the right point:

- `_includes/jekyll_vitepress/head_end.html` — injected just before `</head>`. Use this for analytics scripts, meta tags, or extra stylesheets.
- `_includes/jekyll_vitepress/doc_footer_end.html` — injected after the doc footer. Use this for feedback widgets, related pages, or custom CTAs.
- `_includes/jekyll_vitepress/layout_end.html` — injected just before `</body>`. Use this for chat widgets, global scripts, or modals.

For example, to add a simple feedback prompt after every doc page:

```html
<div class="my-feedback">
  Was this page helpful?
  <a href="/feedback/">Let us know</a>.
</div>
```
{: data-title="_includes/jekyll_vitepress/doc_footer_end.html"}

If these files don't exist in your site, the theme's empty defaults are used — no errors, no output.

## Include overrides

For deeper changes, override any of the theme's built-in includes by creating a file with the same path in your site's `_includes/` directory. Jekyll will use your version instead of the gem's.

Common overrides:

- `_includes/nav.html` — customize the top navigation
- `_includes/sidebar.html` — change sidebar rendering
- `_includes/doc_footer.html` — modify the doc footer layout

## Layout overrides

You can also override `_layouts/default.html` entirely. This gives you full control over the page structure, but means you'll need to update your override if the theme changes its layout in future versions.

## Custom JS and CSS

To add your own JavaScript or CSS, use the `head_end.html` hook include:

```html
<link rel="stylesheet" href="/assets/css/custom.css">
<script src="/assets/js/custom.js" defer></script>
```
{: data-title="_includes/jekyll_vitepress/head_end.html"}






<div class="warning custom-block">
  <p class="custom-block-title">WARNING</p>
  <p>If you override includes or layouts that contain interactive elements (sidebar, outline, search), keep the existing class names and DOM structure intact. The theme’s JavaScript relies on these to wire up sidebar toggling, scroll tracking, and search behavior.
</p>
</div>


