require 'pathname'
require 'rouge'

module Jekyll
  module VitePressTheme
    # rubocop:disable Metrics/ModuleLength
    module Sidebar
      module_function

      DATA_KEY = 'jekyll_vitepress_sidebar'.freeze
      MAX_ITEM_LEVEL = 5

      def apply(site)
        generated_sidebar = generate(site)
        site.data[DATA_KEY] = generated_sidebar if generated_sidebar
      rescue StandardError => e
        Jekyll.logger.warn('jekyll-vitepress-theme', "Sidebar hierarchy generation failed: #{e.message}")
      end

      def generate(site)
        sidebar_groups = site.data['sidebar']
        return nil unless sidebar_groups.respond_to?(:each)

        groups = sidebar_groups.filter_map { |group| generated_group(site, group) }

        {
          'groups' => groups,
          'collections' => groups.to_h { |group| [group['collection'], collection_data(group)] }
        }
      end

      def generated_group(site, group)
        collection_name = group_value(group, 'collection')
        docs = collection_docs(site, collection_name)
        return nil if docs.empty?

        collection_data = build_collection(collection_name, docs)
        return nil if collection_data['docs'].empty?

        group_hash(group).merge(collection_data)
      end

      def collection_data(group)
        group.slice('collection', 'items', 'docs', 'active_urls')
      end

      def build_collection(collection_name, docs)
        ordered_docs = sort_docs(docs)
        nodes = ordered_docs.to_h { |doc| [doc, node_for(doc)] }
        roots = attach_nodes(collection_name, ordered_docs, nodes)

        finalize_nodes(roots, 1)
        flat_docs = flatten_docs(roots)
        {
          'collection' => collection_name.to_s,
          'items' => roots,
          'docs' => flat_docs,
          'active_urls' => flat_docs.filter_map { |doc| doc_url(doc) }
        }
      end

      def attach_nodes(collection_name, docs, nodes)
        docs.each_with_object([]) do |doc, roots|
          parent_doc = parent_doc_for(doc, docs)
          if valid_parent?(doc, parent_doc, docs)
            nodes[parent_doc]['children'] << nodes[doc]
          else
            warn_missing_parent(collection_name, doc) if parent_title(doc)
            roots << nodes[doc]
          end
        end
      end

      def valid_parent?(doc, parent_doc, docs)
        parent_doc && !attaching_creates_cycle?(doc, parent_doc, docs)
      end

      def collection_docs(site, collection_name)
        return [] unless collection_name

        collection = site.collections[collection_name.to_s]
        return [] unless collection

        collection.docs
      end

      def group_hash(group)
        return group if group.is_a?(Hash)

        group.respond_to?(:to_h) ? group.to_h : {}
      end

      def group_value(group, key)
        group_hash(group)[key] || group_hash(group)[key.to_sym]
      end

      def sort_docs(docs)
        docs.sort_by { |doc| sort_key(doc) }
      end

      def sort_key(doc)
        nav_order = data_value(doc, 'nav_order')
        order_bucket = nav_order.nil? ? 1 : 0
        numeric_order = numeric?(nav_order)
        order_type = numeric_order ? 0 : 1
        order_value = numeric_order ? nav_order.to_f : nav_order.to_s

        [order_bucket, order_type, order_value, title(doc).downcase, doc_url(doc).to_s]
      end

      def numeric?(value)
        value.is_a?(Numeric) || value.to_s.match?(/\A-?\d+(?:\.\d+)?\z/)
      end

      def node_for(doc)
        {
          'doc' => doc,
          'title' => title(doc),
          'url' => doc_url(doc),
          'collapsed' => truthy?(data_value(doc, 'collapsed')),
          'children' => [],
          'active_urls' => []
        }
      end

      def parent_doc_for(doc, docs)
        direct_parent = parent_title(doc)
        return nil unless direct_parent

        candidates = docs.select { |candidate| candidate != doc && title(candidate) == direct_parent }
        grand_parent = normalized_string(data_value(doc, 'grand_parent'))
        return candidates.first unless grand_parent

        candidates.find { |candidate| ancestor_titles(candidate, docs).include?(grand_parent) }
      end

      def attaching_creates_cycle?(doc, parent_doc, docs)
        current = parent_doc
        seen = []

        while current
          return true if current == doc || seen.include?(current)

          seen << current
          current = parent_doc_for(current, docs)
        end

        false
      end

      def ancestor_titles(doc, docs)
        titles = []
        current = parent_doc_for(doc, docs)
        seen = []

        while current && !seen.include?(current)
          seen << current
          titles << title(current)
          current = parent_doc_for(current, docs)
        end

        titles
      end

      def finalize_nodes(nodes, level)
        nodes.sort_by! { |node| sort_key(node['doc']) }
        nodes.each do |node|
          finalize_children(node, level)

          node['active_urls'] = [node['url'], *node['children'].flat_map { |child| child['active_urls'] }].compact
        end
      end

      def finalize_children(node, level)
        if level >= MAX_ITEM_LEVEL
          warn_depth_limit(node) unless node['children'].empty?
          node['children'] = []
        else
          finalize_nodes(node['children'], level + 1)
        end
      end

      def flatten_docs(nodes)
        nodes.flat_map do |node|
          [node['doc'], *flatten_docs(node['children'])]
        end
      end

      def data_value(doc, key)
        data = doc.respond_to?(:data) ? doc.data : {}
        data[key] || data[key.to_sym]
      end

      def title(doc)
        normalized_string(data_value(doc, 'title')) || ''
      end

      def parent_title(doc)
        normalized_string(data_value(doc, 'parent'))
      end

      def doc_url(doc)
        doc.url if doc.respond_to?(:url)
      end

      def normalized_string(value)
        string = value.to_s.strip
        string.empty? ? nil : string
      end

      def truthy?(value)
        value == true || value.to_s.casecmp('true').zero?
      end

      def warn_missing_parent(collection_name, doc)
        Jekyll.logger.warn(
          'jekyll-vitepress-theme',
          "Missing sidebar parent '#{parent_title(doc)}' for '#{title(doc)}' in #{collection_name}; rendering it at the collection root."
        )
      end

      def warn_depth_limit(node)
        Jekyll.logger.warn(
          'jekyll-vitepress-theme',
          "Sidebar item '#{node['title']}' is deeper than #{MAX_ITEM_LEVEL} item levels; nested children were not rendered."
        )
      end
    end
    # rubocop:enable Metrics/ModuleLength

    module SearchIndex
      module_function

      TEMPLATE = <<~LIQUID.freeze
        [
        {% assign first = true %}
        {% assign home_page = site.pages | where: 'url', '/' | first %}
        {% if home_page %}
          {% assign home_excerpt = home_page.content | markdownify | strip_html | strip_newlines | replace: '  ', ' ' | strip | truncate: 2400, '' %}
          {
            "title": {{ home_page.title | default: site.title | strip_html | strip | jsonify }},
            "url": {{ home_page.url | relative_url | jsonify }},
            "content": {{ home_excerpt | jsonify }}
          }
          {% assign first = false %}
        {% endif %}
        {% assign generated_sidebar = site.data.jekyll_vitepress_sidebar %}
        {% assign sidebar_groups = generated_sidebar.groups | default: site.data.sidebar %}
        {% for group in sidebar_groups %}
          {% if group.docs %}
            {% assign docs = group.docs %}
          {% else %}
            {% assign docs = site[group.collection] | sort: 'nav_order' %}
          {% endif %}
          {% for doc in docs %}
            {% if doc.title and doc.url %}
              {% unless first %},{% endunless %}
              {% assign excerpt = doc.content | markdownify | strip_html | strip_newlines | replace: '  ', ' ' | strip | truncate: 2400, '' %}
              {
                "title": {{ doc.title | strip_html | strip | jsonify }},
                "url": {{ doc.url | relative_url | jsonify }},
                "content": {{ excerpt | jsonify }}
              }
              {% assign first = false %}
            {% endif %}
          {% endfor %}
        {% endfor %}
        ]
      LIQUID

      class GeneratedPage < Jekyll::PageWithoutAFile
        def initialize(site)
          super(site, site.source, '', 'search.json')

          self.content = TEMPLATE
          data['layout'] = nil
          data['permalink'] = '/search.json'
        end
      end

      def apply(site)
        return if custom_page?(site)

        site.pages << GeneratedPage.new(site)
      end

      def custom_page?(site)
        site.pages.any? { |page| search_index_path?(page.path) || search_index_url?(page.url) } ||
          site.static_files.any? { |file| search_index_path?(file.path) || search_index_url?(file.relative_path) }
      end

      def search_index_path?(value)
        return false unless value

        Pathname.new(value.to_s).basename.to_s == 'search.json'
      rescue ArgumentError
        false
      end

      def search_index_url?(value)
        value.to_s.strip == '/search.json'
      end
    end

    module LastUpdated
      module_function

      def source_file_time(site, path)
        return nil unless path

        source_path = if Pathname.new(path).absolute?
                        path
                      else
                        File.join(site.source, path)
                      end

        return nil unless File.file?(source_path)

        File.mtime(source_path).utc
      end
    end

    module RougeStyles
      module_function

      DEFAULT_LIGHT = 'github'.freeze
      DEFAULT_DARK = 'github.dark'.freeze

      def apply(site)
        theme_config = site.config['jekyll_vitepress']
        return unless theme_config.is_a?(Hash)

        light_name, dark_name = resolved_theme_names(theme_config['syntax'])
        light_name = valid_theme_name(light_name, DEFAULT_LIGHT)
        dark_name = valid_theme_name(dark_name, DEFAULT_DARK)

        theme_config['syntax'] = {
          'light_theme' => light_name,
          'dark_theme' => dark_name
        }
        theme_config['_generated_rouge_css'] = generated_css(light_name, dark_name)
      rescue StandardError => e
        Jekyll.logger.warn('jekyll-vitepress-theme', "Rouge theme generation failed: #{e.message}")
      end

      def resolved_theme_names(syntax_config)
        return [DEFAULT_LIGHT, DEFAULT_DARK] unless syntax_config.is_a?(Hash)

        light = normalized_name(syntax_config['light_theme'] || syntax_config[:light_theme])
        dark = normalized_name(syntax_config['dark_theme'] || syntax_config[:dark_theme])

        [light || DEFAULT_LIGHT, dark || DEFAULT_DARK]
      end

      def normalized_name(name)
        return nil unless name

        value = name.to_s.strip
        return nil if value.empty?

        value
      end

      def valid_theme_name(name, fallback)
        return name if Rouge::Theme.find(name)

        Jekyll.logger.warn('jekyll-vitepress-theme', "Unknown Rouge theme '#{name}', falling back to '#{fallback}'.")
        fallback
      end

      def generated_css(light_name, dark_name)
        light_theme = Rouge::Theme.find(light_name)
        dark_theme = Rouge::Theme.find(dark_name)
        return '' unless light_theme && dark_theme

        [
          light_theme.render(scope: '.vp-doc .highlighter-rouge .highlight'),
          dark_theme.render(scope: '.dark .vp-doc .highlighter-rouge .highlight')
        ].join("\n")
      end
    end

    module VersionLabel
      module_function

      AUTO_VALUE = 'auto'.freeze

      def apply(site)
        versions = site.data['versions']
        return unless versions.is_a?(Hash)

        current_value = versions['current'] || versions[:current]
        return unless auto_value?(current_value)

        versions['current'] = "v#{Jekyll::VitePressTheme::VERSION}"
      rescue StandardError => e
        Jekyll.logger.warn('jekyll-vitepress-theme', "Version label resolution failed: #{e.message}")
      end

      def auto_value?(value)
        value.to_s.strip.casecmp(AUTO_VALUE).zero?
      end
    end

    module CopyPage
      module_function

      def enabled?(item)
        site_enabled?(item.site) && page_enabled?(item)
      end

      def site_enabled?(site)
        theme_config = site.config['jekyll_vitepress']
        copy_page = theme_config['copy_page'] if theme_config.is_a?(Hash)

        !(copy_page.is_a?(Hash) && copy_page['enabled'] == false)
      end

      def page_enabled?(item)
        page_theme = item.data['jekyll_vitepress']

        page_theme != false && !(page_theme.is_a?(Hash) && page_theme['copy_page'] == false)
      end

      def resolved_markdown(item, payload)
        raw = item.content.to_s
        return raw unless item.respond_to?(:render_with_liquid?) && item.render_with_liquid?

        item.renderer.render_liquid(raw, payload, liquid_render_info(item, payload), item.path)
      rescue StandardError => e
        relative_path = item.respond_to?(:relative_path) ? item.relative_path : item.path
        Jekyll.logger.warn('jekyll-vitepress-theme', "Copy page markdown capture failed for #{relative_path}: #{e.message}")
        raw
      end

      def liquid_render_info(item, payload)
        liquid_options = item.site.config['liquid'] || {}

        {
          registers: { site: item.site, page: payload['page'] },
          strict_filters: liquid_options['strict_filters'],
          strict_variables: liquid_options['strict_variables']
        }
      end

      def with_title(markdown, title)
        return markdown if markdown.to_s.empty? || title.to_s.empty? || leading_h1?(markdown)

        "# #{title}\n\n#{markdown}"
      end

      def leading_h1?(markdown)
        return false if markdown.nil?

        stripped = markdown.lstrip
        return false if stripped.empty?

        stripped.match?(/\A#\s+\S/) ||
          stripped.match?(/\A<h1(?:\s|>)/i) ||
          stripped.match?(/\A[^\n]+\n=+\s*(?:\n|$)/)
      end
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  Jekyll::VitePressTheme::VersionLabel.apply(site)
  Jekyll::VitePressTheme::RougeStyles.apply(site)
  Jekyll::VitePressTheme::Sidebar.apply(site)
  Jekyll::VitePressTheme::SearchIndex.apply(site)
end

capture_page_state = lambda do |item, payload|
  if Jekyll::VitePressTheme::CopyPage.enabled?(item)
    raw = Jekyll::VitePressTheme::CopyPage.resolved_markdown(item, payload)
    item.data['_raw_markdown'] = Jekyll::VitePressTheme::CopyPage.with_title(raw, item.data['title'])
  end

  next if item.data.key?('last_updated_at')

  updated_at = Jekyll::VitePressTheme::LastUpdated.source_file_time(item.site, item.path)
  item.data['last_updated_at'] = updated_at if updated_at
end

Jekyll::Hooks.register :documents, :pre_render, &capture_page_state
Jekyll::Hooks.register :pages, :pre_render, &capture_page_state

# Write raw .md files after site build using the same content as "Copy page"
Jekyll::Hooks.register :site, :post_write do |site|
  next unless Jekyll::VitePressTheme::CopyPage.site_enabled?(site)

  items = site.pages.select { |p| p.output_ext == '.html' } +
          site.collections.values.flat_map(&:docs)

  items.each do |item|
    raw = item.data['_raw_markdown']
    next if raw.nil? || raw.empty?

    base_path = item.url.sub(/\.html$/, '').sub(%r{/$}, '')
    md_path = "#{base_path}.md"
    md_path = '/index.md' if item.url == '/'

    dest = File.join(site.dest, md_path)
    FileUtils.mkdir_p(File.dirname(dest))
    File.write(dest, raw)
  end
end
