# frozen_string_literal: true

require_relative 'test_helper'

class SeoTest < Minitest::Test
  SEO = Jekyll::VitePressTheme::SEO

  FakeSite = Struct.new(:config, :pages, :collections, :static_files, :source)
  FakeCollection = Struct.new(:label, :docs, :metadata)
  FakeItem = Struct.new(:site, :data, :url, :path, :output_ext, :collection)

  def build_site(overrides = {})
    config = {
      'title' => 'Example Docs',
      'description' => 'Documentation for the example project.',
      'url' => 'https://example.com',
      'baseurl' => '/docs',
      'lang' => 'en-US',
      'logo' => '/logo.png',
      'jekyll_vitepress' => { 'seo' => {} }
    }.merge(overrides)
    FakeSite.new(config, [], {}, [], '/tmp/example')
  end

  def item(site: build_site, data: {}, url: '/guide/', path: '_guides/guide.md', collection: nil)
    FakeItem.new(site, data, url, path, '.html', collection)
  end

  def test_builds_canonical_social_and_schema_metadata
    page = item(data: {
                  'title' => 'Install <em>safely</em>',
                  'description' => 'Set up the project.',
                  'image' => { 'path' => '/card.png', 'alt' => 'Setup card', 'width' => 1200, 'height' => 630 }
                })

    metadata = SEO.metadata_for(page)
    graph = JSON.parse(metadata['json_ld']).fetch('@graph')

    assert_equal 'Install safely | Example Docs', metadata['title']
    assert_equal 'https://example.com/docs/guide/', metadata['canonical_url']
    assert_equal 'https://example.com/docs/card.png', metadata.dig('image', 'url')
    assert_equal 'en_US', metadata['locale']
    assert(graph.any? { |node| node['@type'] == 'WebSite' })
    assert(graph.any? { |node| node['@type'] == 'WebPage' && node['name'] == 'Install safely' })
    assert(graph.any? { |node| node['@type'] == 'BreadcrumbList' })
  end

  def test_metadata_text_is_plain_and_entity_decoded
    assert_equal 'Use API & SDK', SEO.clean_text('Use **API** &amp; [`SDK`](https://example.com)')
  end

  def test_custom_title_template_and_fragment_free_canonical
    page_site = build_site('jekyll_vitepress' => { 'seo' => { 'title_template' => ':site — :page' } })
    page = item(site: page_site, data: {
                  'title' => 'API',
                  'canonical_url' => 'https://canonical.example/api/#section'
                })

    metadata = SEO.metadata_for(page)

    assert_equal 'Example Docs — API', metadata['title']
    assert_equal 'https://canonical.example/api/', metadata['canonical_url']
    refute SEO.sitemap_candidate?(page, metadata)
  end

  def test_article_is_a_separate_main_entity_of_webpage
    page_site = build_site('author' => { 'name' => 'Docs Team' },
                           'jekyll_vitepress' => { 'seo' => { 'page_type' => 'Article' } })
    page = item(site: page_site, data: { 'title' => 'API Guide' })
    graph = JSON.parse(SEO.metadata_for(page)['json_ld']).fetch('@graph')
    webpage = graph.find { |node| node['@type'] == 'WebPage' }
    article = graph.find { |node| node['@type'] == 'Article' }

    assert_equal 'https://example.com/docs/guide/#article', webpage.dig('mainEntity', '@id')
    assert_equal webpage['@id'], article.dig('mainEntityOfPage', '@id')
    assert_equal 'Docs Team', article.dig('author', 'name')
  end

  def test_noindex_pages_and_404_are_excluded_from_sitemap
    noindex = item(data: { 'title' => 'Private', 'noindex' => true })
    not_found = item(data: { 'title' => 'Not found' }, url: '/404.html')

    noindex_metadata = SEO.metadata_for(noindex)
    not_found_metadata = SEO.metadata_for(not_found)

    assert_equal 'noindex,follow', noindex_metadata['robots']
    refute SEO.sitemap_candidate?(noindex, noindex_metadata)
    refute SEO.sitemap_candidate?(not_found, not_found_metadata)
  end

  def test_site_wide_noindex_disables_sitemap_discovery
    page_site = build_site('jekyll_vitepress' => { 'seo' => { 'index' => false } })
    metadata = SEO.metadata_for(item(site: page_site, data: { 'title' => 'Preview' }))

    assert_equal 'noindex,follow', metadata['robots']
    assert_nil metadata['sitemap_url']
    assert_equal "User-agent: *\nDisallow: /\n", SEO.robots_txt(page_site, SEO.config_for(page_site), nil)
  end

  def test_robots_blocks_generated_markdown_duplicates
    page_site = build_site
    robots = SEO.robots_txt(page_site, SEO.config_for(page_site), SEO.absolute_url(page_site, '/'))

    assert_includes robots, "Disallow: /*.md$\n"
    assert_includes robots, "Sitemap: https://example.com/docs/sitemap.xml\n"
  end

  def test_robots_allows_markdown_when_copy_page_is_disabled
    page_site = build_site('jekyll_vitepress' => {
                             'copy_page' => { 'enabled' => false },
                             'seo' => {}
                           })
    robots = SEO.robots_txt(page_site, SEO.config_for(page_site), SEO.absolute_url(page_site, '/'))

    refute_includes robots, '/*.md$'
  end

  def test_nested_documents_generate_nested_breadcrumbs
    page_site = build_site
    collection = FakeCollection.new('guides', [], { 'output' => true })
    parent = item(site: page_site, data: { 'title' => 'Parent' }, url: '/parent/', path: '_guides/parent.md',
                  collection: collection)
    child = item(site: page_site, data: { 'title' => 'Child', 'parent' => 'Parent' }, url: '/child/',
                 path: '_guides/child.md', collection: collection)
    collection.docs.push(parent, child)

    graph = JSON.parse(SEO.metadata_for(child)['json_ld']).fetch('@graph')
    breadcrumb = graph.find { |node| node['@type'] == 'BreadcrumbList' }
    names = breadcrumb.fetch('itemListElement').map { |entry| entry['name'] }

    assert_equal ['Example Docs', 'Parent', 'Child'], names
  end

  def test_json_ld_escapes_script_terminators
    page = item(data: { 'title' => '</script><script>alert(1)</script>' })
    json_ld = SEO.metadata_for(page)['json_ld']
    unsafe_json = SEO.safe_json('value' => '</script>')

    refute_includes json_ld, '</script>'
    assert_includes unsafe_json, '\\u003c/script\\u003e'
    JSON.parse(json_ld)
  end

  def test_sitemap_uses_only_canonical_indexable_urls_and_explicit_dates
    first = item(data: { 'title' => 'A', 'date_modified' => '2026-08-01' }, url: '/a/')
    second = item(data: { 'title' => 'B', 'noindex' => true }, url: '/b/')
    [first, second].each { |page| page.data['_seo'] = SEO.metadata_for(page) }

    sitemap = SEO.sitemap_xml([second, first])

    assert_includes sitemap, '<loc>https://example.com/docs/a/</loc>'
    assert_includes sitemap, '<lastmod>2026-08-01</lastmod>'
    refute_includes sitemap, '/b/'
  end

  def test_verifications_and_language_alternates_use_standard_config
    page_site = build_site(
      'webmaster_verifications' => { 'google' => 'google-token', 'bing' => 'bing-token' },
      'jekyll_vitepress' => { 'seo' => {} }
    )
    page = item(site: page_site, data: {
                  'title' => 'Localized',
                  'lang' => 'de-DE',
                  'alternates' => [{ 'lang' => 'en', 'url' => '/en/guide/' }]
                })

    metadata = SEO.metadata_for(page)

    assert_equal 'de_DE', metadata['locale']
    assert_equal 'https://example.com/docs/en/guide/', metadata.dig('alternates', 0, 'url')
    names = metadata['verifications'].map { |entry| entry['name'] }
    assert_equal %w[google-site-verification msvalidate.01], names
  end
end
