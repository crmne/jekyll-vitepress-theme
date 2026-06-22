require_relative 'test_helper'

class SidebarTest < Minitest::Test
  Sidebar = Jekyll::VitePressTheme::Sidebar
  FakeDoc = Struct.new(:data, :url)

  def doc(title, url, nav_order:, **frontmatter)
    data = {
      'title' => title,
      'nav_order' => nav_order
    }
    frontmatter.each do |key, value|
      data[key.to_s] = value unless value.nil?
    end

    FakeDoc.new(data, url)
  end

  def test_builds_parent_child_tree_and_depth_first_doc_order
    chat = doc('Chat', '/chat/', nav_order: 1)
    attachments = doc('Attachments', '/attachments/', nav_order: 1, parent: 'Chat')
    streaming = doc('Streaming', '/streaming/', nav_order: 2, parent: 'Chat')
    tools = doc('Tools', '/tools/', nav_order: 2)

    sidebar = Sidebar.build_collection('core_features', [streaming, tools, chat, attachments])

    assert_equal(%w[Chat Tools], sidebar['items'].map { |node| node['title'] })
    assert_equal(%w[Attachments Streaming], sidebar['items'].first['children'].map { |node| node['title'] })
    assert_equal ['/chat/', '/attachments/', '/streaming/', '/tools/'], sidebar['docs'].map(&:url)
    assert_equal ['/chat/', '/attachments/', '/streaming/'], sidebar['items'].first['active_urls']
  end

  def test_grand_parent_disambiguates_repeated_parent_titles
    guide = doc('Guide', '/guide/', nav_order: 1)
    guide_setup = doc('Setup', '/guide/setup/', nav_order: 1, parent: 'Guide')
    reference = doc('Reference', '/reference/', nav_order: 2)
    reference_setup = doc('Setup', '/reference/setup/', nav_order: 1, parent: 'Reference')
    options = doc('Options', '/reference/options/', nav_order: 1, parent: 'Setup', grand_parent: 'Reference')

    sidebar = Sidebar.build_collection('docs', [guide, guide_setup, reference, reference_setup, options])
    reference_node = sidebar['items'].find { |node| node['title'] == 'Reference' }
    setup_node = reference_node['children'].find { |node| node['title'] == 'Setup' }

    assert_equal(['Options'], setup_node['children'].map { |node| node['title'] })
  end

  def test_mixed_nav_order_values_are_sorted_consistently
    numeric = doc('Numeric', '/numeric/', nav_order: 2)
    string = doc('String', '/string/', nav_order: 'alpha')
    missing = FakeDoc.new({ 'title' => 'Missing' }, '/missing/')

    sidebar = Sidebar.build_collection('docs', [missing, string, numeric])

    assert_equal(%w[Numeric String Missing], sidebar['items'].map { |node| node['title'] })
  end

  def test_collapsed_frontmatter_is_copied_to_node
    parent = doc('Chat', '/chat/', nav_order: 1, collapsed: true)
    child = doc('Streaming', '/streaming/', nav_order: 1, parent: 'Chat')

    sidebar = Sidebar.build_collection('docs', [parent, child])

    assert_equal true, sidebar['items'].first['collapsed']
  end
end
