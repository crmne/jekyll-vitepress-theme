# frozen_string_literal: true

require_relative 'test_helper'

class MarkdownExportTest < Minitest::Test
  MarkdownExport = Jekyll::VitePressTheme::MarkdownExport

  def convert(markdown)
    MarkdownExport.convert(markdown)
  end

  def test_markdown_without_html_is_byte_identical
    markdown = <<~MARKDOWN
      # Guide

      Some *prose* with `inline <code>`, a [link](/x/), and a generic like Array<String>.

      - First item
        - Nested item

          ```ruby
          chat.ask "Hi"
          ```

      1. Ordered

      | A | B |
      | - | - |
      | 1 | 2 |

      > A quote
      >   with indentation
      >
      > ```erb
      > <%= render @chat %>
      > ```

          indented code



      Trailing paragraph with two spaces at the end.#{'  '}
    MARKDOWN

    assert_same_bytes markdown, convert(markdown)
    assert_same_bytes 'No newline at the end', convert('No newline at the end')
    assert_same_bytes '', convert(nil)
  end

  def test_fenced_code_is_untouched
    markdown = <<~MARKDOWN
      <div class="intro"><p>Render a view:</p></div>

      ```erb
      <div class="message">
        <%= message.content %>
      </div>
      {: .not-an-ial }



      ```

      ~~~html
      <section>&amp;</section>
      ~~~
    MARKDOWN

    expected = <<~MARKDOWN
      Render a view:

      ```erb
      <div class="message">
        <%= message.content %>
      </div>
      {: .not-an-ial }



      ```

      ~~~html
      <section>&amp;</section>
      ~~~
    MARKDOWN

    assert_equal expected, convert(markdown)
  end

  def test_code_spans_keep_html
    assert_equal "Use `<div>` here\n", convert("<p>Use `<div>` here</p>\n")
  end

  def test_links_keep_href_as_written
    html = '<p>Read <a href="/next/chat/#streaming" class="x">the <em>chat</em> guide</a>.</p>'

    assert_equal 'Read [the *chat* guide](/next/chat/#streaming).', convert(html)
  end

  def test_link_without_text_uses_its_accessible_name
    html = '<p><a href="https://github.com/crmne" aria-label="GitHub"><svg><path d="M0"/></svg></a></p>'

    assert_equal '[GitHub](https://github.com/crmne)', convert(html)
  end

  def test_headings_and_inline_formatting
    html = <<~HTML
      <h2 class="home-heading">Start with one line.<br>Add tools</h2>
      <p>Call <code>chat.ask</code> with <strong>one</strong> <b>line</b>,<br>
         then <i>more</i>.</p>
    HTML

    expected = "## Start with one line. Add tools\n\n" \
               "Call `chat.ask` with **one** **line**,  \nthen *more*.\n"

    assert_equal expected, convert(html)
  end

  def test_lists
    html = <<~HTML
      <ul>
        <li>First</li>
        <li>Second
          <ol start="3">
            <li>Nested <code>code</code></li>
            <li>More</li>
          </ol>
        </li>
      </ul>
    HTML

    expected = <<~MARKDOWN
      - First
      - Second

        3. Nested `code`
        4. More
    MARKDOWN

    assert_equal expected, convert(html)
  end

  def test_tables_become_gfm_tables
    html = <<~HTML
      <table>
        <caption>Coverage</caption>
        <thead><tr><th>Feature</th><th><button>OpenAI</button></th><th>Anthropic</th></tr></thead>
        <tbody>
          <tr><th colspan="3">Conversations</th></tr>
          <tr><th>Chat | streaming</th><td><a href="/a" aria-label="Built in"><span aria-hidden="true"></span></a></td><td>&ndash;</td></tr>
          <tr><td>Short row</td></tr>
        </tbody>
      </table>
    HTML

    expected = <<~MARKDOWN
      Coverage

      | Feature | OpenAI | Anthropic |
      | --- | --- | --- |
      | **Conversations** | | |
      | Chat \\| streaming | [Built in](/a) | – |
      | Short row | | |
    MARKDOWN

    assert_equal expected, convert(html)
  end

  def test_irregular_tables_become_text
    html = '<table><tr><td rowspan="2">Group</td><td>One</td></tr><tr><td>Two</td></tr></table>'

    assert_equal "Group\n\nOne\n\nTwo", convert(html)
  end

  def test_images_become_alt_text
    html = <<~HTML
      <p><img src="a.png" alt="Diagram of the loop"></p>
      <p><img src="b.png" alt="">Decorative</p>
      <div class="logo"><img class="light" src="l.svg" alt="Acme"><img class="dark" src="d.svg" alt="Acme"></div>
      <header><img src="p.jpg" alt="Ada Lovelace"><strong>Ada Lovelace</strong><small>Engineer</small></header>
    HTML

    expected = <<~MARKDOWN
      Diagram of the loop

      Decorative

      Acme

      **Ada Lovelace** Engineer
    MARKDOWN

    assert_equal expected, convert(html)
  end

  def test_presentational_elements_are_dropped_with_their_content
    html = <<~HTML
      <section>
        <script>document.write("<p>script</p>")</script>
        <style>p { color: red; }</style>
        <svg viewBox="0 0 1 1"><title>icon</title><path d="M0"/></svg>
        <video src="demo.mp4"><source src="demo.webm"></video>
        <button type="button">Play</button>
        <template><p>template</p></template>
        <noscript><p>noscript</p></noscript>
        <span aria-hidden="true">decoration</span>
        <dialog><p>dialog</p></dialog>
        <link rel="stylesheet" href="x.css">
        <label>Provider<select><option>All</option></select></label>
        <fieldset><legend>Browse by</legend><label><input type="radio">Provider</label></fieldset>
        <!-- a comment -->
        <p>Kept</p>
      </section>
    HTML

    assert_equal "Kept\n", convert(html)
  end

  def test_wrappers_disappear_and_whitespace_is_normalized
    html = <<~HTML
      Intro paragraph.

      <section class="home">
          <div class="inner">
                  <span class="badge">New</span>
                  Deeply indented text that must not become code.



          </div>
      </section>

      Outro paragraph.
    HTML

    expected = <<~MARKDOWN
      Intro paragraph.

      New Deeply indented text that must not become code.

      Outro paragraph.
    MARKDOWN

    assert_equal expected, convert(html)
  end

  def test_entities_are_decoded
    html = '<p>Tom &amp; Jerry&nbsp;&mdash; &#8220;quoted&#x201D; &bogus;</p>'

    assert_equal 'Tom & Jerry — “quoted” &bogus;', convert(html)
  end

  def test_ial_lines_are_removed
    markdown = <<~MARKDOWN
      Lead paragraph.
      {: .fs-6 .fw-300 }

      > Remember this.
      {: .note }
    MARKDOWN

    assert_equal "Lead paragraph.\n\n> Remember this.\n", convert(markdown)
  end

  def test_code_titles_from_ials_precede_their_fence
    markdown = <<~MARKDOWN
      Configure it:
      ```yaml
      title: Docs
      ```
      {: data-title="_config.yml"}

      ```ruby
      requires_approval
      ```
      {: .home-code-card data-title="Require human approval" data-href="/next/tool-execution/#requiring-approval" }

      - In a list:

        ```ruby
        chat.ask "Hi"
        ```
        {: data-title='app/models/chat.rb' }
    MARKDOWN

    expected = <<~MARKDOWN
      Configure it:

      **_config.yml**

      ```yaml
      title: Docs
      ```

      **[Require human approval](/next/tool-execution/#requiring-approval)**

      ```ruby
      requires_approval
      ```

      - In a list:

        **app/models/chat.rb**

        ```ruby
        chat.ask "Hi"
        ```
    MARKDOWN

    assert_equal expected, convert(markdown)
  end

  def test_highlighted_html_code_becomes_a_fenced_block
    html = <<~HTML
      <div class="language-ruby highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="n">chat</span><span class="p">.</span><span class="nf">ask</span> <span class="s2">"&lt;hi&gt;"</span>
      </code></pre></div></div>
    HTML

    assert_equal "```ruby\nchat.ask \"<hi>\"\n```\n", convert(html)
  end

  def test_html_lists_indent_their_code_blocks
    html = '<ul><li><p>Install:</p><pre><code class="language-sh">gem install x

      bundle</code></pre></li></ul>'

    assert_equal "- Install:\n\n  ```sh\n  gem install x\n\n        bundle\n  ```", convert(html)
  end

  def test_homepage_shaped_markdown
    markdown = <<~MARKDOWN
      <section id="demo" class="home-section">
        <div class="home-section-inner">
          <h2 class="home-heading">19 providers. One Ruby API.</h2>
          <p class="home-lead">
            Build with the models you want.
          </p>
          <div class="home-step">
            <div class="home-step-text">
              <h3 class="home-step-title">Just ask</h3>
              <p class="home-step-desc">Ask a question with <code>chat.ask</code>.</p>
              <a class="home-step-link" href="/next/chat/">Chat guide</a>
            </div>
            <div class="home-step-code home-code-grid" markdown="1">

      ```ruby
      chat = RubyLLM.chat
      chat.ask "What's the best way to learn Ruby?"

      # Build small things
      ```
      {: .home-code-card data-title="Ask" }

      ```ruby
      chat.ask "Next?"
      ```
      {: #second .home-code-card }

      </div>
          </div>
          <div class="provider-icons">
            <a href="https://anthropic.com"><img src="a.svg" alt="Anthropic"></a>
            <a href="https://ollama.com"><img src="o.svg" alt=""><span class="logo-wordmark">Ollama</span></a>
          </div>
        </div>
      </section>
    MARKDOWN

    expected = <<~MARKDOWN
      ## 19 providers. One Ruby API.

      Build with the models you want.

      ### Just ask

      Ask a question with `chat.ask`.

      [Chat guide](/next/chat/)

      **Ask**

      ```ruby
      chat = RubyLLM.chat
      chat.ask "What's the best way to learn Ruby?"

      # Build small things
      ```

      ```ruby
      chat.ask "Next?"
      ```

      [Anthropic](https://anthropic.com) [Ollama](https://ollama.com)
    MARKDOWN

    assert_equal expected, convert(markdown)
  end

  def test_theme_callouts_become_blockquotes
    html = <<~HTML
      <div class="tip custom-block">
        <p class="custom-block-title">TIP</p>
        <p>Read <a href="/guide/">the guide</a>.</p>

      </div>
    HTML

    assert_equal "> **TIP**\n>\n> Read [the guide](/guide/).\n", convert(html)
  end

  def test_indented_include_output_starts_a_paragraph
    markdown = "Intro.\n\n      <a class=\"button\" href=\"/star/\">\n        <span>Star</span>\n      </a>\n\n" \
               "- Item\n\n  <a href=\"/more/\">More</a> inside the item\n"

    assert_equal "Intro.\n\n[Star](/star/)\n\n- Item\n\n  [More](/more/) inside the item\n", convert(markdown)
  end

  def test_markdown_inside_markdown_divs_is_dedented
    markdown = <<~MARKDOWN
      <div markdown="1">
          Indented **Markdown** paragraph.

          - item
            - nested
      </div>
    MARKDOWN

    assert_equal "Indented **Markdown** paragraph.\n\n- item\n  - nested\n", convert(markdown)
  end

  def test_unclosed_fence_runs_to_the_end
    markdown = "<p>Before</p>\n\n```ruby\n<div>never closed\n"

    assert_equal "Before\n\n```ruby\n<div>never closed\n", convert(markdown)
  end

  private

  def assert_same_bytes(expected, actual)
    assert_equal expected.b, actual.b
  end
end
