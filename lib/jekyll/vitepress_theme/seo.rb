# frozen_string_literal: true

require 'cgi'
require 'json'
require 'time'
require 'uri'

module Jekyll
  module VitePressTheme
    # Generates the metadata shared by the HTML head, sitemap, and robots.txt.
    # Keeping those outputs on one canonical URL resolver prevents contradictory
    # indexing signals across theme consumers.
    # rubocop:disable Metrics/AbcSize, Metrics/ModuleLength
    module SEO
      module_function

      DEFAULT_ROBOTS = 'index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1'
      ARTICLE_TYPES = %w[Article BlogPosting NewsArticle TechArticle].freeze
      VERIFICATION_NAMES = {
        'google' => 'google-site-verification',
        'bing' => 'msvalidate.01',
        'yandex' => 'yandex-verification',
        'baidu' => 'baidu-site-verification',
        'facebook' => 'facebook-domain-verification'
      }.freeze

      class GeneratedPage < Jekyll::PageWithoutAFile
        def initialize(site, name, content)
          super(site, site.source, '', name)
          self.content = content
          data['layout'] = nil
          data['sitemap'] = false
          data['seo'] = false
        end
      end

      def apply(site)
        return unless enabled?(site)

        items = html_items(site)
        items.each { |item| prepare(item) }
        warn_about_metadata(site, items)
        generate_discovery_files(site, items)
      rescue StandardError => e
        Jekyll.logger.warn('jekyll-vitepress-theme', "SEO generation failed: #{e.message}")
      end

      def prepare(item)
        return unless enabled?(item.site)

        page_config = page_config(item)
        if page_config == false
          item.data['_seo_disabled'] = true
          item.data.delete('_seo')
          return
        end

        metadata = metadata_for(item, page_config)
        item.data['_seo'] = metadata
        item.data['sitemap'] = false unless sitemap_candidate?(item, metadata)
        metadata
      end

      def enabled?(site)
        config = config_for(site)
        config != false && !(config.is_a?(Hash) && config['enabled'] == false)
      end

      def config_for(site)
        theme_config = site.config['jekyll_vitepress']
        return {} unless theme_config.is_a?(Hash)

        value = theme_config.fetch('seo', {})
        value == false ? false : hash_value(value)
      end

      def page_config(item)
        value = item.data['seo']
        return false if value == false

        value.is_a?(Hash) ? value : {}
      end

      def metadata_for(item, page_config = page_config(item))
        site = item.site
        config = config_for(site)
        page_title = clean_text(page_config['title'] || item.data['title'] || site_title(site))
        full_title = full_title_for(page_title, site_title(site), config)
        description = clean_text(page_config['description'] || item.data['description'] || site.config['description'])
        canonical = canonical_url(site, page_config['canonical_url'] || item.data['canonical_url'] || item.url)
        locale = locale_for(item)
        image = image_for(item, page_config, config)
        author = author_for(item, page_config)
        schema_type = schema_type_for(item, page_config, config)
        dates = dates_for(item, page_config)
        robots = robots_for(item, page_config, config)
        alternates = alternates_for(item, page_config)
        publisher = publisher_for(site, config)

        metadata = {
          'title' => full_title,
          'page_title' => page_title,
          'description' => description,
          'canonical_url' => canonical,
          'locale' => locale.tr('-', '_'),
          'language' => locale.tr('_', '-'),
          'robots' => robots,
          'og_type' => ARTICLE_TYPES.include?(schema_type) ? 'article' : 'website',
          'image' => image,
          'author' => author,
          'twitter' => twitter_for(item, author),
          'facebook' => hash_value(site.config['facebook']),
          'verifications' => verifications_for(site),
          'alternates' => alternates,
          'date_published' => dates['published'],
          'date_modified' => dates['modified'],
          'sitemap_url' => sitemap_enabled?(config) ? absolute_url(site, '/sitemap.xml') : nil
        }
        metadata['json_ld'] = json_ld_for(item, metadata, schema_type, publisher, config)
        metadata
      end

      def full_title_for(page_title, title, config)
        return title if page_title.to_s.empty?
        return page_title if title.to_s.empty? || page_title == title

        template = config.is_a?(Hash) ? config['title_template'] : nil
        if template.to_s.include?(':page') || template.to_s.include?(':site')
          clean_text(template.to_s.gsub(':page', page_title).gsub(':site', title))
        else
          separator = config.is_a?(Hash) ? config.fetch('title_separator', ' | ') : ' | '
          "#{page_title}#{separator}#{title}"
        end
      end

      def robots_for(item, page_config, config)
        explicit = page_config['robots'] || item.data['robots']
        return clean_text(explicit) if explicit && explicit != true

        site_index = !config.is_a?(Hash) || config.fetch('index', true) != false
        noindex = page_config['noindex'] == true || item.data['noindex'] == true || !site_index
        nofollow = page_config['nofollow'] == true || item.data['nofollow'] == true
        return "noindex,#{nofollow ? 'nofollow' : 'follow'}" if noindex

        return DEFAULT_ROBOTS unless config.is_a?(Hash)

        clean_text(config['robots']) || DEFAULT_ROBOTS
      end

      def image_for(item, page_config, config)
        raw = page_config['image'] || item.data['image']
        raw ||= config['image'] if config.is_a?(Hash)
        raw ||= item.site.config['logo']
        return nil if raw.nil? || raw == false

        image = raw.is_a?(Hash) ? raw : { 'path' => raw }
        path = image['path'] || image['src'] || image['url']
        return nil if path.to_s.strip.empty?

        {
          'url' => absolute_url(item.site, path),
          'alt' => clean_text(image['alt'] || item.data['image_alt'] || item.data['title'] || site_title(item.site)),
          'width' => positive_integer(image['width']),
          'height' => positive_integer(image['height'])
        }.compact
      end

      def author_for(item, page_config)
        value = page_config['author'] || item.data['author'] || item.site.config['author']
        return nil if value.nil? || value == false

        author = value.is_a?(Hash) ? value : { 'name' => value }
        name = clean_text(author['name'] || author[:name])
        return nil if name.to_s.empty?

        {
          'name' => name,
          'url' => absolute_url(item.site, author['url'] || author[:url]),
          'twitter' => clean_text(author['twitter'] || author[:twitter])
        }.compact
      end

      def publisher_for(site, config)
        raw = config['publisher'] if config.is_a?(Hash)
        return nil unless raw.is_a?(Hash)

        name = clean_text(raw['name'] || site_title(site))
        return nil if name.to_s.empty?

        type = %w[Organization Person].include?(raw['type']) ? raw['type'] : 'Organization'
        image = raw['logo'] || site.config['logo']
        same_as = Array(raw['same_as'] || raw['sameAs']).filter_map do |url|
          absolute_url(site, url)
        end

        {
          'type' => type,
          'name' => name,
          'url' => absolute_url(site, raw['url'] || '/'),
          'logo' => absolute_url(site, image.is_a?(Hash) ? image['path'] || image['src'] : image),
          'same_as' => same_as
        }.compact
      end

      def twitter_for(item, author = nil)
        site_twitter = hash_value(item.site.config['twitter'])
        page_twitter = hash_value(item.data['twitter'])
        creator = page_twitter['creator'] || page_twitter['username'] || author&.dig('twitter')

        {
          'card' => page_twitter['card'] || site_twitter['card'] || 'summary_large_image',
          'site' => twitter_handle(site_twitter['username']),
          'creator' => twitter_handle(creator)
        }.compact
      end

      def verifications_for(site)
        values = hash_value(site.config['webmaster_verifications'])
        values['google'] ||= site.config['google_site_verification']

        VERIFICATION_NAMES.filter_map do |key, name|
          content = clean_text(values[key])
          { 'name' => name, 'content' => content } if content
        end
      end

      def alternates_for(item, page_config)
        raw = page_config['alternates'] || item.data['alternates']
        Array(raw).filter_map do |alternate|
          next unless alternate.is_a?(Hash)

          language = clean_text(alternate['lang'] || alternate['hreflang'])
          url = absolute_url(item.site, alternate['url'] || alternate['href'])
          next if language.to_s.empty? || url.to_s.empty?

          { 'hreflang' => language, 'url' => url, 'locale' => language.tr('-', '_') }
        end
      end

      def dates_for(item, page_config)
        page_theme = hash_value(item.data['jekyll_vitepress'])
        published = page_config['date_published'] || item.data['date_published']
        published ||= item.data['date'] if posts_document?(item)
        modified = page_config['date_modified'] || item.data['date_modified'] || item.data['last_modified_at']
        modified ||= page_theme['last_updated_at']

        {
          'published' => xml_time(published),
          'modified' => xml_time(modified)
        }.compact
      end

      def schema_type_for(item, page_config, config)
        value = page_config['type']
        value ||= config['page_type'] if config.is_a?(Hash)
        value = 'WebPage' if value.to_s.empty? || item.url == '/'
        clean_text(value)
      end

      def json_ld_for(item, metadata, schema_type, publisher, config)
        return nil if config.is_a?(Hash) && config.dig('schema', 'enabled') == false
        return nil if metadata['canonical_url'].to_s.empty?

        site = item.site
        root_url = absolute_url(site, '/')
        website_id = "#{root_url}#website"
        webpage_id = "#{metadata['canonical_url']}#webpage"
        graph = []

        if publisher
          publisher_id = "#{root_url}#identity"
          identity = {
            '@type' => publisher['type'], '@id' => publisher_id,
            'name' => publisher['name'], 'url' => publisher['url']
          }
          identity['logo'] = { '@type' => 'ImageObject', 'url' => publisher['logo'] } if publisher['logo']
          identity['sameAs'] = publisher['same_as'] unless publisher['same_as'].empty?
          graph << identity
        end

        website = {
          '@type' => 'WebSite', '@id' => website_id, 'url' => root_url,
          'name' => site_title(site), 'description' => clean_text(site.config['description']),
          'inLanguage' => metadata['language']
        }.compact
        website['publisher'] = { '@id' => "#{root_url}#identity" } if publisher
        graph << website

        if metadata['image']
          graph << {
            '@type' => 'ImageObject', '@id' => "#{metadata['image']['url']}#primaryimage",
            'url' => metadata['image']['url'], 'contentUrl' => metadata['image']['url'],
            'caption' => metadata['image']['alt'], 'width' => metadata['image']['width'],
            'height' => metadata['image']['height']
          }.compact
        end

        article_type = ARTICLE_TYPES.include?(schema_type)
        webpage = {
          '@type' => article_type ? 'WebPage' : schema_type,
          '@id' => webpage_id, 'url' => metadata['canonical_url'],
          'name' => metadata['page_title'],
          'description' => metadata['description'], 'isPartOf' => { '@id' => website_id },
          'inLanguage' => metadata['language'], 'datePublished' => metadata['date_published'],
          'dateModified' => metadata['date_modified']
        }.compact
        if metadata['image']
          webpage['primaryImageOfPage'] = { '@id' => "#{metadata['image']['url']}#primaryimage" }
        end

        breadcrumbs = breadcrumb_graph(item, metadata['canonical_url'], root_url)
        if breadcrumbs
          webpage['breadcrumb'] = { '@id' => "#{metadata['canonical_url']}#breadcrumb" }
          graph << breadcrumbs
        end
        graph << webpage

        if article_type
          article_id = "#{metadata['canonical_url']}#article"
          webpage['mainEntity'] = { '@id' => article_id }
          article = {
            '@type' => schema_type, '@id' => article_id,
            'mainEntityOfPage' => { '@id' => webpage_id }, 'isPartOf' => { '@id' => website_id },
            'headline' => metadata['page_title'], 'description' => metadata['description'],
            'inLanguage' => metadata['language'], 'datePublished' => metadata['date_published'],
            'dateModified' => metadata['date_modified']
          }.compact
          article['image'] = { '@id' => "#{metadata['image']['url']}#primaryimage" } if metadata['image']
          article['author'] = person_reference(metadata['author']) if metadata['author']
          article['publisher'] = { '@id' => "#{root_url}#identity" } if publisher
          graph << article
        end

        safe_json('@context' => 'https://schema.org', '@graph' => graph)
      end

      def breadcrumb_graph(item, canonical, root_url)
        return nil if item.url == '/'

        ancestors = breadcrumb_ancestors(item)
        entries = [{ 'name' => site_title(item.site), 'item' => root_url }]
        ancestors.each do |ancestor|
          entries << { 'name' => clean_text(ancestor.data['title']), 'item' => absolute_url(item.site, ancestor.url) }
        end
        entries << { 'name' => clean_text(item.data['title'] || site_title(item.site)), 'item' => canonical }
        entries.reject! { |entry| entry['name'].to_s.empty? || entry['item'].to_s.empty? }
        return nil if entries.length < 2

        {
          '@type' => 'BreadcrumbList', '@id' => "#{canonical}#breadcrumb",
          'itemListElement' => entries.each_with_index.map do |entry, index|
            { '@type' => 'ListItem', 'position' => index + 1, 'name' => entry['name'], 'item' => entry['item'] }
          end
        }
      end

      def breadcrumb_ancestors(item)
        return [] unless item.respond_to?(:collection) && item.collection

        docs = item.collection.docs
        ancestors = []
        current = item
        seen = []
        while (parent = Sidebar.parent_doc_for(current, docs)) && !seen.include?(parent)
          seen << parent
          ancestors.unshift(parent)
          current = parent
        end
        ancestors
      end

      def generate_discovery_files(site, items)
        config = config_for(site)
        return unless config.is_a?(Hash)

        site_url = absolute_url(site, '/')
        if sitemap_enabled?(config) && !custom_output?(site, 'sitemap.xml') && absolute?(site_url)
          site.pages << GeneratedPage.new(site, 'sitemap.xml', sitemap_xml(items))
        end

        return if config.fetch('robots_txt', true) == false || custom_output?(site, 'robots.txt')

        site.pages << GeneratedPage.new(site, 'robots.txt', robots_txt(site, config, site_url))
      end

      def sitemap_xml(items)
        rows = items.filter_map do |item|
          metadata = item.data['_seo']
          next unless sitemap_candidate?(item, metadata)

          last_modified = metadata['date_modified']
          last_modified ||= metadata['date_published'] if posts_document?(item)
          [metadata['canonical_url'], last_modified]
        end
        rows.uniq!(&:first)
        rows.sort_by!(&:first)

        body = rows.map do |url, last_modified|
          lastmod = last_modified ? "\n    <lastmod>#{xml_escape(last_modified)}</lastmod>" : ''
          "  <url>\n    <loc>#{xml_escape(url)}</loc>#{lastmod}\n  </url>"
        end.join("\n")

        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
          #{body}
          </urlset>
        XML
      end

      def robots_txt(site, config, site_url)
        index = config.fetch('index', true) != false
        lines = ['User-agent: *', index ? 'Allow: /' : 'Disallow: /']
        lines << 'Disallow: /*.md$' if index && CopyPage.site_enabled?(site)
        additional = config['robots_txt_rules']
        lines.push('', additional.to_s.strip) unless additional.to_s.strip.empty?
        sitemap_url = absolute_url(site, '/sitemap.xml')
        if sitemap_enabled?(config) && absolute?(site_url) && sitemap_url
          lines.push('', "Sitemap: #{sitemap_url}")
        end
        "#{lines.join("\n")}\n"
      end

      def sitemap_candidate?(item, metadata)
        return false unless metadata.is_a?(Hash)
        return false if item.data['sitemap'] == false || item.data['redirect_to'] || item.data['_seo_disabled']
        return false if ['/404.html', '/404/'].include?(item.url)

        robot_tokens = metadata['robots'].to_s.downcase.split(',').map(&:strip)
        return false if robot_tokens.intersect?(%w[noindex none])

        canonical = metadata['canonical_url']
        self_url = absolute_url(item.site, item.url)
        absolute?(canonical) && canonical == self_url
      end

      def html_items(site)
        pages = site.pages.select { |page| page.output_ext == '.html' }
        docs = site.collections.values.reject { |collection| collection.metadata['output'] == false }.flat_map(&:docs)
        (pages + docs).uniq
      end

      def custom_output?(site, name)
        expected = "/#{name}"
        (site.pages + site.static_files).any? do |item|
          item.url == expected || (item.respond_to?(:relative_path) && item.relative_path == expected)
        end
      end

      def warn_about_metadata(site, items)
        root = absolute_url(site, '/')
        unless absolute?(root)
          Jekyll.logger.warn(
            'jekyll-vitepress-theme',
            'Set an absolute `url` in _config.yml to emit canonical URLs, JSON-LD, sitemap.xml, and robots.txt discovery.'
          )
        end

        enabled_items = items.reject { |item| item.data['_seo_disabled'] }
        warn_for_items('Missing SEO title', enabled_items.select { |item| item.data.dig('_seo', 'page_title').to_s.empty? })
        warn_for_items('Missing SEO description', enabled_items.select { |item| item.data.dig('_seo', 'description').to_s.empty? })

        duplicate_titles = enabled_items.group_by { |item| item.data.dig('_seo', 'title') }
                                        .select { |title, matches| !title.to_s.empty? && matches.length > 1 }
        duplicate_titles.each do |title, matches|
          paths = matches.first(5).map { |item| item.path || item.url }.join(', ')
          Jekyll.logger.warn('jekyll-vitepress-theme', "Duplicate SEO title '#{title}': #{paths}")
        end

        duplicate_descriptions = enabled_items.group_by { |item| item.data.dig('_seo', 'description') }
                                              .select { |description, matches| !description.to_s.empty? && matches.length > 1 }
        duplicate_descriptions.each do |description, matches|
          paths = matches.first(5).map { |item| item.path || item.url }.join(', ')
          Jekyll.logger.warn('jekyll-vitepress-theme', "Duplicate SEO description '#{description}': #{paths}")
        end
      end

      def warn_for_items(label, items)
        return if items.empty?

        paths = items.first(5).map { |item| item.path || item.url }.join(', ')
        suffix = items.length > 5 ? " (and #{items.length - 5} more)" : ''
        Jekyll.logger.warn('jekyll-vitepress-theme', "#{label}: #{paths}#{suffix}")
      end

      def locale_for(item)
        value = item.data['locale'] || item.data['lang'] || item.site.config['locale'] || item.site.config['lang'] || 'en-US'
        clean_text(value) || 'en-US'
      end

      def site_title(site)
        branding = site.config.dig('jekyll_vitepress', 'branding')
        clean_text(site.config['title'] || (branding['site_title'] if branding.is_a?(Hash)))
      end

      def absolute_url(site, value)
        return nil if value.nil? || value == false

        string = value.to_s.strip
        return nil if string.empty?
        return string if absolute?(string)

        base = site.config['url'].to_s.strip.sub(%r{/+\z}, '')
        return nil if base.empty?

        baseurl = site.config['baseurl'].to_s.strip
        baseurl = '' if baseurl == '/'
        baseurl = "/#{baseurl}" unless baseurl.empty? || baseurl.start_with?('/')
        baseurl = baseurl.sub(%r{/+\z}, '')
        path = "/#{string}" unless string.start_with?('/')
        path ||= string
        "#{base}#{baseurl}#{path}".sub(%r{/index\.html\z}, '/').sub(%r{/+\z}, '/')
      end

      def canonical_url(site, value)
        url = absolute_url(site, value)
        return nil unless url

        uri = URI.parse(url)
        uri.fragment = nil
        uri.to_s
      rescue URI::InvalidURIError
        nil
      end

      def sitemap_enabled?(config)
        config.fetch('index', true) != false && config.fetch('sitemap', true) != false
      end

      def absolute?(value)
        uri = URI.parse(value.to_s)
        uri.is_a?(URI::HTTP) && uri.host
      rescue URI::InvalidURIError
        false
      end

      def clean_text(value)
        return nil if value.nil? || value == false

        text = value.to_s.gsub(/\[([^\]]+)\]\([^)]+\)/, '\\1')
                    .gsub(/<[^>]*>/, ' ')
                    .gsub(/[`*~]/, '')
                    .gsub(/\s+/, ' ')
                    .strip
        text = CGI.unescapeHTML(text)
        text.empty? ? nil : text
      end

      def positive_integer(value)
        integer = Integer(value, exception: false)
        integer if integer&.positive?
      end

      def twitter_handle(value)
        handle = clean_text(value)
        handle ? "@#{handle.delete_prefix('@')}" : nil
      end

      def hash_value(value)
        value.is_a?(Hash) ? value : {}
      end

      def posts_document?(item)
        item.respond_to?(:collection) && item.collection&.label == 'posts'
      end

      def person_reference(author)
        value = { '@type' => 'Person', 'name' => author['name'] }
        value['url'] = author['url'] if author['url']
        value
      end

      def xml_time(value)
        return nil if value.nil? || value == false
        return value if value.is_a?(String) && value.match?(/\A\d{4}-\d{2}-\d{2}\z/)

        time = value.respond_to?(:to_time) ? value.to_time : Time.parse(value.to_s)
        time.xmlschema
      rescue ArgumentError, TypeError
        nil
      end

      def safe_json(value)
        JSON.generate(value).gsub('<', '\\u003c').gsub('>', '\\u003e').gsub('&', '\\u0026')
      end

      def xml_escape(value)
        CGI.escapeHTML(value.to_s)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/ModuleLength
  end
end
