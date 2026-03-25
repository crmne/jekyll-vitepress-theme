# What Is Jekyll VitePress Theme?

[Jekyll](https://jekyllrb.com/) is a static site generator written in [Ruby](https://www.ruby-lang.org/). It turns [Markdown](https://www.markdownguide.org/), [Liquid](https://shopify.github.io/liquid/) templates, and [data files](https://jekyllrb.com/docs/datafiles/) into static HTML you can deploy almost anywhere — no application server, no database, just files on a CDN.

Jekyll powers a huge number of documentation sites and blogs, particularly in the Ruby ecosystem and [GitHub Pages](https://pages.github.com/) workflows. If you've ever pushed a `docs/` folder to GitHub and had a site appear, you've likely used Jekyll.

## What this theme is

[Jekyll VitePress Theme](https://github.com/crmne/jekyll-vitepress-theme) is a Jekyll theme **and** plugin gem that recreates the [VitePress](https://vitepress.dev/) documentation experience — the same polished look and feel, entirely within Jekyll:

- **Top navigation** with mobile nav screen, social links, and optional GitHub star count
- **Left sidebar** driven by your Jekyll collections and data files
- **Right "On this page" outline** that tracks your scroll position
- **Code blocks** with copy buttons, language labels, and file-title bars with icons
- **Custom blocks** for tips, warnings, and callouts that match VitePress containers
- **Home layout** with hero section and feature cards
- **Doc footer** with edit link, previous/next pager, and automatic last-updated timestamps
- **Built-in local search** triggered with `/` or `Ctrl/Cmd+K`
- **Dark mode** with an appearance toggle that respects system preference
- **Markdown enhancements** — header anchors, external link icons, styled tables, and automatic title injection

Everything is configured through `_config.yml` and `_data/*.yml` files — no JavaScript build step, no Node.js toolchain.

## Why this exists

[VitePress](https://vitepress.dev/) has arguably the best documentation UX available today, but it depends on a [Node.js](https://nodejs.org/) + [Vite](https://vite.dev/) toolchain. That's a fine choice for JavaScript projects, but if you're building something in Ruby, adding an entire Node.js pipeline just for docs feels like the wrong trade-off.

This theme brings VitePress's visual and interaction model to Jekyll, so you can write your docs in Markdown, configure everything in YAML, and deploy with the tools you already know.
