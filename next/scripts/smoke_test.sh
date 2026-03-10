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

echo "Smoke test passed for ${SITE_DIR}"
