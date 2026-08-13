require_relative 'test_helper'
require 'tmpdir'

class VersionLabelTest < Minitest::Test
  VersionLabel = Jekyll::VitePressTheme::VersionLabel
  FakeSite = Struct.new(:config, :data, :source)

  def site(config: {}, current: 'auto', source: Dir.pwd)
    FakeSite.new(config, { 'versions' => { 'current' => current } }, source)
  end

  def test_auto_value_matches_case_insensitively
    assert VersionLabel.auto_value?('auto')
    assert VersionLabel.auto_value?('AUTO')
    assert VersionLabel.auto_value?(' auto ')
  end

  def test_auto_value_rejects_other_values
    refute VersionLabel.auto_value?('v1.2.3')
    refute VersionLabel.auto_value?(nil)
    refute VersionLabel.auto_value?('')
  end

  def test_auto_uses_the_configured_literal_version
    subject = site(config: { 'jekyll_vitepress' => { 'version' => { 'value' => '2.0.0' } } })
    VersionLabel.apply(subject)

    assert_equal 'v2.0.0', subject.data['versions']['current']
  end

  def test_configured_literal_tolerates_a_leading_v
    subject = site(config: { 'jekyll_vitepress' => { 'version' => { 'value' => 'v3.1' } } })
    VersionLabel.apply(subject)

    assert_equal 'v3.1', subject.data['versions']['current']
  end

  def test_auto_reads_the_version_from_a_file_relative_to_the_site_source
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'lib', 'my_gem'))
      File.write(File.join(dir, 'lib', 'my_gem', 'version.rb'), "module MyGem\n  VERSION = '4.5.6'\nend\n")

      subject = site(
        config: { 'jekyll_vitepress' => { 'version' => { 'file' => 'lib/my_gem/version.rb' } } },
        source: dir
      )
      VersionLabel.apply(subject)

      assert_equal 'v4.5.6', subject.data['versions']['current']
    end
  end

  def test_auto_falls_back_to_the_theme_version_without_configuration
    subject = site
    VersionLabel.apply(subject)

    assert_equal "v#{Jekyll::VitePressTheme::VERSION}", subject.data['versions']['current']
  end

  def test_a_missing_version_file_falls_back_rather_than_raising
    subject = site(config: { 'jekyll_vitepress' => { 'version' => { 'file' => 'nope/version.rb' } } })
    VersionLabel.apply(subject)

    assert_equal "v#{Jekyll::VitePressTheme::VERSION}", subject.data['versions']['current']
  end

  def test_a_non_auto_current_is_left_alone
    subject = site(config: { 'jekyll_vitepress' => { 'version' => { 'value' => '2.0.0' } } }, current: 'next')
    VersionLabel.apply(subject)

    assert_equal 'next', subject.data['versions']['current']
  end
end
