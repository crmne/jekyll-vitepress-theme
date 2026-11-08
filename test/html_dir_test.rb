# frozen_string_literal: true

require 'tmpdir'
require_relative 'test_helper'

class HtmlDirTest < Minitest::Test
  FIXTURE = File.expand_path('fixtures/seo_site', __dir__)

  def render(overrides = {})
    Dir.mktmpdir('jekyll-vitepress-dir') do |destination|
      config = Jekyll.configuration(
        { 'config' => File.join(FIXTURE, '_config.yml'), 'source' => FIXTURE, 'destination' => destination,
          'quiet' => true, 'disable_disk_cache' => true }.merge(overrides)
      )
      Jekyll::Site.new(config).process
      return File.read(File.join(destination, 'guide', 'index.html'))[/<html[^>]*>/]
    end
  end

  # Jekyll answers page.dir with the page's URL directory, which is not a
  # text direction and must not reach the dir attribute.
  def test_pages_get_no_dir_from_their_url_directory
    assert_equal '<html lang="en-GB">', render
  end

  def test_site_text_direction_is_used
    assert_equal '<html lang="en-GB" dir="rtl">', render('dir' => 'rtl')
  end
end
