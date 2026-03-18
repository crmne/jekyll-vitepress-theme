---
title: Code Blocks
nav_order: 2
description: Copy buttons, language labels, syntax palettes, and file-title icons.
---

Code blocks support VitePress-style enhancements:

- copy button
- language label
- optional title bar via `data-title`
- file-type icon in title bar inferred from file extension/language

Syntax colors come from Rouge themes configured in `_config.yml`:

```yaml
jekyll_vitepress:
  syntax:
    light_theme: github
    dark_theme: github.dark
```
{: data-title="_config.yml"}

## Titled block example

```ruby
class WeatherTool
  def call(city:)
    "sunny in #{city}"
  end
end
```
{: data-title="app/tools/weather_tool.rb"}

```ts
export function formatDate(input: string): string {
  return new Date(input).toISOString()
}
```
{: data-title="src/utils/date.ts"}

`light_theme` and `dark_theme` accept any installed Rouge theme name.
