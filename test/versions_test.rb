# frozen_string_literal: true

require 'tmpdir'
require_relative 'test_helper'

class VersionsTest < Minitest::Test
  FIXTURE = File.expand_path('fixtures/seo_site', __dir__)

  ITEMS = [
    { 'id' => 'stable', 'title' => '2.0.0 (stable)', 'url' => '/manual/' },
    { 'id' => 'next', 'title' => 'Next (unreleased)', 'url' => '/manual/next/' },
    { 'id' => 'v1', 'title' => '1.4.0', 'url' => '/manual/v1/' }
  ].freeze

  def version(kind, id:, label:, title:)
    {
      'id' => id, 'kind' => kind, 'title' => title, 'label' => label, 'branch' => 'main',
      'path' => kind == 'stable' ? '/' : "/#{id}/", 'root_baseurl' => '/manual',
      'stable' => { 'title' => '2.0.0 (stable)', 'url' => '/manual/' }, 'items' => ITEMS
    }
  end

  def build(vitepress_version, baseurl)
    Dir.mktmpdir('jekyll-vitepress-versions') do |destination|
      config = Jekyll.configuration(
        'config' => File.join(FIXTURE, '_config.yml'), 'source' => FIXTURE, 'destination' => destination,
        'baseurl' => baseurl, 'quiet' => true, 'disable_disk_cache' => true,
        'vitepress_version' => vitepress_version
      )
      Jekyll::Site.new(config).process
      yield destination
    end
  end

  def test_next_build_labels_titles_and_keeps_canonicals_inside_the_version
    build(version('next', id: 'next', label: 'Next', title: 'Next (unreleased)'), '/manual/next') do |site|
      home = File.read(File.join(site, 'index.html'))
      guide = File.read(File.join(site, 'guide', 'index.html'))

      assert_includes home, '<title>Downstream Docs Next</title>'
      assert_includes guide, '<title>Downstream Docs Next — Public Guide</title>'
      assert_includes guide, '<meta property="og:title" content="Downstream Docs Next — Public Guide">'
      assert_includes guide, '<meta name="twitter:title" content="Downstream Docs Next — Public Guide">'
      assert_includes home, '<link rel="canonical" href="https://docs.example.test/manual/next/">'
      assert_includes guide, 'href="https://docs.example.test/manual/next/guide/"'
      assert_includes home, 'class="has-version-banner"'
      assert_includes home, "You&#39;re reading the docs for unreleased Downstream Docs from <code>main</code>."
      assert_includes home, '<a href="/manual/">Read the 2.0.0 docs</a>'
      assert_includes home, '<span>Next (unreleased)</span>'
      assert_includes home, 'href="/manual/v1/"'
      assert_includes File.read(File.join(site, 'sitemap.xml')), '<loc>https://docs.example.test/manual/next/guide/</loc>'
    end
  end

  def test_older_build_names_its_version_in_the_banner
    build(version('older', id: 'v1', label: 'v1', title: '1.4.0'), '/manual/v1') do |site|
      home = File.read(File.join(site, 'index.html'))

      assert_includes home, '<title>Downstream Docs v1</title>'
      assert_includes home, "You&#39;re reading the docs for Downstream Docs 1.4.0."
      assert_includes home, '<span>1.4.0</span>'
    end
  end

  def test_stable_build_has_no_banner_and_plain_titles
    build(version('stable', id: 'stable', label: nil, title: '2.0.0 (stable)'), '/manual') do |site|
      home = File.read(File.join(site, 'index.html'))

      assert_includes home, '<title>Downstream Docs</title>'
      assert_includes home, '<meta property="og:title" content="Downstream Docs">'
      refute_includes home, 'vp-version-banner'
      refute_includes home, 'has-version-banner'
      assert_includes home, '<span>2.0.0 (stable)</span>'
    end
  end

  def test_absolute_canonical_in_front_matter_moves_into_the_version
    site = Jekyll::Site.new(Jekyll.configuration(
                              'source' => FIXTURE, 'url' => 'https://docs.example.test', 'baseurl' => '/manual/next',
                              'quiet' => true, 'vitepress_version' => version('next', id: 'next', label: 'Next',
                                                                                      title: 'Next (unreleased)')
                            ))

    assert_equal '/guide/', Jekyll::VitePressTheme::Versions.localize_url(site, 'https://docs.example.test/manual/guide/')
    assert_equal 'https://elsewhere.test/x/', Jekyll::VitePressTheme::Versions.localize_url(site, 'https://elsewhere.test/x/')
  end
end
