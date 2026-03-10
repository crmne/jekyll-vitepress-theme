#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'optparse'
require 'time'
require 'rubygems/version'

options = {
  mode: nil,
  version: nil,
  base_path: nil,
  manifest_in: nil,
  manifest_out: nil,
  repository: nil
}

OptionParser.new do |parser|
  parser.banner = 'Usage: version_manifest.rb --mode <next|release> [options]'

  parser.on('--mode MODE', 'Mode: next or release') { |value| options[:mode] = value&.strip }
  parser.on('--version VERSION', 'Release version (required for release mode)') { |value| options[:version] = value&.strip }
  parser.on('--base-path PATH', 'Pages base path (e.g. /repo or empty)') { |value| options[:base_path] = value }
  parser.on('--manifest-in PATH', 'Input versions.yml path') { |value| options[:manifest_in] = value&.strip }
  parser.on('--manifest-out PATH', 'Output versions.yml path') { |value| options[:manifest_out] = value&.strip }
  parser.on('--repository OWNER/REPO', 'GitHub repository slug') { |value| options[:repository] = value&.strip }
end.parse!

abort('Missing required --mode') unless options[:mode]
abort("Invalid --mode '#{options[:mode]}'. Use 'next' or 'release'.") unless %w[next release].include?(options[:mode])
abort('Missing required --manifest-out') unless options[:manifest_out]
abort('Missing required --repository') unless options[:repository]

if options[:mode] == 'release' && (options[:version].nil? || options[:version].empty?)
  abort('Missing required --version for release mode')
end

def normalize_base_path(value)
  return '' if value.nil?

  trimmed = value.to_s.strip
  return '' if trimmed.empty? || trimmed == '/'

  normalized = trimmed.start_with?('/') ? trimmed : "/#{trimmed}"
  normalized.chomp('/')
end

def release_id_for(value)
  return nil if value.nil?

  raw = value.to_s.strip
  return nil if raw.empty?

  normalized = raw.start_with?('v') ? raw : "v#{raw}"
  Gem::Version.new(normalized.delete_prefix('v'))
  normalized
rescue ArgumentError
  nil
end

def release_id_from_item(item)
  return nil unless item.is_a?(Hash)

  from_id = release_id_for(item['id'] || item[:id])
  return from_id if from_id

  from_text = release_id_for(item['text'] || item[:text])
  return from_text if from_text

  link = item['link'] || item[:link]
  return nil unless link

  match = link.to_s.match(%r{/v/(\d+\.\d+\.\d+[A-Za-z0-9.-]*)/?})
  return nil unless match

  release_id_for(match[1])
end

base_path = normalize_base_path(options[:base_path])
manifest_in_path = options[:manifest_in]

manifest_in = {}
if manifest_in_path && !manifest_in_path.empty? && File.exist?(manifest_in_path)
  loaded = YAML.safe_load_file(manifest_in_path, permitted_classes: [Time], aliases: true)
  manifest_in = loaded if loaded.is_a?(Hash)
end

existing_items = manifest_in['items'].is_a?(Array) ? manifest_in['items'] : []
release_ids = existing_items.filter_map { |item| release_id_from_item(item) }.uniq

if options[:mode] == 'release'
  release_id = release_id_for(options[:version])
  abort("Invalid release version '#{options[:version]}'") unless release_id
  release_ids |= [release_id]
end

release_ids = release_ids.sort_by { |value| Gem::Version.new(value.delete_prefix('v')) }.reverse

latest_id = release_id_for(manifest_in['latest'])
latest_id = release_ids.first if latest_id.nil? && !release_ids.empty?
latest_id = release_id_for(options[:version]) if options[:mode] == 'release'

current_id = options[:mode] == 'release' ? release_id_for(options[:version]) : 'next'

items = []
items << {
  'id' => 'next',
  'text' => 'next (unreleased)',
  'link' => "#{base_path}/next/"
}

release_ids.each do |rid|
  text = rid == latest_id ? "#{rid} (latest)" : rid
  items << {
    'id' => rid,
    'text' => text,
    'link' => "#{base_path}/v/#{rid.delete_prefix('v')}/"
  }
end

items << {
  'id' => 'changelog',
  'text' => 'Changelog',
  'link' => "https://github.com/#{options[:repository]}/releases",
  'external' => true
}

manifest_out = {
  'current' => current_id,
  'latest' => latest_id,
  'items' => items,
  'updated_at' => Time.now.utc.iso8601
}

dirname = File.dirname(options[:manifest_out])
Dir.mkdir(dirname) unless dirname == '.' || Dir.exist?(dirname)
File.write(options[:manifest_out], YAML.dump(manifest_out))
