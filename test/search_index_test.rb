require_relative 'test_helper'

class SearchIndexTest < Minitest::Test
  SearchIndex = Jekyll::VitePressTheme::SearchIndex

  FakePage = Struct.new(:path, :url)
  FakeStaticFile = Struct.new(:path, :relative_path)
  FakeSite = Struct.new(:pages, :static_files)

  def test_no_custom_page_on_empty_site
    refute SearchIndex.custom_page?(FakeSite.new([], []))
  end

  def test_detects_custom_page_by_path
    site = FakeSite.new([FakePage.new('search.json', '/search.json')], [])
    assert SearchIndex.custom_page?(site)
  end

  def test_detects_custom_page_by_nested_path
    site = FakeSite.new([FakePage.new('docs/search.json', '/docs/search.json')], [])
    assert SearchIndex.custom_page?(site)
  end

  def test_detects_custom_page_by_url
    site = FakeSite.new([FakePage.new('something.md', '/search.json')], [])
    assert SearchIndex.custom_page?(site)
  end

  def test_detects_custom_static_file
    site = FakeSite.new([], [FakeStaticFile.new('/site/search.json', '/search.json')])
    assert SearchIndex.custom_page?(site)
  end

  def test_ignores_unrelated_pages
    site = FakeSite.new(
      [FakePage.new('index.md', '/'), FakePage.new('research.json', '/research.json')],
      [FakeStaticFile.new('/site/assets/app.js', '/assets/app.js')]
    )
    refute SearchIndex.custom_page?(site)
  end

  def test_search_index_path_handles_nil_and_invalid_values
    refute SearchIndex.search_index_path?(nil)
    refute SearchIndex.search_index_path?('')
    assert SearchIndex.search_index_path?('search.json')
  end
end
