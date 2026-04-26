---
title: What Is Jekyll VitePress Theme?
nav_order: 1
description: What Jekyll is, and what this theme adds on top.
---

[Jekyll](https://jekyllrb.com/) is a static site generator written in [Ruby](https://www.ruby-lang.org/). It turns [Markdown](https://www.markdownguide.org/), [Liquid](https://shopify.github.io/liquid/) templates, and [data files](https://jekyllrb.com/docs/datafiles/) into static HTML you can deploy almost anywhere. There is no application server and no database, just files on a CDN.

Jekyll powers a huge number of documentation sites and blogs, particularly in the Ruby ecosystem and [GitHub Pages](https://pages.github.com/) workflows. If you've ever pushed a `docs/` folder to GitHub and had a site appear, you've likely used Jekyll.

## What this theme is

[Jekyll VitePress Theme](https://github.com/crmne/jekyll-vitepress-theme) is a Jekyll theme **and** plugin gem that recreates the [VitePress](https://vitepress.dev/) documentation experience inside a Ruby project:

- **Top navigation** with mobile nav screen, social links, and optional GitHub star count
- **Left sidebar** driven by your Jekyll collections and data files
- **Right "On this page" outline** that tracks your scroll position
- **Turbo Frame page navigation** that swaps doc content while keeping the shell in place
- **Code blocks** with copy buttons, language labels, and file-title bars with icons
- **Custom blocks** for tips, warnings, and callouts that match VitePress containers
- **Home layout** with hero section and feature cards
- **Doc footer** with edit link, previous/next pager, and automatic last-updated timestamps
- **Built-in local search** triggered with `/` or `Ctrl/Cmd+K`
- **Dark mode** with an appearance toggle that respects system preference
- **Markdown enhancements:** header anchors, external link icons, styled tables, and automatic title injection

Everything is configured through `_config.yml` and `_data/*.yml` files. There is no Vite app to maintain, no JavaScript bundle step, and no second documentation stack sitting beside your Ruby app or gem.

## Why this exists

[VitePress](https://vitepress.dev/) has one of the best documentation experiences available today, but it comes from the Node.js and Vite ecosystem. That is a good fit for JavaScript projects. It can feel like the wrong trade-off when the rest of your project is Ruby.

This theme brings that visual and interaction model to Jekyll. You write Markdown, configure YAML, render static HTML, and still get fast page changes through Turbo Frames.
