#!/usr/bin/env bash
set -euo pipefail

SITE_DIR="${1:-_site}"

if [[ ! -d "${SITE_DIR}" ]]; then
  echo "Smoke test failed: site directory not found (${SITE_DIR})"
  exit 1
fi

required_files=(
  "${SITE_DIR}/index.html"
  "${SITE_DIR}/search.json"
  "${SITE_DIR}/sitemap.xml"
  "${SITE_DIR}/robots.txt"
  "${SITE_DIR}/llms.txt"
  "${SITE_DIR}/llms-full.txt"
  "${SITE_DIR}/getting-started/index.html"
  "${SITE_DIR}/configuration-reference/index.html"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "${file}" ]]; then
    echo "Smoke test failed: missing file ${file}"
    exit 1
  fi
done

grep -q "VPNavBar" "${SITE_DIR}/index.html" || { echo "Smoke test failed: home nav markup missing"; exit 1; }
grep -q "VPHero" "${SITE_DIR}/index.html" || { echo "Smoke test failed: home hero markup missing"; exit 1; }
grep -q "VPVersionSelector" "${SITE_DIR}/getting-started/index.html" || { echo "Smoke test failed: version selector missing"; exit 1; }
grep -q "id=\"vp-search\"" "${SITE_DIR}/getting-started/index.html" || { echo "Smoke test failed: search container missing"; exit 1; }
grep -q "VPDocFooter" "${SITE_DIR}/getting-started/index.html" || { echo "Smoke test failed: doc footer missing"; exit 1; }
grep -q '"url": "/getting-started/"' "${SITE_DIR}/search.json" || { echo "Smoke test failed: generated search index missing docs content"; exit 1; }
grep -q '<link rel="canonical" href="https://jekyll-vitepress.dev/getting-started/">' "${SITE_DIR}/getting-started/index.html" || { echo "Smoke test failed: canonical URL missing"; exit 1; }
grep -q '"@type":"Article"' "${SITE_DIR}/getting-started/index.html" || { echo "Smoke test failed: Article JSON-LD missing"; exit 1; }
grep -q '"@type":"BreadcrumbList"' "${SITE_DIR}/getting-started/index.html" || { echo "Smoke test failed: breadcrumb JSON-LD missing"; exit 1; }
grep -q '<loc>https://jekyll-vitepress.dev/getting-started/</loc>' "${SITE_DIR}/sitemap.xml" || { echo "Smoke test failed: canonical URL missing from sitemap"; exit 1; }
grep -Fq 'Disallow: /*.md$' "${SITE_DIR}/robots.txt" || { echo "Smoke test failed: generated Markdown is crawlable"; exit 1; }
grep -q 'Sitemap: https://jekyll-vitepress.dev/sitemap.xml' "${SITE_DIR}/robots.txt" || { echo "Smoke test failed: sitemap missing from robots.txt"; exit 1; }
grep -q 'data-action="view-markdown"' "${SITE_DIR}/getting-started/index.html" || { echo "Smoke test failed: Markdown view control missing"; exit 1; }
if grep -qE '<a[^>]+href="/[^"]+\.md"' "${SITE_DIR}/getting-started/index.html"; then
  echo "Smoke test failed: Markdown duplicate exposed as a crawlable link"
  exit 1
fi
grep -q '\[Getting Started\](https://jekyll-vitepress.dev/getting-started/)' "${SITE_DIR}/llms.txt" || { echo "Smoke test failed: canonical docs missing from llms.txt"; exit 1; }
grep -q '^# Getting Started$' "${SITE_DIR}/llms-full.txt" || { echo "Smoke test failed: docs content missing from llms-full.txt"; exit 1; }
grep -q 'This guide walks you through installing the theme' "${SITE_DIR}/llms-full.txt" || { echo "Smoke test failed: full docs body missing from llms-full.txt"; exit 1; }

json_ld_count="$(grep -c 'application/ld+json' "${SITE_DIR}/getting-started/index.html")"
canonical_count="$(grep -c 'rel="canonical"' "${SITE_DIR}/getting-started/index.html")"
[[ "${json_ld_count}" == "1" ]] || { echo "Smoke test failed: duplicate JSON-LD (${json_ld_count})"; exit 1; }
[[ "${canonical_count}" == "1" ]] || { echo "Smoke test failed: duplicate canonical links (${canonical_count})"; exit 1; }

echo "Smoke test passed for ${SITE_DIR}"
