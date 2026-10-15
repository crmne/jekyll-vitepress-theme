# frozen_string_literal: true

require 'kramdown'
require 'set'
require 'strscan'

module Jekyll
  module VitePressTheme
    # Converts the HTML that a page's Markdown source carries, written inline or
    # produced by includes and filters, into Markdown. The "Copy page" button,
    # the exported .md files, and llms-full.txt all share it. Fenced code
    # blocks and code spans pass through untouched, and a page without HTML
    # comes back unchanged.
    # rubocop:disable Metrics/AbcSize, Metrics/ModuleLength
    module MarkdownExport
      module_function

      Element = Struct.new(:name, :attrs, :children, :parent)
      Text = Struct.new(:text)

      BLOCK_CODE = "\u0000B%d\u0000"
      SPAN_CODE = "\u0000S%d\u0000"
      BLOCK_CODE_PATTERN = /\u0000B\d+\u0000/
      PLACEHOLDER_PATTERN = /\u0000([BS])(\d+)\u0000/
      LINE_BREAK = "\u0001"

      KNOWN_ELEMENTS = %w[
        a abbr address article aside audio b bdi bdo blockquote body br button canvas caption cite code col colgroup
        data dd del details dfn dialog div dl dt em embed fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6
        head header hgroup hr html i iframe img input ins kbd label legend li link main map mark menu meta meter nav
        noscript object ol optgroup option output p picture pre progress q s samp script search section select small
        source span strike strong style sub summary sup svg table tbody td template textarea tfoot th thead time tr
        track tt u ul var video wbr
      ].to_set.freeze

      VOID_ELEMENTS = %w[area base br col embed hr img input link meta source track wbr].to_set.freeze
      RAW_TEXT_ELEMENTS = %w[script style textarea].to_set.freeze
      DROPPED_ELEMENTS = %w[
        audio button canvas embed fieldset head iframe input link map meta noscript object script select style svg
        template textarea video
      ].to_set.freeze
      FORM_CONTROLS = %w[input select textarea].to_set.freeze

      BLOCK_ELEMENTS = %w[
        address article aside blockquote body caption dd details dialog div dl dt fieldset figcaption figure footer
        form h1 h2 h3 h4 h5 h6 header hgroup hr html legend li main menu nav ol p pre search section summary table
        tbody td tfoot th thead tr ul
      ].to_set.freeze

      IMPLIED_CLOSES = {
        'li' => %w[li],
        'dt' => %w[dt dd],
        'dd' => %w[dt dd],
        'tr' => %w[tr td th],
        'td' => %w[td th],
        'th' => %w[td th],
        'option' => %w[option]
      }.freeze

      EMPHASIS = {
        'em' => '*', 'i' => '*', 'cite' => '*', 'dfn' => '*', 'var' => '*',
        'strong' => '**', 'b' => '**',
        'del' => '~~', 's' => '~~', 'strike' => '~~'
      }.freeze

      CODE_ELEMENTS = %w[code kbd samp tt].to_set.freeze

      TAG_PATTERN = %r{
        <!--.*?-->
        |
        <(/)?([a-zA-Z][a-zA-Z0-9-]*)
        ((?:\s+[^\s"'>/=]+(?:\s*=\s*(?:"[^"]*"|'[^']*'|[^\s"'=<>`]+))?)*)
        \s*(/)?>
      }mx

      ATTRIBUTE_PATTERN = %r{([^\s"'>/=]+)(?:\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+)))?}
      ENTITY_PATTERN = /&(?:#(\d+)|#[xX](\h+)|([a-zA-Z][a-zA-Z0-9]*));/
      IAL_LINE_PATTERN = /^[ \t]*\{:[^\n]*\}[ \t]*(?:\n|\z)/
      FENCE_OPEN_PATTERN = /\A((?:[ \t]*>)*[ \t]*)(`{3,}|~{3,})(.*)\z/
      LIST_ITEM_PATTERN = /\A(?:[-*+]|\d+[.)])[ \t]/
      CODE_SPAN_PATTERN = /(?<!`)(`+)(?!`)((?:(?!\n[ \t]*\n).)+?)(?<!`)\1(?!`)/m

      def convert(markdown)
        source = markdown.to_s
        codes = []
        text = protect_code(source, codes)
        return source unless html?(text) || text.match?(IAL_LINE_PATTERN)

        output = render_markdown(parse(text).children, dedent: false, codes: codes)
        restore_code(finish(output, source), codes)
      end

      def html?(text)
        text.scan(TAG_PATTERN).any? { |_, name| name.nil? || known?(name) }
      end

      def known?(name)
        name = name.downcase
        KNOWN_ELEMENTS.include?(name) || name.include?('-')
      end

      def protect_code(source, codes)
        output = +''
        prose = +''
        lines = source.lines
        index = 0
        while index < lines.length
          line = lines[index]
          match = line.chomp.match(FENCE_OPEN_PATTERN)
          if match && !(match[2].start_with?('`') && match[3].include?('`'))
            closing = closing_fence_index(lines, index, match[2])
            output << protect_spans(prose, codes)
            prose = +''
            block = lines[index..closing].join
            newline = block.end_with?("\n") ? "\n" : ''
            output << code_title(lines[closing + 1], match[1], output)
            output << register(codes, block.chomp, BLOCK_CODE) << newline
            index = closing + 1
          else
            prose << line
            index += 1
          end
        end
        output << protect_spans(prose, codes)
      end

      def closing_fence_index(lines, start, fence)
        closing = /\A(?:[ \t]*>)*[ \t]*#{Regexp.escape(fence[0])}{#{fence.length},}[ \t]*\z/
        ((start + 1)...lines.length).find { |i| lines[i].chomp.match?(closing) } || (lines.length - 1)
      end

      # The IAL after a fence gives the code block its title bar, so the title
      # moves to a line of its own before the fence when the IAL goes.
      def code_title(line, prefix, output)
        return '' unless line&.match?(IAL_LINE_PATTERN)

        title = ial_value(line, 'data-title')
        return '' if title.empty?

        href = ial_value(line, 'data-href')
        title = "[#{title}](#{href})" unless href.empty?
        separator = output.empty? || output.end_with?("\n\n") ? '' : "#{prefix.rstrip}\n"
        "#{separator}#{prefix}**#{title}**\n#{prefix.rstrip}\n"
      end

      def ial_value(line, name)
        match = line.match(/(?:\A|[\s{:])#{Regexp.escape(name)}=(?:"([^"]*)"|'([^']*)')/)
        match ? decode(match[1] || match[2]).strip : ''
      end

      def protect_spans(text, codes)
        text.gsub(CODE_SPAN_PATTERN) { |span| register(codes, span, SPAN_CODE) }
      end

      def register(codes, code, format)
        codes << code
        format(format, codes.length - 1)
      end

      def restore_code(text, codes)
        8.times do
          break unless text.include?("\u0000")

          text = text.gsub(/^([ \t>]*)#{BLOCK_CODE_PATTERN.source}/) do |match|
            prefix = Regexp.last_match(1)
            code = codes[match[/\d+/].to_i]
            prefix + code.gsub(/\n(?=(.?))/) { Regexp.last_match(1).empty? ? "\n" : "\n#{prefix}" }
          end
          text = text.gsub(PLACEHOLDER_PATTERN) { codes[Regexp.last_match(2).to_i] }
        end
        text
      end

      def finish(output, source)
        text = output.gsub(/^[ \t]+$/, '')
                     .gsub(/\n{3,}/, "\n\n")
                     .sub(/\A\n+/, '')
                     .sub(/\s+\z/, '')
                     .gsub(LINE_BREAK, "  \n")
        source.end_with?("\n") && !text.empty? ? "#{text}\n" : text
      end

      # Parsing

      def parse(text)
        root = Element.new('#root', {}, [], nil)
        stack = [root]
        scanner = StringScanner.new(text)
        while (consumed = scanner.scan_until(TAG_PATTERN))
          tag = scanner.matched
          closing, name, attributes, self_closing = scanner.captures
          append_text(stack.last, consumed[0...-tag.length])
          name = name&.downcase
          next if name.nil?

          if !known?(name)
            append_text(stack.last, tag)
          elsif closing
            close_element(stack, name)
          else
            element = open_element(stack, name, parse_attributes(attributes))
            if RAW_TEXT_ELEMENTS.include?(name)
              append_text(element, raw_text(scanner, name))
              stack.pop
            elsif VOID_ELEMENTS.include?(name) || self_closing
              stack.pop
            end
          end
        end
        append_text(stack.last, scanner.rest)
        root
      end

      def raw_text(scanner, name)
        consumed = scanner.scan_until(%r{</#{name}\s*>}i)
        return consumed[0...-scanner.matched.length] if consumed

        scanner.rest.tap { scanner.terminate }
      end

      def open_element(stack, name, attrs)
        closes = IMPLIED_CLOSES.fetch(name, [])
        stack.pop while stack.length > 1 && closes.include?(stack.last.name)
        stack.pop if stack.length > 1 && stack.last.name == 'p' && BLOCK_ELEMENTS.include?(name)

        element = Element.new(name, attrs, [], stack.last)
        stack.last.children << element
        stack << element
        element
      end

      def close_element(stack, name)
        index = stack.rindex { |element| element.name == name }
        stack.slice!(index..) if index&.positive?
      end

      def append_text(parent, text)
        parent.children << Text.new(text) unless text.nil? || text.empty?
      end

      def parse_attributes(source)
        source.to_s.scan(ATTRIBUTE_PATTERN).to_h do |name, double, single, bare|
          [name.downcase, decode(double || single || bare || '')]
        end
      end

      # Rendering

      def render_markdown(nodes, dedent:, codes:)
        output = nodes.each_with_object(+'') do |node, out|
          if node.is_a?(Text)
            out << node.text.gsub(IAL_LINE_PATTERN, '')
          elsif dropped?(node)
            next
          elsif block?(node)
            out << "\n\n" << render_block(node, codes) << "\n\n"
          else
            unindent_paragraph_start(out)
            out << render_inline(node, codes, breaks: true)
          end
        end
        dedent ? dedent(output) : output
      end

      # Includes often indent the HTML they write, and Markdown would read a
      # paragraph indented four spaces as code. Indentation that continues a
      # list item stays.
      def unindent_paragraph_start(out)
        return unless out.match?(/(?:\A|\n[ \t]*\n)[ \t]+\z/)

        previous = out.rstrip.lines.last.to_s
        return if previous.match?(/\A[ \t]/) || previous.match?(LIST_ITEM_PATTERN)

        out.sub!(/[ \t]+\z/, '')
      end

      def dedent(text)
        lines = text.split("\n", -1)
        indents = lines.drop(1).reject { |line| line.strip.empty? || line.match?(/\A[ \t]*#{BLOCK_CODE_PATTERN.source}/) }
                               .map { |line| line[/\A[ \t]*/].length }
        indent = indents.min.to_i
        return text if indent.zero?

        lines.each_with_index.map { |line, i| i.zero? ? line : line.sub(/\A[ \t]{0,#{indent}}/, '') }.join("\n")
      end

      def render_flow(nodes, codes)
        blocks = []
        run = +''
        previous = nil
        flush = lambda do
          inline = normalize_inline(run)
          blocks << inline unless inline.empty?
          run = +''
        end

        nodes.each do |node|
          if node.is_a?(Text)
            node.text.split(/(#{BLOCK_CODE_PATTERN.source})/).each do |piece|
              if piece.match?(BLOCK_CODE_PATTERN)
                flush.call
                blocks << piece
              else
                run << inline_text_node(piece)
              end
            end
          elsif dropped?(node)
            next
          elsif block?(node)
            flush.call
            block = render_block(node, codes)
            blocks << block unless block.strip.empty?
          else
            append_inline(run, render_inline(node, codes, breaks: true), previous, node)
          end
          previous = node
        end
        flush.call
        blocks.join("\n\n")
      end

      def render_block(element, codes)
        return strong_block(element, codes) if class?(element, 'custom-block-title')

        case element.name
        when /\Ah([1-6])\z/
          text = inline_text(element.children, codes, breaks: false)
          text.empty? ? '' : "#{'#' * Regexp.last_match(1).to_i} #{text}"
        when 'summary', 'dt', 'legend' then strong_block(element, codes)
        when 'pre' then render_pre(element, codes)
        when 'ul', 'ol', 'menu' then render_list(element, codes)
        when 'li' then list_item(render_flow(element.children, codes), '- ')
        when 'blockquote' then quote(render_flow(element.children, codes))
        when 'table' then render_table(element, codes)
        when 'hr' then '---'
        when 'a' then render_block_link(element, codes)
        else
          body = if markdown_attribute?(element)
                   render_markdown(element.children, dedent: true, codes: codes)
                 else
                   render_flow(element.children, codes)
                 end
          class?(element, 'custom-block') ? quote(body) : body
        end
      end

      def strong_block(element, codes)
        text = inline_text(element.children, codes, breaks: false)
        text.empty? ? '' : "**#{text}**"
      end

      def render_inline(node, codes, breaks:)
        return inline_text_node(node.text) if node.is_a?(Text)
        return '' if dropped?(node)

        name = node.name
        return " #{inline_text(node.children, codes, breaks: breaks)} " if BLOCK_ELEMENTS.include?(name)

        if name == 'a'
          render_link(node, codes, breaks: breaks)
        elsif CODE_ELEMENTS.include?(name)
          code_span(text_content(node).gsub(/\s+/, ' ').strip)
        elsif EMPHASIS.key?(name)
          emphasize(render_children_inline(node, codes, breaks: breaks), EMPHASIS[name])
        elsif name == 'br'
          breaks ? LINE_BREAK : ' '
        elsif name == 'img'
          duplicate_image?(node) ? '' : node.attrs['alt'].to_s.strip
        else
          render_children_inline(node, codes, breaks: breaks)
        end
      end

      def render_children_inline(element, codes, breaks:)
        render_inline_nodes(element.children, codes, breaks: breaks)
      end

      def inline_text(nodes, codes, breaks:)
        normalize_inline(render_inline_nodes(nodes, codes, breaks: breaks))
      end

      def render_inline_nodes(nodes, codes, breaks:)
        previous = nil
        nodes.each_with_object(+'') do |node, buffer|
          append_inline(buffer, render_inline(node, codes, breaks: breaks), previous, node)
          previous = node
        end
      end

      # Sibling elements with no whitespace between them are laid out apart by
      # CSS, such as a name and a job title in a flex row, so keep them apart.
      def append_inline(buffer, text, previous, node)
        separate = previous.is_a?(Element) && node.is_a?(Element) &&
                   buffer.match?(/[^\s#{LINE_BREAK}]\z/o) && text.match?(/\A[^\s#{LINE_BREAK}]/o)
        buffer << ' ' if separate
        buffer << text
      end

      def inline_text_node(text)
        decode(text.gsub(/[ \t\r\n]+/, ' ')).tr("\u00A0", ' ')
      end

      def normalize_inline(text)
        text.gsub(/[ \t\r\n]+/, ' ')
            .gsub(/ ?#{LINE_BREAK} ?/o, LINE_BREAK)
            .gsub(/\A[ #{LINE_BREAK}]+|[ #{LINE_BREAK}]+\z/o, '')
      end

      def render_link(element, codes, breaks:)
        label = inline_text(element.children, codes, breaks: breaks)
        label = accessible_name(element) if label.empty?
        href = element.attrs['href'].to_s.strip
        return label if href.empty? || label.empty?

        "[#{label}](#{href})"
      end

      def render_block_link(element, codes)
        body = render_flow(element.children, codes)
        href = element.attrs['href'].to_s.strip
        return body if href.empty?

        label = accessible_name(element)
        label = body.lines.first.to_s.sub(/\A[#*\s]+/, '').sub(/[*\s]+\z/, '') if label.empty?
        [body, "[#{label}](#{href})"].reject(&:empty?).join("\n\n")
      end

      # An image repeats its neighbour when it is the dark-mode twin of the
      # previous image or an avatar next to the name it shows.
      def duplicate_image?(image)
        alt = normalize_inline(image.attrs['alt'].to_s)
        return false if alt.empty?

        siblings = image.parent.children.reject { |child| child.is_a?(Text) && child.text.strip.empty? }
        index = siblings.index { |child| child.equal?(image) }
        previous = index.positive? ? siblings[index - 1] : nil
        following = siblings[index + 1]

        (previous.is_a?(Element) && previous.name == 'img' && normalize_inline(previous.attrs['alt'].to_s) == alt) ||
          (following.is_a?(Element) && following.name != 'img' && normalize_inline(text_content(following)) == alt)
      end

      def accessible_name(element)
        normalize_inline(element.attrs['aria-label'] || element.attrs['title'] || '')
      end

      def emphasize(text, marker)
        core = text.strip
        return text if core.empty?

        leading = text.match?(/\A\s/) ? ' ' : ''
        trailing = text.match?(/\s\z/) ? ' ' : ''
        "#{leading}#{marker}#{core}#{marker}#{trailing}"
      end

      def code_span(text)
        return '' if text.empty?

        fence = '`' * (longest_run(text, '`') + 1)
        padding = text.start_with?('`') || text.end_with?('`') ? ' ' : ''
        "#{fence}#{padding}#{text}#{padding}#{fence}"
      end

      def render_pre(element, codes)
        code = text_content(element).sub(/\A\n/, '').sub(/\s+\z/, '')
        return '' if code.empty?

        fence = '`' * [3, longest_run(code, '`') + 1].max
        register(codes, "#{fence}#{language(element)}\n#{code}\n#{fence}", BLOCK_CODE)
      end

      def language(element)
        candidates = element.children.grep(Element).select { |child| child.name == 'code' }
        node = element
        while node
          candidates << node
          node = node.parent
        end
        candidates.each do |candidate|
          match = candidate.attrs['class'].to_s.match(/(?:\A|\s)(?:language|lang)-(\S+)/)
          return match[1] if match
        end
        ''
      end

      def render_list(element, codes)
        number = (element.attrs['start'] || 1).to_i
        items = element.children.grep(Element).select { |child| child.name == 'li' && !dropped?(child) }
        items.filter_map do |item|
          body = render_flow(item.children, codes)
          next if body.empty?

          marker = element.name == 'ol' ? "#{number}. " : '- '
          number += 1
          list_item(body, marker)
        end.join("\n")
      end

      def list_item(body, marker)
        indent = ' ' * marker.length
        body.lines.each_with_index.map do |line, index|
          if index.zero? then "#{marker}#{line}"
          elsif line.strip.empty? then line
          else
            "#{indent}#{line}"
          end
        end.join
      end

      def quote(body)
        body = body.gsub(/^[ \t]+$/, '').gsub(/\n{3,}/, "\n\n").sub(/\A\n+/, '').sub(/\s+\z/, '')
        body.lines.map do |line|
          line.strip.empty? ? ">\n" : "> #{line}"
        end.join.chomp
      end

      def render_table(element, codes)
        rows = table_rows(element)
        return render_flow(element.children, codes) unless tabular?(rows)

        caption = element.children.grep(Element).find { |child| child.name == 'caption' && !dropped?(child) }
        width = rows.map { |cells| cells.sum { |cell| colspan(cell) } }.max
        lines = rows.map { |cells| table_row(cells, width, codes) }
        lines.insert(1, "|#{' --- |' * width}")
        table = lines.join("\n")
        caption_text = caption ? inline_text(caption.children, codes, breaks: false) : ''
        caption_text.empty? ? table : "#{caption_text}\n\n#{table}"
      end

      def table_rows(table)
        rows = []
        table.children.grep(Element).each do |child|
          next if dropped?(child)

          case child.name
          when 'tr' then rows << child
          when 'thead', 'tbody', 'tfoot'
            rows.concat(child.children.grep(Element).select { |row| row.name == 'tr' && !dropped?(row) })
          end
        end
        rows.map { |row| row.children.grep(Element).select { |cell| %w[td th].include?(cell.name) } }
            .reject(&:empty?)
      end

      def tabular?(rows)
        return false if rows.empty?

        rows.flatten.none? do |cell|
          cell.attrs['rowspan'].to_i > 1 || descendant?(cell) { |node| %w[table pre ul ol dl blockquote].include?(node.name) }
        end
      end

      def table_row(cells, width, codes)
        texts = cells.flat_map do |cell|
          text = cell_text(cell, codes).gsub('|', '\\|')
          text = "**#{text}**" if cells.length == 1 && colspan(cell) > 1 && !text.empty?
          [text] + Array.new(colspan(cell) - 1, '')
        end
        texts.fill('', texts.length...width)
        "|#{texts.map { |text| text.empty? ? ' ' : " #{text} " }.join('|')}|"
      end

      # Sortable tables label their columns with buttons, which are otherwise
      # dropped, so a header cell falls back to its full text.
      def cell_text(cell, codes)
        text = inline_text(cell.children, codes, breaks: false)
        return text unless text.empty? && cell.name == 'th'

        normalize_inline(text_content(cell))
      end

      def colspan(cell)
        [cell.attrs['colspan'].to_i, 1].max
      end

      # Queries

      def dropped?(element)
        DROPPED_ELEMENTS.include?(element.name) ||
          element.attrs['aria-hidden'] == 'true' ||
          (element.name == 'label' && control_label?(element)) ||
          (element.name == 'dialog' && !element.attrs.key?('open'))
      end

      def control_label?(label)
        label.children.any? do |child|
          child.is_a?(Element) && (FORM_CONTROLS.include?(child.name) || control_label?(child))
        end
      end

      def block?(element)
        BLOCK_ELEMENTS.include?(element.name) || descendant?(element) { |node| BLOCK_ELEMENTS.include?(node.name) }
      end

      def descendant?(element, &block)
        element.children.any? do |child|
          child.is_a?(Element) && !dropped?(child) && (yield(child) || descendant?(child, &block))
        end
      end

      def class?(element, name)
        element.attrs['class'].to_s.split.include?(name)
      end

      def markdown_attribute?(element)
        %w[1 block span].include?(element.attrs['markdown'])
      end

      def text_content(element)
        element.children.map do |child|
          child.is_a?(Text) ? decode(child.text) : text_content(child)
        end.join
      end

      def longest_run(text, character)
        text.scan(/#{Regexp.escape(character)}+/).map(&:length).max.to_i
      end

      def decode(text)
        text.gsub(ENTITY_PATTERN) do |entity|
          code_point = entity_code_point(Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3))
          code_point ? [code_point].pack('U') : entity
        end
      end

      def entity_code_point(decimal, hex, name)
        return decimal.to_i if decimal
        return hex.to_i(16) if hex

        Kramdown::Utils::Entities.entity(name).code_point
      rescue Kramdown::Error, RangeError
        nil
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/ModuleLength
  end
end
