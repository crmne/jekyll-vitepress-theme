# frozen_string_literal: true

require 'cgi'
require 'date'
require 'fileutils'
require 'json'
require 'open3'
require 'rubygems/version'
require 'tmpdir'
require 'yaml'

module Jekyll
  module VitePressTheme
    # Builds a docs site, and when `jekyll_vitepress.versions` is configured,
    # every version of it that stays online:
    #
    # * stable: the newest release tag, at the site root
    # * next: the checkout being built (the default branch in CI), at /next/
    # * older major lines listed under `keep`, such as the newest 1.x at /v1/
    #
    # Each release is checked out in a Git worktree and built with the current
    # docs Gemfile, so theme fixes reach older versions too. Each build runs in
    # its own Jekyll process, so one version's plugins never load into another.
    # The builds are then assembled into one site.
    #
    # Without a `versions` block it runs one ordinary build, so every project
    # can publish with the same command.
    # rubocop:disable-next Metrics/AbcSize, Metrics/ClassLength
    class VersionedBuild
      class Error < StandardError; end

      Version = Struct.new(
        :id, :kind, :tag, :title, :label, :path, :redirect_missing, :overlay,
        :source, :root, :output,
        keyword_init: true
      )

      CONFIG_FILES = %w[_config.yml _config.yaml _config.toml].freeze

      def initialize(source: '.', destination: nil, baseurl: '', jekyll_args: [], out: $stdout)
        @docs = File.expand_path(source)
        @destination = File.expand_path(destination || File.join(@docs, '_site'))
        @baseurl = normalize_baseurl(baseurl)
        @jekyll_args = jekyll_args
        @out = out
      end

      def run
        versions = planned_versions
        versions ? build_versions(versions) : build_single
      end

      # Builds every version, serves the site, and rebuilds the checkout's
      # version whenever a file changes, the way `jekyll serve` does for a
      # single site. Build hooks run once, in the first build.
      def serve(host: '127.0.0.1', port: 4000)
        versions = planned_versions
        return serve_single(host, port) unless versions

        Dir.mktmpdir('jekyll-vitepress-') do |work|
          build_versions(versions, work)
          checkout = versions.find { |version| version.tag.nil? }
          watcher = checkout && watch(checkout, work)
          begin
            serve_directory(host, port)
          ensure
            stop(watcher)
          end
        end
      end

      private

      attr_reader :docs, :destination, :baseurl, :hooks

      # -- Planning -------------------------------------------------------

      def plan(settings)
        @root = git(docs, 'rev-parse', '--show-toplevel', allow_failure: true)&.strip
        return warn_single('the docs are not in a Git checkout') unless @root && !@root.empty?

        @docs_path = relative_docs_path
        releases = release_tags(settings['tag_prefix'])
        stable = releases.last
        return warn_single('there is no release tag yet') unless stable
        return warn_single("#{stable[:tag]} has no docs at #{display_docs_path}") unless docs_at?(stable[:tag])

        versions = [stable_version(stable, hash_setting(settings['stable']))]
        versions << next_version(hash_setting(settings['next'])) unless settings['next'] == false
        versions.concat(kept_versions(settings, releases, stable))
        versions.each { |version| version.overlay = Array(settings['overlay']) + Array(version.overlay) }
        versions
      end

      def stable_version(release, options)
        Version.new(
          id: options['id'] || 'stable', kind: 'stable', tag: release[:tag],
          title: title_for(options['title'], release[:version], "#{release[:version]} (stable)"),
          label: nil, path: '/'
        )
      end

      def next_version(options)
        Version.new(
          id: options['id'] || 'next', kind: 'next', tag: nil,
          title: options['title'] || 'Next (unreleased)', label: options.fetch('label', 'Next'),
          path: normalize_path(options['path'] || '/next/')
        )
      end

      def kept_versions(settings, releases, stable)
        Array(settings['keep']).filter_map do |entry|
          entry = hash_setting(entry)
          major = Integer(entry.fetch('major') { raise Error, 'Each entry under versions.keep needs a `major`' })
          release = releases.reverse.find { |candidate| candidate[:segments].first == major }
          next say("No #{major}.x release tag, so there is no #{major}.x version to keep") unless release
          next if release[:tag] == stable[:tag]
          next say("#{release[:tag]} has no docs at #{display_docs_path}, so it is skipped") unless docs_at?(release[:tag])

          id = entry['id'] || "v#{major}"
          Version.new(
            id: id, kind: 'older', tag: release[:tag],
            title: title_for(entry['title'], release[:version], release[:version]),
            label: entry.fetch('label', id), path: normalize_path(entry['path'] || "/#{id}/"),
            redirect_missing: entry['redirect_missing'] == true, overlay: entry['overlay']
          )
        end
      end

      def release_tags(prefix)
        prefix = prefix.nil? ? 'v?' : Regexp.escape(prefix.to_s)
        pattern = /\A#{prefix}(\d+\.\d+\.\d+)\z/
        releases = git(@root, 'tag', '--list').lines.map(&:strip).filter_map do |tag|
          match = pattern.match(tag)
          next unless match

          version = Gem::Version.new(match[1])
          { tag: tag, version: match[1], gem_version: version, segments: version.segments }
        end
        releases.sort_by { |release| release[:gem_version] }
      end

      def docs_at?(tag)
        CONFIG_FILES.any? do |name|
          path = @docs_path.empty? ? name : File.join(@docs_path, name)
          git(@root, 'cat-file', '-e', "#{tag}:#{path}", allow_failure: true)
        end
      end

      # -- Building -------------------------------------------------------

      def build_single
        version = Version.new(id: 'current', kind: 'current', source: docs, root: docs, output: destination)
        run_hook('before_build', version)
        jekyll_build(docs, destination, baseurl, config_files(docs))
        run_hook('after_build', version)
        run_hook('after_assemble', version)
      end

      def planned_versions
        config = site_config
        settings = config.dig('jekyll_vitepress', 'versions')
        @hooks = build_hooks(config)
        @site_url = config['url'].to_s.strip.sub(%r{/+\z}, '')
        settings.is_a?(Hash) ? plan(settings) : nil
      end

      def build_versions(versions, work = nil)
        return Dir.mktmpdir('jekyll-vitepress-') { |dir| build_versions(versions, dir) } unless work

        begin
          versions.each do |version|
            prepare_source(version, work)
            build_version(version, versions, work)
          end
          assemble(versions)
        ensure
          versions.each { |version| remove_worktree(version) }
        end
        summary = versions.map { |version| "#{version.path} = #{version.tag || 'this checkout'}" }.join(', ')
        say("Built #{summary} into #{destination}")
      end

      def prepare_source(version, work)
        version.output = File.join(work, 'out', version.id)
        unless version.tag
          version.root = @root
          version.source = docs
          return
        end

        version.root = File.join(work, 'src', version.id)
        FileUtils.mkdir_p(File.dirname(version.root))
        git(@root, '-c', 'core.hooksPath=/dev/null', 'worktree', 'add', '--quiet', '--detach', version.root, version.tag)
        version.source = @docs_path.empty? ? version.root : File.join(version.root, @docs_path)
        copy_overlay(version)
      end

      def copy_overlay(version)
        version.overlay.each do |path|
          from = File.join(docs, path)
          raise Error, "versions.overlay lists #{path}, which is not in #{docs}" unless File.exist?(from)

          to = File.join(version.source, path)
          FileUtils.rm_rf(to)
          FileUtils.mkdir_p(File.dirname(to))
          FileUtils.cp_r(from, to)
        end
      end

      def build_version(version, versions, work)
        say("Building #{version.title} (#{version.tag || 'this checkout'}) at #{version.path}")
        extra = File.join(work, "#{version.id}.yml")
        File.write(extra, YAML.dump(Versions::CONFIG_KEY => version_data(version, versions)))
        run_hook('before_build', version)
        jekyll_build(version.source, version.output, version_baseurl(version), config_files(version.source) + [extra])
        run_hook('after_build', version)
      end

      def version_data(version, versions)
        stable = versions.first
        {
          'id' => version.id, 'kind' => version.kind, 'title' => version.title, 'label' => version.label,
          'ref' => version.tag || 'HEAD', 'branch' => branch_name, 'path' => version.path,
          'root_baseurl' => baseurl,
          'stable' => { 'title' => stable.title, 'url' => version_url(stable) },
          'items' => versions.map { |item| { 'id' => item.id, 'title' => item.title, 'url' => version_url(item) } } +
            external_items
        }
      end

      # Links such as a changelog, kept from the project's _data/versions.yml.
      def external_items
        path = File.join(docs, '_data', 'versions.yml')
        return [] unless File.file?(path)

        data = YAML.safe_load_file(path, permitted_classes: [Date, Time]) || {}
        Array(data['items']).select { |item| item.is_a?(Hash) && (item['external'] || item['url'].to_s.include?('://')) }
      end

      def jekyll_build(source, output, build_baseurl, configs)
        command = ['bundle', 'exec', 'jekyll', 'build', '--source', source, '--destination', output,
                   '--baseurl', build_baseurl, '--config', configs.join(','), *@jekyll_args]
        run!(command, chdir: source, env: { 'BUNDLE_GEMFILE' => gemfile })
      end

      # -- Assembling -----------------------------------------------------

      def assemble(versions)
        guard_destination!
        FileUtils.rm_rf(destination)
        FileUtils.mkdir_p(destination)
        stable, *others = versions
        FileUtils.cp_r(File.join(stable.output, '.'), destination)
        others.each do |version|
          target = File.join(destination, version.path)
          FileUtils.rm_rf(target)
          FileUtils.mkdir_p(target)
          FileUtils.cp_r(File.join(version.output, '.'), target)
        end
        others.select(&:redirect_missing).each { |version| write_redirects(version) }
        list_sitemaps(others)
        run_hook('after_assemble', stable)
      end

      # Old URLs that only exist in a kept version, such as pages removed
      # since 1.x, redirect into that version instead of returning 404.
      def write_redirects(version)
        Dir.glob('**/*.html', base: version.output).each do |relative|
          next if relative == '404.html' || File.exist?(File.join(destination, relative))

          route = relative.delete_suffix('index.html')
          target = "#{baseurl}#{version.path}#{route}"
          path = File.join(destination, relative)
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, redirect_html(target))
        end
      end

      def redirect_html(target)
        escaped = CGI.escapeHTML(target)
        canonical = @site_url.empty? ? '' : %(\n  <link rel="canonical" href="#{CGI.escapeHTML(@site_url)}#{escaped}">)
        <<~HTML
          <!doctype html>
          <html lang="en">
          <head>
            <meta charset="utf-8">
            <title>Redirecting…</title>#{canonical}
            <meta name="robots" content="noindex,follow">
            <script>window.location.replace(#{JSON.generate(target)} + window.location.search + window.location.hash);</script>
            <meta http-equiv="refresh" content="0;url=#{escaped}">
          </head>
          <body><p>This page has moved to <a href="#{escaped}">#{escaped}</a>.</p></body>
          </html>
        HTML
      end

      # Search engines find the stable sitemap through robots.txt; the other
      # versions' sitemaps are listed beside it when they list any page, which
      # they only do when `seo.index_versions` lets those versions be indexed.
      def list_sitemaps(versions)
        robots = File.join(destination, 'robots.txt')
        return unless File.file?(robots) && File.read(robots).match?(/^Sitemap:/)

        lines = versions.filter_map do |version|
          sitemap = File.join(version.output, 'sitemap.xml')
          next unless File.file?(sitemap) && File.read(sitemap).include?('<loc>')

          "Sitemap: #{@site_url}#{baseurl}#{version.path}sitemap.xml"
        end
        File.open(robots, 'a') { |file| lines.each { |line| file.puts(line) } } unless lines.empty?
      end

      def guard_destination!
        protected = [docs, @root, Dir.home, '/'].compact.map { |path| File.expand_path(path) }
        return unless protected.include?(destination)

        raise Error, "Refusing to replace #{destination} with the built site; pass a separate --destination"
      end

      # -- Serving --------------------------------------------------------

      def serve_single(host, port)
        command = ['bundle', 'exec', 'jekyll', 'serve', '--source', docs, '--destination', destination,
                   '--baseurl', baseurl, '--host', host, '--port', port.to_s, *@jekyll_args]
        run!(command, chdir: docs, env: { 'BUNDLE_GEMFILE' => gemfile })
      end

      def watch(version, work)
        output = File.join(destination, version.path)
        configs = config_files(docs) + [File.join(work, "#{version.id}.yml")]
        command = ['bundle', 'exec', 'jekyll', 'build', '--watch', '--source', docs, '--destination', output,
                   '--baseurl', version_baseurl(version), '--config', configs.join(','), *@jekyll_args]
        say("Rebuilding #{version.path} when #{docs} changes")
        Process.spawn({ 'BUNDLE_GEMFILE' => gemfile }, *command, chdir: docs)
      end

      def serve_directory(host, port)
        require 'webrick'
        server = WEBrick::HTTPServer.new(BindAddress: host, Port: port, AccessLog: [],
                                         Logger: WEBrick::Log.new(File::NULL))
        server.mount(baseurl.empty? ? '/' : baseurl, WEBrick::HTTPServlet::FileHandler, destination)
        %w[INT TERM].each { |signal| trap(signal) { server.shutdown } }
        say("Serving http://#{host}:#{port}#{baseurl}/")
        server.start
      end

      def stop(pid)
        return unless pid

        Process.kill('TERM', pid)
        Process.wait(pid)
      rescue Errno::ESRCH, Errno::ECHILD
        nil
      end

      # -- Hooks ----------------------------------------------------------

      def build_hooks(config)
        value = config.dig('jekyll_vitepress', 'build')
        value.is_a?(Hash) ? value : {}
      end

      def run_hook(name, version)
        Array(hooks[name]).each do |command|
          say("Running #{name} for #{version.id}: #{command}")
          # Hooks get the environment from before `bundle exec`, so a hook
          # can run the repository's own bundle without inheriting the docs one.
          with_original_env { run!(['sh', '-c', command.to_s], chdir: docs, env: hook_env(version)) }
        end
      end

      def hook_env(version)
        {
          'VITEPRESS_DOCS' => docs,
          'VITEPRESS_SITE' => destination,
          'VITEPRESS_VERSION_ID' => version.id,
          'VITEPRESS_VERSION_KIND' => version.kind,
          'VITEPRESS_VERSION_REF' => version.tag || 'HEAD',
          'VITEPRESS_VERSION_SOURCE' => version.source,
          'VITEPRESS_VERSION_ROOT' => version.root,
          'VITEPRESS_VERSION_OUTPUT' => version.output,
          'VITEPRESS_VERSION_BASEURL' => version.path ? version_baseurl(version) : baseurl,
          'VITEPRESS_VERSION_URL' => version.path ? "#{@site_url}#{version_url(version)}" : "#{@site_url}#{baseurl}/"
        }.transform_values(&:to_s)
      end

      # -- Helpers --------------------------------------------------------

      def site_config
        path = CONFIG_FILES.map { |name| File.join(docs, name) }.find { |candidate| File.file?(candidate) }
        raise Error, "No _config.yml in #{docs}" unless path
        return {} if path.end_with?('.toml')

        YAML.safe_load_file(path, permitted_classes: [Date, Time], aliases: true) || {}
      end

      def config_files(source)
        CONFIG_FILES.map { |name| File.join(source, name) }.select { |path| File.file?(path) }
      end

      def gemfile
        ENV['BUNDLE_GEMFILE'] || File.join(docs, 'Gemfile')
      end

      def with_original_env(&)
        defined?(Bundler) ? Bundler.with_original_env(&) : yield
      end

      def remove_worktree(version)
        return unless version.tag && version.root && File.directory?(version.root)

        git(@root, 'worktree', 'remove', '--force', version.root, allow_failure: true)
      end

      def relative_docs_path
        real_root = File.realpath(@root)
        real_docs = File.realpath(docs)
        real_docs == real_root ? '' : real_docs.delete_prefix("#{real_root}/")
      end

      def display_docs_path
        @docs_path.empty? ? 'the repository root' : @docs_path
      end

      def branch_name
        @branch_name ||= begin
          name = git(@root, 'rev-parse', '--abbrev-ref', 'HEAD', allow_failure: true).to_s.strip
          name = ENV['GITHUB_REF_NAME'].to_s if (name.empty? || name == 'HEAD') && ENV['GITHUB_REF_TYPE'] == 'branch'
          name.empty? || name == 'HEAD' ? 'main' : name
        end
      end

      def version_baseurl(version)
        "#{baseurl}#{version.path.chomp('/')}"
      end

      def version_url(version)
        "#{baseurl}#{version.path}"
      end

      def title_for(template, version, default)
        template ? template.to_s.gsub(':version', version) : default
      end

      def hash_setting(value)
        value.is_a?(Hash) ? value : {}
      end

      def normalize_path(value)
        path = "/#{value.to_s.strip.delete_prefix('/')}"
        path.end_with?('/') ? path : "#{path}/"
      end

      def normalize_baseurl(value)
        value = value.to_s.strip
        return '' if value.empty? || value == '/'

        "/#{value.delete_prefix('/')}".sub(%r{/+\z}, '')
      end

      def warn_single(reason)
        say("Building one version of the docs: #{reason}.")
        nil
      end

      def say(message)
        @out.puts("jekyll-vitepress: #{message}")
        nil
      end

      def git(dir, *args, allow_failure: false)
        output, status = Open3.capture2e('git', '-C', dir, *args)
        return output if status.success?
        return nil if allow_failure

        raise Error, "git #{args.join(' ')} failed:\n#{output}"
      end

      def run!(command, chdir:, env: {})
        success = system(env, *command, chdir: chdir)
        raise Error, "#{command.first(4).join(' ')} … failed" unless success
      end
    end
  end
end
