# Nested Sidebar Items

Jekyll VitePress keeps sidebar configuration Jekyll-native: `_data/sidebar.yml` names the collection groups, and page frontmatter controls hierarchy inside each collection.

## Parent pages

Give the parent page a title and `nav_order`. `has_children` is optional, but it documents intent and keeps the frontmatter familiar for sites migrating from other Jekyll documentation themes.

**_core_features/chat.md**

```yaml
---
title: Chat
nav_order: 1
has_children: true
---
```

## Child pages

Set `parent` to the parent page title. Child pages are rendered below their parent and sorted by their own `nav_order`.

**_core_features/streaming.md**

```yaml
---
title: Streaming
parent: Chat
nav_order: 2
---
```

Use `grand_parent` when two branches reuse the same parent title:

**_reference/options.md**

```yaml
---
title: Options
parent: Setup
grand_parent: Reference
nav_order: 1
---
```

## Collapsed branches

Add `collapsed: true` to a parent page to close that branch by default. Active branches are always opened so the current page stays visible.

**_advanced/advanced-topics.md**

```yaml
---
title: Advanced Topics
nav_order: 4
has_children: true
collapsed: true
---
```

Nested sidebar items follow the VitePress default theme shape and render up to six visible levels, counting the collection group as the root level.
