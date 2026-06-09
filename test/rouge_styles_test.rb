require_relative 'test_helper'

class RougeStylesTest < Minitest::Test
  RougeStyles = Jekyll::VitePressTheme::RougeStyles

  def test_default_theme_names_without_config
    assert_equal %w[github github.dark], RougeStyles.resolved_theme_names(nil)
    assert_equal %w[github github.dark], RougeStyles.resolved_theme_names('github')
  end

  def test_configured_theme_names
    config = { 'light_theme' => 'thankful_eyes', 'dark_theme' => 'molokai' }
    assert_equal %w[thankful_eyes molokai], RougeStyles.resolved_theme_names(config)
  end

  def test_blank_names_fall_back_to_defaults
    config = { 'light_theme' => '  ', 'dark_theme' => nil }
    assert_equal %w[github github.dark], RougeStyles.resolved_theme_names(config)
  end

  def test_valid_theme_name_keeps_known_theme
    assert_equal 'github', RougeStyles.valid_theme_name('github', 'molokai')
  end

  def test_valid_theme_name_falls_back_for_unknown_theme
    assert_equal 'github', RougeStyles.valid_theme_name('no-such-theme', 'github')
  end

  def test_generated_css_scopes_light_and_dark
    css = RougeStyles.generated_css('github', 'github.dark')
    assert_includes css, '.vp-doc .highlighter-rouge .highlight'
    assert_includes css, '.dark .vp-doc .highlighter-rouge .highlight'
  end
end
