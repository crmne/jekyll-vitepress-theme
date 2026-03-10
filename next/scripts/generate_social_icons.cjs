#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');
const iconsData = require('@iconify-json/simple-icons/icons.json');

const rootDir = path.resolve(__dirname, '..');
const iconsOutDir = path.join(rootDir, 'assets', 'images', 'social-icons');
const cssOutFile = path.join(rootDir, 'assets', 'css', 'vp-icons.css');

const defaultWidth = iconsData.width || 24;
const defaultHeight = iconsData.height || 24;
const curatedSocialIcons = [
  'github',
  'gitlab',
  'bitbucket',
  'discord',
  'slack',
  'x',
  'twitter',
  'mastodon',
  'linkedin',
  'youtube',
  'facebook',
  'instagram',
  'reddit',
  'bluesky',
  'telegram',
  'twitch',
  'npm',
  'medium',
  'devdotto',
  'dribbble',
  'stackoverflow',
  'rss'
];

const iconEntries = curatedSocialIcons.map((slug) => {
  const icon = iconsData.icons[slug];
  if (!icon) {
    throw new Error(`Icon "${slug}" not found in @iconify-json/simple-icons.`);
  }
  return [slug, icon];
});

fs.rmSync(iconsOutDir, { recursive: true, force: true });
fs.mkdirSync(iconsOutDir, { recursive: true });

for (const [slug, icon] of iconEntries) {
  const width = icon.width || defaultWidth;
  const height = icon.height || defaultHeight;
  const body = icon.body;
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}">${body}</svg>\n`;
  fs.writeFileSync(path.join(iconsOutDir, `${slug}.svg`), svg);
}

const cssLines = ['/* Generated from @iconify-json/simple-icons. Do not edit manually. */'];

for (const [slug] of iconEntries) {
  cssLines.push(`.vpi-social-${slug} { --icon: url("../images/social-icons/${slug}.svg"); }`);
}

// Compatibility aliases used in docs/themes.
cssLines.push('.vpi-social-blog { --icon: url("../images/social-icons/rss.svg"); }');

fs.writeFileSync(cssOutFile, `${cssLines.join('\n')}\n`);

console.log(`Generated ${iconEntries.length} social icon SVG files.`);
console.log(`Wrote ${cssOutFile}`);
