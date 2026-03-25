# Deployment

## Single docs site (recommended)

The simplest and recommended approach is deploying one canonical docs site at `/`. This is the standard GitHub Pages workflow:

1. Build Jekyll at the repository root.
2. Publish the output to the `gh-pages` branch (or configure GitHub Pages to build from your default branch).

With GitHub Actions, a minimal workflow looks like:

```yaml
- uses: actions/jekyll-build-pages@v1
- uses: actions/deploy-pages@v4
```

This keeps CI simple and avoids the complexity of managing multiple doc versions.

## Multi-version docs (optional)

If your project needs versioned documentation — say, `/next/` for the development branch, `/latest/` for the current release, and `/v/1.0.0/` for specific versions — the theme includes scripts to support this pattern:

- `scripts/version_manifest.rb` generates `_data/versions.yml` from your release history
- `scripts/publish_gh_pages.sh` handles publishing in two modes:
  - `next` — publishes to the `/next/` path
  - `release` — publishes to both `/v/x.y.z/` and `/latest/`

A typical CI flow:

1. **On every push to the default branch**, build docs with `baseurl: /next` and publish with `publish_gh_pages.sh next`.
2. **On release**, build for `/v/x.y.z` and `/latest`, then publish with `publish_gh_pages.sh release`.
3. `_data/versions.yml` on the `gh-pages` branch becomes the source of truth for the version selector dropdown.

When `_data/versions.yml` is present and contains version items, the theme renders a version selector in the navbar automatically.






<div class="warning custom-block">
  <p class="custom-block-title">WARNING</p>
  <p>Multi-version mode adds operational complexity — caching behavior, legacy paths, and rebuild coordination all need attention. Only use it when you genuinely need immutable version snapshots. For most projects, a single docs site with a changelog link is sufficient.
</p>
</div>



In your repository's GitHub Pages settings, configure the source to serve from branch `gh-pages` (root).
