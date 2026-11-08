# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'stringio'
require 'tmpdir'
require 'yaml'
require_relative 'test_helper'
require_relative '../lib/jekyll/vitepress_theme/versioned_build'

class VersionedBuildTest < Minitest::Test
  FIXTURE = File.expand_path('fixtures/seo_site', __dir__)

  def setup
    @repo = Dir.mktmpdir('jekyll-vitepress-repo')
    @docs = File.join(@repo, 'docs')
    FileUtils.cp_r(FIXTURE, @docs)
    git('init', '--quiet', '--initial-branch=main')
  end

  def teardown
    FileUtils.rm_rf(@repo)
  end

  def test_builds_stable_next_and_kept_major_into_one_site
    configure_versions(
      'next' => true,
      'keep' => [{ 'major' => 1, 'redirect_missing' => true }],
      'overlay' => ['_includes/jekyll_vitepress/layout_end.html']
    )
    write('_includes/jekyll_vitepress/layout_end.html', '<!-- shared footer -->')
    write('old.md', "---\ntitle: Old Page\npermalink: /old/\n---\n\nOnly in 1.x.\n")
    release('v1.0.0')
    write('index.md', home('Release 1.1'))
    release('v1.1.0')
    FileUtils.rm(File.join(@docs, 'old.md'))
    write('index.md', home('Release 2.0'))
    release('v2.0.0')
    write('index.md', home('Unreleased work'))
    git('commit', '--quiet', '-am', 'Work on main')

    site = File.join(@repo, 'site')
    output = build(site)

    stable = File.read(File.join(site, 'index.html'))
    following = File.read(File.join(site, 'next', 'index.html'))
    older = File.read(File.join(site, 'v1', 'index.html'))

    assert_includes stable, 'Release 2.0'
    assert_includes stable, '<title>Downstream Docs</title>'
    refute_includes stable, 'vp-version-banner'
    assert_includes following, 'Unreleased work'
    assert_includes following, '<title>Downstream Docs Next</title>'
    assert_includes following, '<a href="/manual/">Read the 2.0.0 docs</a>'
    assert_includes older, 'Release 1.1'
    assert_includes older, '<title>Downstream Docs v1</title>'
    assert_includes older, '<!-- shared footer -->', 'overlay files reach release builds'
    assert_includes older, 'href="/manual/next/"'

    assert_includes File.read(File.join(site, 'v1', 'old', 'index.html')), 'Only in 1.x.'
    assert_includes File.read(File.join(site, 'old', 'index.html')), 'window.location.replace("/manual/v1/old/"'

    robots = File.read(File.join(site, 'robots.txt'))
    assert_includes robots, 'Sitemap: https://docs.example.test/manual/sitemap.xml'
    assert_includes robots, 'Sitemap: https://docs.example.test/manual/next/sitemap.xml'
    assert_includes robots, 'Sitemap: https://docs.example.test/manual/v1/sitemap.xml'

    assert_equal(%w[v2.0.0 HEAD v1.1.0], ['', 'next', 'v1'].map { |dir| File.read(File.join(site, dir, 'version.hook')).strip })
    assert_equal 1, git('worktree', 'list').lines.size, 'release worktrees are removed'
    assert_includes output, 'Built / = v2.0.0, /next/ = this checkout, /v1/ = v1.1.0'
  end

  def test_without_versions_it_builds_once
    release('v1.0.0')
    site = File.join(@repo, 'site')
    output = build(site)

    assert_includes File.read(File.join(site, 'index.html')), '<title>Downstream Docs</title>'
    refute File.exist?(File.join(site, 'next'))
    assert_empty output
  end

  def test_without_a_release_tag_it_builds_the_checkout_once
    configure_versions('next' => true)
    git('add', '.')
    git('commit', '--quiet', '-m', 'Docs')
    site = File.join(@repo, 'site')
    output = build(site)

    assert_includes output, 'Building one version of the docs: there is no release tag yet.'
    refute File.exist?(File.join(site, 'next'))
    refute_includes File.read(File.join(site, 'index.html')), 'vp-version-banner'
  end

  private

  def configure_versions(versions)
    config = YAML.safe_load_file(File.join(@docs, '_config.yml'))
    config['jekyll_vitepress']['versions'] = versions
    config['jekyll_vitepress']['build'] = {
      'after_build' => 'echo "$VITEPRESS_VERSION_REF" > "$VITEPRESS_VERSION_OUTPUT/version.hook"'
    }
    File.write(File.join(@docs, '_config.yml'), YAML.dump(config))
  end

  def home(text)
    "---\nlayout: home\ntitle: Downstream Docs\npermalink: /\n---\n\n#{text}\n"
  end

  def write(path, content)
    full = File.join(@docs, path)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, content)
  end

  def release(tag)
    git('add', '.')
    git('commit', '--quiet', '-m', "Release #{tag}")
    git('tag', tag)
  end

  def build(site)
    out = StringIO.new
    Jekyll::VitePressTheme::VersionedBuild.new(
      source: @docs, destination: site, baseurl: '/manual', jekyll_args: ['--quiet'], out: out
    ).run
    out.string
  end

  def git(*args)
    output, status = Open3.capture2e(
      { 'GIT_AUTHOR_NAME' => 'Test', 'GIT_AUTHOR_EMAIL' => 'test@example.test',
        'GIT_COMMITTER_NAME' => 'Test', 'GIT_COMMITTER_EMAIL' => 'test@example.test' },
      'git', '-C', @repo, '-c', 'commit.gpgsign=false', '-c', 'tag.gpgsign=false', *args
    )
    raise "git #{args.join(' ')} failed: #{output}" unless status.success?

    output
  end
end
