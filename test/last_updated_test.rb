# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'stringio'
require 'tmpdir'
require_relative 'test_helper'

class LastUpdatedTest < Minitest::Test
  FakeSite = Struct.new(:source)
  FIXTURE = File.expand_path('fixtures/seo_site', __dir__)

  FIRST = Time.utc(2024, 1, 15, 9, 30, 0)
  SECOND = Time.utc(2024, 6, 1, 12, 0, 0)
  THIRD = Time.utc(2025, 3, 20, 18, 45, 0)
  MTIME = Time.utc(2026, 10, 1, 8, 0, 0)

  PINNED_PAGE = <<~MARKDOWN
    ---
    title: Pinned
    permalink: /pinned/
    jekyll_vitepress:
      last_updated_at: 2020-02-03 04:05:06 +0000
    ---

    Pinned.
  MARKDOWN

  GIT_ENV = {
    'GIT_CONFIG_GLOBAL' => File::NULL,
    'GIT_CONFIG_NOSYSTEM' => '1',
    'GIT_AUTHOR_NAME' => 'Test',
    'GIT_AUTHOR_EMAIL' => 'test@example.test',
    'GIT_COMMITTER_NAME' => 'Test',
    'GIT_COMMITTER_EMAIL' => 'test@example.test'
  }.freeze

  def test_tracked_file_uses_last_commit_date
    in_repo do |repo|
      commit(repo, FIRST, 'a.md' => 'one', 'b.md' => 'one')
      commit(repo, SECOND, 'b.md' => 'second')

      site = FakeSite.new(repo)
      assert_equal FIRST, time_for(site, 'a.md')
      assert_equal SECOND, time_for(site, 'b.md')
    end
  end

  def test_renamed_file_uses_the_rename_commit
    in_repo do |repo|
      commit(repo, FIRST, 'old.md' => 'content')
      git(repo, 'mv', 'old.md', 'new.md')
      git(repo, 'commit', '-q', '-m', 'Rename', date: SECOND)

      assert_equal SECOND, time_for(FakeSite.new(repo), 'new.md')
    end
  end

  def test_untracked_file_uses_mtime
    in_repo do |repo|
      commit(repo, FIRST, 'a.md' => 'one')
      write(repo, 'draft.md', 'draft')

      assert_equal MTIME, time_for(FakeSite.new(repo), 'draft.md')
    end
  end

  def test_modified_file_uses_mtime
    in_repo do |repo|
      commit(repo, FIRST, 'a.md' => 'one', 'b.md' => 'one', 'c.md' => 'one')
      write(repo, 'a.md', 'edited')
      write(repo, 'b.md', 'staged')
      git(repo, 'add', 'b.md')
      git(repo, 'mv', 'c.md', 'd.md')

      site = FakeSite.new(repo)
      assert_equal MTIME, time_for(site, 'a.md')
      assert_equal MTIME, time_for(site, 'b.md')
      assert_equal MTIME, time_for(site, 'd.md')
    end
  end

  def test_site_in_repository_subdirectory
    in_repo do |repo|
      commit(repo, FIRST, 'docs/guide.md' => 'guide', 'README.md' => 'readme')
      commit(repo, SECOND, 'README.md' => 'changed')

      assert_equal FIRST, time_for(FakeSite.new(File.join(repo, 'docs')), 'guide.md')
    end
  end

  def test_shallow_clone_keeps_dates_inside_its_history
    Dir.mktmpdir('jekyll-vp-origin') do |origin|
      init(origin)
      commit(origin, FIRST, 'a.md' => 'one')
      commit(origin, SECOND, 'b.md' => 'one')
      commit(origin, THIRD, 'b.md' => 'third')

      Dir.mktmpdir('jekyll-vp-clone') do |parent|
        clone = File.join(parent, 'clone')
        git(parent, 'clone', '-q', '--depth', '2', "file://#{origin}", clone)
        touch(clone, 'a.md')
        touch(clone, 'b.md')

        site = FakeSite.new(clone)
        output = capture_jekyll_log { assert_equal MTIME, time_for(site, 'a.md') }
        assert_equal THIRD, time_for(site, 'b.md')
        assert_includes output, 'fetch-depth: 0'
      end
    end
  end

  def test_without_git_repository_uses_mtime
    Dir.mktmpdir('jekyll-vp-plain') do |dir|
      write(dir, 'a.md', 'one')

      assert_equal MTIME, time_for(FakeSite.new(dir), 'a.md')
    end
  end

  def test_missing_file_has_no_time
    Dir.mktmpdir('jekyll-vp-plain') do |dir|
      assert_nil Jekyll::VitePressTheme::LastUpdated.source_file_time(FakeSite.new(dir), 'missing.md')
    end
  end

  def test_built_site_dates_pages_from_git_and_honors_front_matter
    in_repo do |repo|
      docs = File.join(repo, 'docs')
      FileUtils.cp_r(FIXTURE, docs)
      FileUtils.rm_rf(File.join(docs, '.jekyll-cache'))
      write(repo, 'docs/pinned.md', PINNED_PAGE)
      git(repo, 'add', '.')
      git(repo, 'commit', '-q', '-m', 'Docs', date: FIRST)
      write(repo, 'docs/guide.md', "#{File.read(File.join(docs, 'guide.md'))}\nMore.\n")
      git(repo, 'commit', '-q', '-am', 'Guide', date: SECOND)
      write(repo, 'docs/draft.md', "---\ntitle: Draft\npermalink: /draft/\n---\n\nDraft.\n")

      build(docs) do |destination|
        assert_equal FIRST, last_updated(destination, 'private/index.html')
        assert_equal SECOND, last_updated(destination, 'guide/index.html')
        assert_equal Time.utc(2020, 2, 3, 4, 5, 6), last_updated(destination, 'pinned/index.html')

        sitemap = File.read(File.join(destination, 'sitemap.xml'))
        assert_sitemap_lastmod sitemap, 'guide/', SECOND.xmlschema
        assert_sitemap_lastmod sitemap, 'pinned/', '2020-02-03T04:05:06+00:00'
        assert_includes sitemap, '/draft/</loc>'
        assert_sitemap_lastmod sitemap, 'draft/', nil
      end
    end
  end

  private

  def assert_sitemap_lastmod(sitemap, path, expected)
    entry = sitemap[%r{<loc>[^<]*/#{Regexp.escape(path)}</loc>\s*<lastmod>([^<]+)</lastmod>}, 1]
    if expected.nil?
      assert_nil entry, "sitemap lastmod for /#{path}"
    else
      assert_equal expected, entry, "sitemap lastmod for /#{path}"
    end
  end

  def time_for(site, path)
    Jekyll::VitePressTheme::LastUpdated.source_file_time(site, path)
  end

  def in_repo
    Dir.mktmpdir('jekyll-vp-repo') do |repo|
      init(repo)
      yield repo
    end
  end

  def init(repo)
    git(repo, 'init', '-q', '-b', 'main')
  end

  def commit(repo, time, files)
    files.each { |path, content| write(repo, path, content) }
    git(repo, 'add', '.')
    git(repo, 'commit', '-q', '-m', "Commit at #{time.iso8601}", date: time)
  end

  def write(repo, path, content)
    full_path = File.join(repo, path)
    FileUtils.mkdir_p(File.dirname(full_path))
    File.write(full_path, content)
    File.utime(MTIME, MTIME, full_path)
  end

  def touch(repo, path)
    full_path = File.join(repo, path)
    File.utime(MTIME, MTIME, full_path)
  end

  def git(dir, *args, date: nil)
    env = GIT_ENV.dup
    env['GIT_AUTHOR_DATE'] = env['GIT_COMMITTER_DATE'] = date.iso8601 if date
    output, status = Open3.capture2e(env, 'git', '-C', dir, *args)
    assert status.success?, "git #{args.join(' ')} failed: #{output}"
    output
  end

  def capture_jekyll_log
    level = Jekyll.logger.level
    stderr = $stderr
    Jekyll.logger.log_level = :warn
    $stderr = StringIO.new
    start = Jekyll.logger.messages.length
    yield
    Jekyll.logger.messages.drop(start).join("\n")
  ensure
    $stderr = stderr
    Jekyll.logger.log_level = level
  end

  def build(source)
    Dir.mktmpdir('jekyll-vp-build') do |destination|
      config = Jekyll.configuration(
        'config' => File.join(source, '_config.yml'),
        'source' => source,
        'destination' => destination,
        'quiet' => true,
        'disable_disk_cache' => true
      )
      Jekyll::Site.new(config).process
      yield destination
    end
  end

  def last_updated(destination, path)
    html = File.read(File.join(destination, path))
    datetime = html[/class="VPLastUpdated">[^<]*<time datetime="([^"]+)"/, 1]
    refute_nil datetime, "#{path} has no last-updated time"
    Time.iso8601(datetime).utc
  end
end
