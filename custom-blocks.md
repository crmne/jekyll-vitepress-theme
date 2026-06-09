# Custom Blocks




Custom blocks are the VitePress-style containers behind the theme's callout UI. They render colored boxes for tips, warnings, danger notices, and other highlighted content. They are part of [VitePress Parity](/vitepress-parity/); Markdown-friendly callouts, labels, and project buttons are covered in [Extensions to VitePress](/extensions-to-vitepress/).








<div class="tip custom-block">
  <p class="custom-block-title">TIP</p>
  <p>For everyday Markdown authoring, use the Just the Docs-style syntax on <a href="/callouts-labels-buttons/">Callouts, Labels, and Buttons</a>. Use this page when you need the lower-level Liquid include, custom titles, or collapsible details.</p>

</div>



## Liquid Include Syntax

Use the built-in `alert.html` include when you need explicit control over the block type, title, or content:

```liquid
{% include alert.html type="tip" content="This is a helpful tip." %}
```

The `type` controls the color and default title. The `content` is processed as Markdown, so formatting like backticks, links, and multiple paragraphs work naturally.

## Available Types






<div class="info custom-block">
  <p class="custom-block-title">INFO</p>
  <p>This is an <code class="language-plaintext highlighter-rouge">info</code> block. Use it for neutral, supplementary information.</p>

</div>








<div class="note custom-block">
  <p class="custom-block-title">NOTE</p>
  <p>This is a <code class="language-plaintext highlighter-rouge">note</code> block. Visually identical to info; use whichever label fits better.</p>

</div>








<div class="tip custom-block">
  <p class="custom-block-title">TIP</p>
  <p>This is a helpful <code class="language-plaintext highlighter-rouge">tip</code> block.</p>

</div>








<div class="important custom-block">
  <p class="custom-block-title">IMPORTANT</p>
  <p>This is an <code class="language-plaintext highlighter-rouge">important</code> block. Do not skip this.</p>

</div>








<div class="warning custom-block">
  <p class="custom-block-title">WARNING</p>
  <p>This is a <code class="language-plaintext highlighter-rouge">warning</code> block. Something could go wrong.</p>

</div>








<div class="danger custom-block">
  <p class="custom-block-title">DANGER</p>
  <p>This is a <code class="language-plaintext highlighter-rouge">danger</code> block. Data loss or security risk.</p>

</div>








<div class="caution custom-block">
  <p class="custom-block-title">CAUTION</p>
  <p>This is a <code class="language-plaintext highlighter-rouge">caution</code> block. Visually identical to danger.</p>

</div>








<details class="details custom-block">
  <summary>Details</summary>
  <p>This is a collapsible <code class="language-plaintext highlighter-rouge">details</code> block.</p>

</details>



## Custom Titles

Each type has a default title (`TIP`, `WARNING`, etc.). Override it with the `title` parameter:

```liquid
{% include alert.html type="warning" title="Breaking Change" content="The `foo` option was removed in v2.0." %}
```






<div class="warning custom-block">
  <p class="custom-block-title">Breaking Change</p>
  <p>The <code class="language-plaintext highlighter-rouge">foo</code> option was removed in v2.0.</p>

</div>



## Markdown In Content

The `content` parameter supports Markdown: code, links, bold, even multiple paragraphs:

```liquid
{% include alert.html type="tip" content="Set `layout: home` in your frontmatter. See the [Frontmatter Reference](/frontmatter-reference/) for details." %}
```






<div class="tip custom-block">
  <p class="custom-block-title">TIP</p>
  <p>Set <code class="language-plaintext highlighter-rouge">layout: home</code> in your frontmatter. See the <a href="/frontmatter-reference/">Frontmatter Reference</a> for details.</p>

</div>



For multi-paragraph content, build the string with `capture` first:

```liquid
{% capture upgrade_note %}
Upgrade with `bundle update jekyll-vitepress-theme`.

Then rebuild your site to pick up the new assets.
{% endcapture %}
{% include alert.html type="note" content=upgrade_note %}
```







<div class="note custom-block">
  <p class="custom-block-title">NOTE</p>
  
<p>Upgrade with <code class="language-plaintext highlighter-rouge">bundle update jekyll-vitepress-theme</code>.</p>

<p>Then rebuild your site to pick up the new assets.</p>

</div>


