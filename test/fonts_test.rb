# frozen_string_literal: true

require 'tmpdir'
require_relative 'test_helper'

class FontsTest < Minitest::Test
  FIXTURE = File.expand_path('fixtures/seo_site', __dir__)
  GOOGLE = 'https://fonts.googleapis.com/css2?family=Inter&display=swap'

  def test_inter_is_served_with_the_site_and_preloaded_by_default
    home = build_home
    assert_includes home, '<link rel="preload" href="/manual/assets/fonts/inter/inter-normal-latin.woff2" ' \
                          'as="font" type="font/woff2" crossorigin>'
    assert_includes home, '<link rel="stylesheet" href="/manual/assets/css/inter.css">'
    refute_includes home, 'fonts.googleapis.com'
  end

  def test_a_google_fonts_url_loads_from_google
    home = build_home(GOOGLE)
    assert_includes home, %(<link rel="stylesheet" href="#{GOOGLE}">)
    refute_includes home, 'inter.css'
    refute_includes home, 'rel="preload"'
  end

  def test_false_loads_no_web_font
    home = build_home(false)
    refute_includes home, 'fonts.googleapis.com'
    refute_includes home, 'inter.css'
  end

  def test_every_face_the_stylesheet_names_ships_with_the_theme
    root = File.expand_path('..', __dir__)
    css = File.read(File.join(root, 'assets/css/inter.css'))
    files = css.scan(%r{url\("?\.\./fonts/inter/([^")]+)"?\)}).flatten
    assert_equal 14, files.uniq.length
    files.each { |file| assert File.file?(File.join(root, 'assets/fonts/inter', file)), file }
    assert File.file?(File.join(root, 'assets/fonts/inter/LICENSE.txt'))
  end

  private

  def build_home(google_fonts_url = :unset)
    Dir.mktmpdir('jekyll-vitepress-fonts') do |destination|
      overrides = {
        'config' => File.join(FIXTURE, '_config.yml'),
        'source' => FIXTURE,
        'destination' => destination,
        'quiet' => true,
        'disable_disk_cache' => true
      }
      config = Jekyll.configuration(overrides)
      unless google_fonts_url == :unset
        theme = config['jekyll_vitepress'] ||= {}
        (theme['typography'] ||= {})['google_fonts_url'] = google_fonts_url
      end
      Jekyll::Site.new(config).process
      File.read(File.join(destination, 'index.html'))
    end
  end
end
