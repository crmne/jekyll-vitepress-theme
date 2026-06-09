require_relative 'test_helper'

class CopyPageTest < Minitest::Test
  CopyPage = Jekyll::VitePressTheme::CopyPage

  FakeSite = Struct.new(:config)
  FakeItem = Struct.new(:site, :data)

  def site(config = {})
    FakeSite.new(config)
  end

  def item(site_config: {}, data: {})
    FakeItem.new(site(site_config), data)
  end

  def test_leading_h1_detects_atx_heading
    assert CopyPage.leading_h1?("# Title\n\nBody")
  end

  def test_leading_h1_detects_html_heading
    assert CopyPage.leading_h1?('<h1 class="x">Title</h1>')
    assert CopyPage.leading_h1?('<h1>Title</h1>')
  end

  def test_leading_h1_detects_setext_heading
    assert CopyPage.leading_h1?("Title\n=====\n\nBody")
  end

  def test_leading_h1_ignores_leading_whitespace
    assert CopyPage.leading_h1?("\n\n  # Title")
  end

  def test_leading_h1_rejects_plain_text_and_lower_headings
    refute CopyPage.leading_h1?('Just a paragraph')
    refute CopyPage.leading_h1?('## Subheading')
    refute CopyPage.leading_h1?('#NotAHeading')
    refute CopyPage.leading_h1?(nil)
    refute CopyPage.leading_h1?('')
  end

  def test_with_title_prepends_when_markdown_has_no_h1
    assert_equal "# Title\n\nBody", CopyPage.with_title('Body', 'Title')
  end

  def test_with_title_keeps_markdown_with_leading_h1
    assert_equal "# Own\n\nBody", CopyPage.with_title("# Own\n\nBody", 'Title')
  end

  def test_with_title_keeps_empty_markdown_empty
    assert_equal '', CopyPage.with_title('', 'Title')
  end

  def test_with_title_without_title_returns_markdown
    assert_equal 'Body', CopyPage.with_title('Body', nil)
    assert_equal 'Body', CopyPage.with_title('Body', '')
  end

  def test_enabled_by_default
    assert CopyPage.enabled?(item)
  end

  def test_disabled_site_wide
    config = { 'jekyll_vitepress' => { 'copy_page' => { 'enabled' => false } } }
    refute CopyPage.enabled?(item(site_config: config))
    refute CopyPage.site_enabled?(site(config))
  end

  def test_site_enabled_with_explicit_true
    config = { 'jekyll_vitepress' => { 'copy_page' => { 'enabled' => true } } }
    assert CopyPage.site_enabled?(site(config))
  end

  def test_disabled_per_page_with_false_theme
    refute CopyPage.enabled?(item(data: { 'jekyll_vitepress' => false }))
  end

  def test_disabled_per_page_with_copy_page_false
    refute CopyPage.enabled?(item(data: { 'jekyll_vitepress' => { 'copy_page' => false } }))
  end

  def test_page_setting_does_not_override_site_disable
    config = { 'jekyll_vitepress' => { 'copy_page' => { 'enabled' => false } } }
    data = { 'jekyll_vitepress' => { 'copy_page' => true } }
    refute CopyPage.enabled?(item(site_config: config, data: data))
  end
end
