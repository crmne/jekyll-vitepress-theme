---
title: Nested Sidebar Items
parent: Navigation and Layout
nav_order: 1
description: Use Jekyll frontmatter to build VitePress-style nested sidebar trees inside each collection.
---

Jekyll VitePress keeps sidebar configuration Jekyll-native: `_data/sidebar.yml` names the collection groups, and page frontmatter controls hierarchy inside each collection.

## Parent pages

Give the parent page a title and `nav_order`. `has_children` is optional, but it documents intent and keeps the frontmatter familiar for sites migrating from other Jekyll documentation themes.

```yaml
---
title: Chat
nav_order: 1
has_children: true
---
```
{: data-title="_core_features/chat.md"}

## Child pages

Set `parent` to the parent page title. Child pages are rendered below their parent and sorted by their own `nav_order`.

```yaml
---
title: Streaming
parent: Chat
nav_order: 2
---
```
{: data-title="_core_features/streaming.md"}

Use `grand_parent` when two branches reuse the same parent title:

```yaml
---
title: Options
parent: Setup
grand_parent: Reference
nav_order: 1
---
```
{: data-title="_reference/options.md"}

## Collapsed branches

Add `collapsed: true` to a parent page to close that branch by default. Active branches are always opened so the current page stays visible.

```yaml
---
title: Advanced Topics
nav_order: 4
has_children: true
collapsed: true
---
```
{: data-title="_advanced/advanced-topics.md"}

Nested sidebar items follow the VitePress default theme shape and render up to six visible levels, counting the collection group as the root level.
