# frozen_string_literal: true

module Jekyll
  module VitePressTheme
    # The part of versioned docs that runs inside each version's build.
    #
    # `jekyll-vitepress build` builds every published version separately and
    # hands each build a `vitepress_version` entry in its configuration. This
    # module turns that entry into the version selector, and gives the SEO
    # module the labelled site title and version-local canonical URLs. The
    # banner on unreleased and older versions reads the same entry from
    # `site.vitepress_version`.
    module Versions
      module_function

      CONFIG_KEY = 'vitepress_version'

      def current(site)
        value = site.config[CONFIG_KEY]
        value.is_a?(Hash) ? value : nil
      end

      def stable?(site)
        version = current(site)
        version.nil? || version['kind'] == 'stable'
      end

      def apply(site)
        version = current(site)
        return unless version

        site.data['versions'] = {
          'current' => version['id'],
          'items' => Array(version['items']).map { |item| item.is_a?(Hash) ? item.dup : item }
        }
      end

      # The site title that page titles end with: "RubyLLM Next" or
      # "RubyLLM v1" outside the stable docs, so search results and link
      # previews say which version a page belongs to.
      def site_title(site, title)
        return title if stable?(site)

        label = current(site)['label'].to_s.strip
        return title if label.empty?
        return label if title.to_s.empty?

        "#{title} #{label}"
      end

      # An absolute URL into the published site, such as a `canonical_url` in
      # front matter, names the stable docs. Inside another version it should
      # name that version's page, so it becomes a site path that the version's
      # base URL is then added to.
      def localize_url(site, value)
        version = current(site)
        return value unless version && value.is_a?(String)

        origin = site.config['url'].to_s.strip.sub(%r{/+\z}, '')
        return value if origin.empty?

        prefix = "#{origin}#{version['root_baseurl'].to_s.sub(%r{/+\z}, '')}"
        return value unless value == prefix || value.start_with?("#{prefix}/")

        path = value.delete_prefix(prefix)
        path.empty? ? '/' : path
      end
    end
  end
end
