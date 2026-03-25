require 'pathname'
require 'rouge'

module Jekyll
  module VitePressTheme
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
      rescue StandardError
        nil
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
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  Jekyll::VitePressTheme::VersionLabel.apply(site)
  Jekyll::VitePressTheme::RougeStyles.apply(site)
end

Jekyll::Hooks.register :documents, :pre_render do |document|
  theme_config = document.site.config['jekyll_vitepress']
  copy_page_disabled = theme_config.is_a?(Hash) &&
                       theme_config['copy_page'].is_a?(Hash) &&
                       theme_config['copy_page']['enabled'] == false

  unless copy_page_disabled
    page_theme = document.data['jekyll_vitepress']
    copy_page_disabled = page_theme == false || (page_theme.is_a?(Hash) && page_theme['copy_page'] == false)
  end

  document.data['_raw_markdown'] = document.content unless copy_page_disabled

  next if document.data.key?('last_updated_at')

  updated_at = Jekyll::VitePressTheme::LastUpdated.source_file_time(document.site, document.path)
  document.data['last_updated_at'] = updated_at if updated_at
end

Jekyll::Hooks.register :pages, :pre_render do |page|
  theme_config = page.site.config['jekyll_vitepress']
  copy_page_disabled = theme_config.is_a?(Hash) &&
                       theme_config['copy_page'].is_a?(Hash) &&
                       theme_config['copy_page']['enabled'] == false

  unless copy_page_disabled
    page_theme = page.data['jekyll_vitepress']
    copy_page_disabled = page_theme == false || (page_theme.is_a?(Hash) && page_theme['copy_page'] == false)
  end

  page.data['_raw_markdown'] = page.content unless copy_page_disabled

  next if page.data.key?('last_updated_at')

  updated_at = Jekyll::VitePressTheme::LastUpdated.source_file_time(page.site, page.path)
  page.data['last_updated_at'] = updated_at if updated_at
end

# Write raw .md files after site build using the same content as "Copy page"
Jekyll::Hooks.register :site, :post_write do |site|
  theme_config = site.config['jekyll_vitepress']
  if theme_config.is_a?(Hash) &&
     theme_config['copy_page'].is_a?(Hash) &&
     theme_config['copy_page']['enabled'] == false
    next
  end

  items = site.pages.select { |p| p.output_ext == '.html' } +
          site.collections.values.flat_map(&:docs)

  items.each do |item|
    raw = item.data['_raw_markdown']
    next if raw.nil? || raw.empty?

    base_path = item.url.sub(/\.html$/, '').sub(%r{/$}, '')
    md_path = "#{base_path}.md"
    md_path = '/index.md' if item.url == '/'

    title = item.data['title']
    body = if title && !title.empty? && !raw.strip.start_with?('# ')
             "# #{title}\n\n#{raw}"
           else
             raw
           end

    dest = File.join(site.dest, md_path)
    FileUtils.mkdir_p(File.dirname(dest))
    File.write(dest, body)
  end
end
