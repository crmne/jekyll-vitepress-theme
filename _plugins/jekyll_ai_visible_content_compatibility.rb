# frozen_string_literal: true

require 'jekyll-ai-visible-content'

module JekyllAiVisibleContent
  module ContentFilter
    class << self
      def content_pages(site, config = nil)
        docs = site.posts.docs + site.pages.select { |page| content_page?(page, config) }

        site.collections.each_value do |collection|
          next if collection.label == 'posts'

          collection.docs.each do |doc|
            docs << doc if content_page?(doc, config)
          end
        end

        docs
      end
    end
  end

  module Generators
    class LlmsTxtGenerator
      private

      def append_links_section(lines, config)
        lines << '## Links'
        lines << ''
        lines << "- Website: #{config.site_url}"

        (config.entity['same_as'] || []).each do |link|
          platform = extract_platform(link)
          lines << "- #{platform}: #{link}"
        end

        lines << ''
      end
    end

    class ContentGraphGenerator
      private

      def normalize_url(url, site_url, baseurl)
        path = parse_internal_path(url.to_s.strip, site_url)
        return nil unless path

        path = '/' if path.empty?

        path = strip_query_and_fragment(path)
        return nil unless path

        path = strip_baseurl(path, baseurl)
        path = normalize_index(path)
        normalize_slash(path)
      end
    end
  end
end
