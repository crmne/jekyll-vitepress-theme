# frozen_string_literal: true

require_relative 'test_helper'

class LlmsTest < Minitest::Test
  LLMS = Jekyll::VitePressTheme::LLMS

  FakeSite = Struct.new(:config)
  FakeItem = Struct.new(:site, :data, :url)

  def test_enabled_and_full_text_defaults
    site = FakeSite.new({ 'jekyll_vitepress' => {} })
    config = LLMS.config_for(site)

    assert LLMS.enabled?(config)
    assert LLMS.full_text?(config)
  end

  def test_site_can_disable_llm_discovery
    site = FakeSite.new({ 'jekyll_vitepress' => { 'llms' => false } })

    refute LLMS.enabled?(LLMS.config_for(site))
  end

  def test_noindex_and_external_canonical_pages_are_ineligible
    site = FakeSite.new({ 'url' => 'https://example.com', 'baseurl' => '' })
    noindex = FakeItem.new(site, { '_seo' => { 'robots' => 'noindex,follow' } }, '/private/')
    duplicate = FakeItem.new(site, { '_seo' => {
                               'robots' => 'index,follow',
                               'canonical_url' => 'https://canonical.example/guide/'
                             } }, '/guide/')

    refute LLMS.eligible?(noindex)
    refute LLMS.eligible?(duplicate)
  end

  def test_leading_title_is_removed_and_spacing_is_normalized
    markdown = "# Title\n\n\nFirst paragraph.\n\n\n\nSecond paragraph."

    assert_equal "First paragraph.\n\nSecond paragraph.", LLMS.strip_leading_title(markdown)
  end
end
