# frozen_string_literal: true

require 'json'
require 'tmpdir'
require_relative 'test_helper'

class SeoIntegrationTest < Minitest::Test
  FIXTURE = File.expand_path('fixtures/seo_site', __dir__)

  def test_downstream_site_gets_complete_seo_without_extra_plugins
    Dir.mktmpdir('jekyll-vitepress-seo') do |destination|
      config = Jekyll.configuration(
        'config' => File.join(FIXTURE, '_config.yml'),
        'source' => FIXTURE,
        'destination' => destination,
        'quiet' => true,
        'disable_disk_cache' => true
      )
      Jekyll::Site.new(config).process

      home = File.read(File.join(destination, 'index.html'))
      private_page = File.read(File.join(destination, 'private', 'index.html'))
      sitemap = File.read(File.join(destination, 'sitemap.xml'))
      robots = File.read(File.join(destination, 'robots.txt'))
      llms = File.read(File.join(destination, 'llms.txt'))
      llms_full = File.read(File.join(destination, 'llms-full.txt'))

      assert_complete_home_metadata(home)
      assert_includes private_page, '<meta name="robots" content="noindex,follow">'
      assert_includes sitemap, '<loc>https://docs.example.test/manual/</loc>'
      refute_includes sitemap, '/private/'
      assert_includes robots, 'Disallow: /*.md$'
      assert_includes robots, 'Sitemap: https://docs.example.test/manual/sitemap.xml'
      assert_includes private_page, 'rel="nofollow noreferrer"'
      assert_includes private_page, 'data-title="Downstream Docs — Internal Preview"'
      assert_llm_discovery(llms, llms_full)

      assert_schema_graph(home)
    end
  end

  private

  def assert_complete_home_metadata(home)
    assert_equal 1, home.scan('rel="canonical"').length
    assert_equal 1, home.scan('application/ld+json').length
    assert_match(/<html lang="en-GB"[^>]*>/, home)
    assert_includes home, '<link rel="canonical" href="https://docs.example.test/manual/">'
    assert_includes home, '<meta property="og:image:width" content="1200">'
  end

  def assert_schema_graph(home)
    json = home[%r{<script type="application/ld\+json">(.*?)</script>}m, 1]
    graph = JSON.parse(json).fetch('@graph')
    assert(graph.any? { |node| node['@type'] == 'WebSite' })
    assert(graph.any? { |node| node['@type'] == 'WebPage' })
  end

  def assert_llm_discovery(index, full)
    assert_match(/\A# Downstream Docs\n/, index)
    assert_includes index, '[Public Guide](https://docs.example.test/manual/guide/)'
    assert_includes index, '[Complete documentation](https://docs.example.test/manual/llms-full.txt)'
    refute_includes index, 'Internal Preview'
    assert_includes full, '# Public Guide'
    assert_includes full, 'Public downstream documentation with `{{ product.name }}` preserved as an example.'
    refute_includes full, 'Private preview content.'
  end
end
