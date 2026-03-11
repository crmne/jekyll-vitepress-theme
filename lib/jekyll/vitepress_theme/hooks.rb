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
        vp_theme = site.config['vp_theme']
        return unless vp_theme.is_a?(Hash)

        light_name, dark_name = resolved_theme_names(vp_theme)
        light_name = valid_theme_name(light_name, DEFAULT_LIGHT)
        dark_name = valid_theme_name(dark_name, DEFAULT_DARK)

        vp_theme['rouge_theme'] = {
          'light' => light_name,
          'dark' => dark_name
        }
        vp_theme['_generated_rouge_css'] = generated_css(light_name, dark_name)
      rescue StandardError => e
        Jekyll.logger.warn('jekyll-vitepress-theme', "Rouge theme generation failed: #{e.message}")
      end

      def resolved_theme_names(vp_theme)
        rouge_theme = vp_theme['rouge_theme']

        light = nil
        dark = nil

        if rouge_theme.is_a?(String)
          light = normalized_name(rouge_theme)
        elsif rouge_theme.is_a?(Hash)
          light = normalized_name(rouge_theme['light'] || rouge_theme[:light])
          dark = normalized_name(rouge_theme['dark'] || rouge_theme[:dark])
        end

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
        vp_theme = site.config['vp_theme']
        return unless vp_theme.is_a?(Hash)

        version_config = vp_theme['version']
        return unless version_config.is_a?(Hash)

        current_value = version_config['current'] || version_config[:current]
        return unless auto_value?(current_value)

        version_config['current'] = "v#{Jekyll::VitePressTheme::VERSION}"
      rescue StandardError => e
        Jekyll.logger.warn('jekyll-vitepress-theme', "Version label resolution failed: #{e.message}")
      end

      def auto_value?(value)
        value.to_s.strip.casecmp(AUTO_VALUE).zero?
      end
    end
  end
end

Jekyll::Hooks.register :site, :after_reset do |site|
  Jekyll::VitePressTheme::VersionLabel.apply(site)
  Jekyll::VitePressTheme::RougeStyles.apply(site)
end

Jekyll::Hooks.register :documents, :pre_render do |document|
  next if document.data.key?('last_updated_at')

  updated_at = Jekyll::VitePressTheme::LastUpdated.source_file_time(document.site, document.path)
  document.data['last_updated_at'] = updated_at if updated_at
end

Jekyll::Hooks.register :pages, :pre_render do |page|
  next if page.data.key?('last_updated_at')

  updated_at = Jekyll::VitePressTheme::LastUpdated.source_file_time(page.site, page.path)
  page.data['last_updated_at'] = updated_at if updated_at
end
