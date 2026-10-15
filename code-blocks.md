# Code Blocks

Code blocks get several VitePress-style enhancements automatically. They are part of [VitePress Parity](/vitepress-parity/), while optional features beyond baseline VitePress are documented in [Extensions to VitePress](/extensions-to-vitepress/). No configuration is needed beyond choosing your syntax themes.

## What you get for free

Every fenced code block renders with:

- A **copy button** in the top-right corner
- A **language label** showing the block's language (e.g., `ruby`, `yaml`, `sh`)

These work with any standard Markdown fenced code block:

````markdown
```ruby
puts "Hello, world!"
```
````

## Syntax highlighting

Syntax colors come from [Rouge](https://github.com/rouge-ruby/rouge) themes, configured in `_config.yml`:

**_config.yml**

```yaml
jekyll_vitepress:
  syntax:
    light_theme: github
    dark_theme: github.dark
```

The theme generates scoped CSS for both modes at build time. When the user toggles between light and dark mode, code blocks switch palettes automatically. Any installed Rouge theme name works here. If you specify an invalid name, the plugin falls back to `github` / `github.dark` and logs a warning.

## Title bars

You can add a file-title bar to any code block using Kramdown's [Inline Attribute List](https://kramdown.gettalong.de/syntax.html#inline-attribute-lists) syntax. Place `{: data-title="filename"}` on the line immediately after the closing fence:

````markdown
```ruby
class WeatherTool
  def call(city:)
    "sunny in #{city}"
  end
end
```
{: data-title="app/tools/weather_tool.rb"}
````

This renders a title bar above the code block showing the filename, complete with a file-type icon inferred from the extension. The theme includes built-in icons for common file types.

## Titled block examples

**app/tools/weather_tool.rb**

```ruby
class WeatherTool
  def call(city:)
    "sunny in #{city}"
  end
end
```

**src/utils/date.ts**

```ts
export function formatDate(input: string): string {
  return new Date(input).toISOString()
}
```

**_config.yml**

```yaml
jekyll_vitepress:
  branding:
    site_title: My Docs
```

> **TIP**
>
> The `{: data-title="..."}` syntax is a Kramdown feature called an Inline Attribute List (IAL). It must appear on its own line directly after the code fence, with no blank line in between.
