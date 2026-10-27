# frozen_string_literal: true

require 'open3'
require 'pathname'

module Jekyll
  module VitePressTheme
    # Dates each page by the last commit that touched its source file, read
    # from one `git log` pass per build. Files Git cannot date reliably
    # (untracked, locally modified, outside the repository, or older than a
    # shallow clone's history) use their modification time instead.
    module LastUpdated
      module_function

      FIELD_SEPARATOR = "\x1e"

      # Git's view of the files under a site source: commit times keyed by
      # real path, plus the paths whose working copy differs from HEAD.
      class GitIndex
        def self.empty
          new({}, [])
        end

        def initialize(times, modified)
          @times = times
          @modified = modified.to_h { |path| [path, true] }
        end

        def time_for(path)
          return nil if @modified.key?(path)

          @times[path]
        end
      end

      def source_file_time(site, path)
        source_path = resolved_source_path(site, path)
        return nil unless source_path

        git_index(site).time_for(source_path) || File.mtime(source_path).utc
      end

      # The last commit date alone, or nil where Git cannot date the file.
      # For uses such as the sitemap, where a build-time file timestamp
      # would claim a change that never happened.
      def commit_time(site, path)
        source_path = resolved_source_path(site, path)
        source_path && git_index(site).time_for(source_path)
      end

      def resolved_source_path(site, path)
        return nil unless path

        source_path = Pathname.new(path).absolute? ? path : File.join(site.source, path)
        return nil unless File.file?(source_path)

        File.realpath(source_path)
      end

      def git_index(site)
        @git_indexes ||= {}
        @git_indexes[site] ||= build_git_index(site.source)
      end

      def reset(site)
        @git_indexes&.delete(site)
      end

      def build_git_index(source)
        source = File.realpath(source)
        root = repository_root(source)
        return GitIndex.empty unless root

        pathspec = relative_pathspec(source, root)
        boundaries = shallow_boundaries(root)
        warn_shallow if boundaries.any?

        GitIndex.new(commit_times(root, pathspec, boundaries), modified_paths(root, pathspec))
      rescue SystemCallError, ArgumentError => e
        Jekyll.logger.debug('jekyll-vitepress-theme', "Git dates unavailable: #{e.message}")
        GitIndex.empty
      end

      def repository_root(source)
        root = git(source, 'rev-parse', '--show-toplevel').to_s.strip
        root.empty? ? nil : File.realpath(root)
      end

      def relative_pathspec(source, root)
        Pathname.new(source).relative_path_from(Pathname.new(root)).to_s
      end

      def commit_times(root, pathspec, boundaries)
        log = git(root, 'log', '--no-renames', "--format=#{FIELD_SEPARATOR}%H %ct", '--name-only', '-z', '--', pathspec)
        return {} unless log

        log.split(FIELD_SEPARATOR).each_with_object({}) do |entry, times|
          sha, time, files = parse_log_entry(entry)
          next if files.empty? || boundaries.include?(sha)

          files.each do |file|
            path = File.join(root, file)
            times[path] = time if times[path].nil? || time > times[path]
          end
        end
      end

      def parse_log_entry(entry)
        header, files = entry.split("\0", 2)
        sha, timestamp = header.to_s.split
        return [sha, nil, []] if files.nil?

        [sha, Time.at(Integer(timestamp)).utc, files.delete_prefix("\n").split("\0").reject(&:empty?)]
      end

      def modified_paths(root, pathspec)
        status = git(root, 'status', '--porcelain=v1', '-z', '--untracked-files=no', '--', pathspec)
        return [] unless status

        entries = status.split("\0")
        paths = []
        until entries.empty?
          entry = entries.shift
          paths << File.join(root, entry[3..])
          entries.shift if entry.start_with?('R', 'C')
        end
        paths
      end

      def shallow_boundaries(root)
        return [] unless git(root, 'rev-parse', '--is-shallow-repository')&.strip == 'true'

        shallow_file = git(root, 'rev-parse', '--git-path', 'shallow')&.strip
        return [] unless shallow_file

        shallow_file = File.expand_path(shallow_file, root)
        return [] unless File.file?(shallow_file)

        File.read(shallow_file).split
      end

      def warn_shallow
        Jekyll.logger.warn(
          'jekyll-vitepress-theme',
          'Shallow Git clone: pages last changed before the clone\'s history use their file ' \
          'modification time for "Last updated". Fetch the full history (fetch-depth: 0) for accurate dates.'
        )
      end

      def git(directory, *args)
        output, status = Open3.capture2('git', '-C', directory, *args, err: File::NULL)
        status.success? ? output : nil
      rescue SystemCallError
        nil
      end
    end
  end
end

Jekyll::Hooks.register :site, :after_reset do |site|
  Jekyll::VitePressTheme::LastUpdated.reset(site)
end
