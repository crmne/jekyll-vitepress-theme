# frozen_string_literal: true

module Jekyll
  module VitePressTheme
    # Generates the proposed llms.txt index and its full-text companion from
    # the same canonical, indexable content used by the theme's SEO layer.
    # rubocop:disable Metrics/AbcSize, Metrics/ModuleLength
    module LLMS
      module_function

      class GeneratedPage < Jekyll::PageWithoutAFile
        def initialize(site, name, content)
          super(site, site.source, '', name)
          self.content = content
          data['layout'] = nil
          data['permalink'] = "/#{name}"
          data['seo'] = false
          data['sitemap'] = false
          data['llms'] = false
        end

        def render_with_liquid?
          false
        end
      end

      def apply(site)
        config = config_for(site)
        return unless enabled?(config)

        groups = content_groups(site)
        return if groups.empty?

        unless SEO.custom_output?(site, 'llms.txt')
          site.pages << GeneratedPage.new(site, 'llms.txt', render_index(site, config, groups))
        end

        return unless full_text?(config) && !SEO.custom_output?(site, 'llms-full.txt')

        site.pages << GeneratedPage.new(site, 'llms-full.txt', render_full(site, config, groups))
      rescue StandardError => e
        Jekyll.logger.warn('jekyll-vitepress-theme', "LLM discovery generation failed: #{e.message}")
      end

      def config_for(site)
        theme_config = site.config['jekyll_vitepress']
        return {} unless theme_config.is_a?(Hash)

        value = theme_config.fetch('llms', {})
        value == false ? false : hash_value(value)
      end

      def enabled?(config)
        config != false && config.fetch('enabled', true) != false
      end

      def full_text?(config)
        config.fetch('full', config.fetch('include_full_text', true)) != false
      end

      def content_groups(site)
        eligible = SEO.html_items(site).select { |item| eligible?(item) }
        used = {}.compare_by_identity
        groups = []

        home = eligible.find { |item| item.url == '/' }
        add_group(groups, used, 'Overview', [home].compact)

        sidebar_groups(site).each do |group|
          docs = Array(group['docs']).select { |item| eligible.include?(item) }
          add_group(groups, used, group['title'] || collection_title(group['collection']), docs)
        end

        remaining = eligible.reject { |item| used[item] }
        remaining.group_by { |item| collection_label(item) }.each do |label, items|
          title = label ? collection_title(label) : 'Pages'
          add_group(groups, used, title, sorted_items(items))
        end

        groups
      end

      def eligible?(item)
        return false if item.data['llms'] == false || item.data['redirect_to']
        return false if ['/404.html', '/404/'].include?(item.url)

        metadata = item.data['_seo']
        robots = metadata&.dig('robots') || item.data['robots']
        tokens = robots.to_s.downcase.split(/[\s,]+/)
        return false if item.data['noindex'] == true || tokens.intersect?(%w[noindex none])

        canonical = metadata&.dig('canonical_url')
        self_url = SEO.absolute_url(item.site, item.url)
        canonical.to_s.empty? || self_url.to_s.empty? || canonical == self_url
      end

      def render_index(site, config, groups)
        lines = header_lines(site, config)
        details = config['details'].to_s.strip
        lines.push(details, '') unless details.empty?

        if full_text?(config)
          lines << '## Full Documentation'
          lines << ''
          lines << "- [Complete documentation](#{site_url(site, '/llms-full.txt')}): All canonical pages in one Markdown document."
          lines << ''
        end

        groups.each do |group|
          lines << "## #{plain_heading(group[:title])}"
          lines << ''
          group[:items].each do |item|
            title = link_label(item_title(item))
            entry = "- [#{title}](#{canonical_url(item)})"
            description = item_description(item)
            entry += ": #{description}" if description
            lines << entry
          end
          lines << ''
        end

        "#{lines.join("\n").rstrip}\n"
      end

      def render_full(site, config, groups)
        title = config['title'] || SEO.site_title(site) || 'Documentation'
        description = config['description'] || site.config['description']
        lines = ["# #{plain_heading(title)} — Full Documentation", '']
        lines.push("> #{SEO.clean_text(description)}", '') if SEO.clean_text(description)

        groups.flat_map { |group| group[:items] }.each do |item|
          lines << '---'
          lines << ''
          lines << "# #{plain_heading(item_title(item))}"
          lines << ''
          lines << "Canonical URL: #{canonical_url(item)}"
          lines << ''
          content = strip_leading_title(raw_markdown(item, site))
          content = item_description(item).to_s if content.empty?
          lines << content
          lines << ''
        end

        "#{lines.join("\n").rstrip}\n"
      end

      def header_lines(site, config)
        title = config['title'] || SEO.site_title(site) || 'Documentation'
        description = config['description'] || site.config['description']
        lines = ["# #{plain_heading(title)}", '']
        lines.push("> #{SEO.clean_text(description)}", '') if SEO.clean_text(description)
        lines
      end

      def raw_markdown(item, site)
        payload = site.site_payload.merge('page' => item.to_liquid)
        raw = CopyPage.resolved_markdown(item, payload)
        CopyPage.with_title(raw, item_title(item)).to_s.strip
      end

      def strip_leading_title(markdown)
        markdown.to_s
                .sub(/\A\s*#\s+[^\n]+\n+/, '')
                .sub(%r{\A\s*<h1(?:\s[^>]*)?>.*?</h1>\s*}mi, '')
                .sub(/\A\s*[^\n]+\n=+\s*\n+/, '')
                .gsub(/\n{3,}/, "\n\n")
                .strip
      end

      def canonical_url(item)
        item.data.dig('_seo', 'canonical_url') || site_url(item.site, item.url)
      end

      def site_url(site, path)
        SEO.absolute_url(site, path) || relative_url(site, path)
      end

      def relative_url(site, path)
        baseurl = site.config['baseurl'].to_s.sub(%r{/+\z}, '')
        path = "/#{path}" unless path.start_with?('/')
        "#{baseurl}#{path}"
      end

      def item_title(item)
        item.data.dig('_seo', 'page_title') || SEO.clean_text(item.data['title']) || item.url
      end

      def item_description(item)
        SEO.clean_text(item.data.dig('_seo', 'description') || item.data['description'])
      end

      def sidebar_groups(site)
        data = site.data['jekyll_vitepress_sidebar']
        data.is_a?(Hash) ? Array(data['groups']) : []
      end

      def add_group(groups, used, title, items)
        items = items.reject { |item| used[item] }
        return if items.empty?

        items.each { |item| used[item] = true }
        groups << { title: title, items: items }
      end

      def sorted_items(items)
        items.sort_by do |item|
          order = item.data['nav_order']
          [order.is_a?(Numeric) ? order : Float::INFINITY, item.url.to_s]
        end
      end

      def collection_label(item)
        return unless item.respond_to?(:collection) && item.collection

        item.collection.label
      end

      def collection_title(label)
        label.to_s.tr('_-', ' ').split.map(&:capitalize).join(' ')
      end

      def plain_heading(value)
        SEO.clean_text(value).to_s.gsub(/[\r\n#]+/, ' ').strip
      end

      def link_label(value)
        plain_heading(value).gsub(/([\[\]])/, '\\\1')
      end

      def hash_value(value)
        value.is_a?(Hash) ? value : {}
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/ModuleLength
  end
end
