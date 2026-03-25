# Navigation and Layout

The default layout mirrors the standard VitePress docs structure: a fixed top navbar, a left sidebar for section navigation, a main content area, and a right-side outline that tracks your scroll position.

## Page structure

Every docs page renders inside this layout:

```text
┌──────────────────────────────────────────────┐
│                  Top Navbar                  │
├────────┬───────────────────────┬─────────────┤
│        │                       │ On this page│
│Sidebar │      Content          │  - Heading  │
│        │                       │  - Heading  │
│        │                       │  - Heading  │
│        ├───────────────────────┤             │
│        │     Doc Footer        │             │
├────────┴───────────────────────┴─────────────┤
│              Global Footer                   │
└──────────────────────────────────────────────┘
```

Pages with `layout: home` skip the sidebar and outline, rendering the hero and feature cards at full width instead.

## Sidebar

Sidebar entries are driven by two things: your `_data/sidebar.yml` file and the `nav_order` frontmatter on each document.

```yaml
- title: Introduction
  collection: introduction
- title: Core Features
  collection: core_features
```
{: data-title="_data/sidebar.yml"}

Each group pulls documents from the named Jekyll collection and sorts them by `nav_order`. The currently active page is highlighted automatically. If a collection has no documents with frontmatter, that group won't render any links.

## Top navigation

The navbar links are defined in `_data/navigation.yml`. Each entry has a `title`, a `url`, and optionally a `collections` array:

```yaml
- title: Guide
  url: /introduction/
  collections: [introduction, core_features, advanced]
- title: Reference
  url: /configuration-reference/
  collections: [reference]
```
{: data-title="_data/navigation.yml"}

The `collections` array determines which nav link stays highlighted as the user navigates within those collections. For example, when viewing any page from the `core_features` collection, the "Guide" nav link remains active.

## Mobile navigation

On smaller screens, the sidebar collapses behind a menu button. Tapping it reveals a full-screen navigation overlay with the same sidebar groups. The menu button label is configurable via `jekyll_vitepress.labels.sidebar_menu` (defaults to "Menu").

## Home layout

Set `layout: home` in your page's frontmatter to render a landing page with a hero section and feature cards. Home pages don't show the sidebar or outline — they're full-width by design. See the [Frontmatter Reference]({% link _reference/frontmatter-reference.md %}) for all available home layout keys.
