require 'minitest/autorun'
require 'yaml'
require 'open3'
require 'tmpdir'

class VersionManifestTest < Minitest::Test
  SCRIPT = File.expand_path('../scripts/version_manifest.rb', __dir__)

  def run_script(*args)
    Open3.capture3(RbConfig.ruby, SCRIPT, *args)
  end

  def write_manifest(dir, manifest)
    path = File.join(dir, 'versions.yml')
    File.write(path, YAML.dump(manifest))
    path
  end

  def test_next_mode_from_scratch
    Dir.mktmpdir do |dir|
      out_path = File.join(dir, 'out', 'versions.yml')
      _, stderr, status = run_script('--mode', 'next', '--manifest-out', out_path, '--repository', 'owner/repo')

      assert status.success?, stderr
      manifest = YAML.safe_load_file(out_path, permitted_classes: [Time])

      item_ids = manifest['items'].map { |item| item['id'] }
      assert_equal 'next', manifest['current']
      assert_nil manifest['latest']
      assert_equal %w[next changelog], item_ids
      assert_equal 'https://github.com/owner/repo/releases', manifest['items'].last['url']
    end
  end

  def test_release_mode_adds_version_and_marks_latest
    Dir.mktmpdir do |dir|
      out_path = File.join(dir, 'versions.yml')
      _, stderr, status = run_script(
        '--mode', 'release', '--version', '1.2.3',
        '--base-path', '/repo', '--manifest-out', out_path, '--repository', 'owner/repo'
      )

      assert status.success?, stderr
      manifest = YAML.safe_load_file(out_path, permitted_classes: [Time])

      assert_equal 'v1.2.3', manifest['current']
      assert_equal 'v1.2.3', manifest['latest']

      release = manifest['items'].find { |item| item['id'] == 'v1.2.3' }
      assert_equal 'v1.2.3 (latest)', release['title']
      assert_equal '/repo/v/1.2.3/', release['url']
    end
  end

  def test_release_mode_sorts_versions_descending
    Dir.mktmpdir do |dir|
      in_path = write_manifest(dir, 'items' => [
                                 { 'id' => 'v1.10.0', 'url' => '/v/1.10.0/' },
                                 { 'id' => 'v1.2.0', 'url' => '/v/1.2.0/' }
                               ])
      out_path = File.join(dir, 'out.yml')
      _, stderr, status = run_script(
        '--mode', 'release', '--version', '1.9.0',
        '--manifest-in', in_path, '--manifest-out', out_path, '--repository', 'owner/repo'
      )

      assert status.success?, stderr
      manifest = YAML.safe_load_file(out_path, permitted_classes: [Time])
      release_ids = manifest['items'].map { |item| item['id'] } - %w[next changelog]

      assert_equal %w[v1.10.0 v1.9.0 v1.2.0], release_ids
      assert_equal 'v1.9.0', manifest['latest']
    end
  end

  def test_next_mode_keeps_existing_latest
    Dir.mktmpdir do |dir|
      in_path = write_manifest(dir, 'latest' => 'v2.0.0', 'items' => [
                                 { 'id' => 'v2.0.0', 'url' => '/v/2.0.0/' },
                                 { 'id' => 'v1.0.0', 'url' => '/v/1.0.0/' }
                               ])
      out_path = File.join(dir, 'out.yml')
      _, stderr, status = run_script(
        '--mode', 'next', '--manifest-in', in_path, '--manifest-out', out_path, '--repository', 'owner/repo'
      )

      assert status.success?, stderr
      manifest = YAML.safe_load_file(out_path, permitted_classes: [Time])

      assert_equal 'next', manifest['current']
      assert_equal 'v2.0.0', manifest['latest']
      assert_equal 'v2.0.0 (latest)', manifest['items'].find { |item| item['id'] == 'v2.0.0' }['title']
    end
  end

  def test_recovers_release_id_from_url_when_id_missing
    Dir.mktmpdir do |dir|
      in_path = write_manifest(dir, 'items' => [{ 'url' => '/repo/v/3.1.4/' }])
      out_path = File.join(dir, 'out.yml')
      _, stderr, status = run_script(
        '--mode', 'next', '--manifest-in', in_path, '--manifest-out', out_path, '--repository', 'owner/repo'
      )

      assert status.success?, stderr
      manifest = YAML.safe_load_file(out_path, permitted_classes: [Time])
      assert_includes manifest['items'].map { |item| item['id'] }, 'v3.1.4'
    end
  end

  def test_release_mode_requires_version
    _, stderr, status = run_script('--mode', 'release', '--manifest-out', 'out.yml', '--repository', 'owner/repo')

    refute status.success?
    assert_includes stderr, 'Missing required --version'
  end

  def test_rejects_invalid_version
    Dir.mktmpdir do |dir|
      out_path = File.join(dir, 'out.yml')
      _, stderr, status = run_script(
        '--mode', 'release', '--version', 'not-a-version',
        '--manifest-out', out_path, '--repository', 'owner/repo'
      )

      refute status.success?
      assert_includes stderr, "Invalid release version 'not-a-version'"
    end
  end

  def test_rejects_unknown_mode
    _, stderr, status = run_script('--mode', 'bogus', '--manifest-out', 'out.yml', '--repository', 'owner/repo')

    refute status.success?
    assert_includes stderr, "Invalid --mode 'bogus'"
  end
end
