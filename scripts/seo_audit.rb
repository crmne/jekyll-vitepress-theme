# frozen_string_literal: true

require 'cgi'
require 'json'
require 'pathname'
require 'uri'

site_dir = Pathname(ARGV.fetch(0, '_site')).expand_path
abort "SEO audit failed: site directory not found (#{site_dir})" unless site_dir.directory?

errors = []
records = []

# rubocop:disable Metrics/BlockLength
site_dir.glob('**/*.html').sort.each do |path|
  html = path.read
  next if html.match?(/<meta[^>]+http-equiv=["']refresh["']/i)

  relative_path = path.relative_path_from(site_dir).to_s
  head = html[%r{<head\b[^>]*>(.*?)</head>}mi, 1]
  unless head
    errors << "#{relative_path}: missing <head>"
    next
  end

  title = head[%r{<title>(.*?)</title>}mi, 1]
  description = head[/<meta\s+name="description"\s+content="([^"]*)"/i, 1]
  robots = head[/<meta\s+name="robots"\s+content="([^"]*)"/i, 1]
  canonical = head[/<link\s+rel="canonical"\s+href="([^"]*)"/i, 1]
  json_scripts = head.scan(%r{<script\s+type="application/ld\+json">(.*?)</script>}mi).flatten

  {
    '<title>' => title,
    'description' => description,
    'robots' => robots,
    'canonical' => canonical,
    'og:title' => head[/<meta\s+property="og:title"/i],
    'og:description' => head[/<meta\s+property="og:description"/i],
    'og:url' => head[/<meta\s+property="og:url"/i],
    'og:image' => head[/<meta\s+property="og:image"/i],
    'twitter:card' => head[/<meta\s+name="twitter:card"/i]
  }.each do |label, value|
    errors << "#{relative_path}: missing #{label}" if value.to_s.empty?
  end

  canonical_count = head.scan('rel="canonical"').length
  errors << "#{relative_path}: expected one canonical, found #{canonical_count}" unless canonical_count == 1
  errors << "#{relative_path}: expected one JSON-LD script, found #{json_scripts.length}" unless json_scripts.length == 1

  if canonical
    begin
      uri = URI.parse(CGI.unescapeHTML(canonical))
      errors << "#{relative_path}: canonical must be absolute" unless uri.is_a?(URI::HTTP) && uri.host
      errors << "#{relative_path}: canonical must not contain a fragment" if uri.fragment
    rescue URI::InvalidURIError
      errors << "#{relative_path}: invalid canonical URL"
    end
  end

  if json_scripts.one?
    begin
      graph = JSON.parse(json_scripts.first).fetch('@graph')
      errors << "#{relative_path}: JSON-LD WebSite node missing" unless graph.any? { |node| node['@type'] == 'WebSite' }
      errors << "#{relative_path}: JSON-LD WebPage node missing" unless graph.any? { |node| node['@type'] == 'WebPage' }
    rescue JSON::ParserError, KeyError, TypeError => e
      errors << "#{relative_path}: invalid JSON-LD (#{e.message})"
    end
  end

  records << {
    path: relative_path,
    title: CGI.unescapeHTML(title.to_s.gsub(/<[^>]*>/, '')).strip,
    description: CGI.unescapeHTML(description.to_s).strip,
    canonical: CGI.unescapeHTML(canonical.to_s),
    noindex: robots.to_s.downcase.split(',').map(&:strip).intersect?(%w[noindex none])
  }
end
# rubocop:enable Metrics/BlockLength

%i[title description canonical].each do |field|
  records.group_by { |record| record[field] }.each do |value, matches|
    next if value.empty? || matches.one?

    errors << "duplicate #{field} '#{value}': #{matches.map { |record| record[:path] }.join(', ')}"
  end
end

sitemap_path = site_dir.join('sitemap.xml')
robots_path = site_dir.join('robots.txt')
llms_path = site_dir.join('llms.txt')
llms_full_path = site_dir.join('llms-full.txt')
errors << 'sitemap.xml is missing' unless sitemap_path.file?
errors << 'robots.txt is missing' unless robots_path.file?
errors << 'llms.txt is missing' unless llms_path.file?
errors << 'llms-full.txt is missing' unless llms_full_path.file?

if sitemap_path.file?
  sitemap_urls = sitemap_path.read.scan(%r{<loc>(.*?)</loc>}m).flatten.map { |url| CGI.unescapeHTML(url.strip) }
  errors << 'sitemap.xml contains duplicate URLs' unless sitemap_urls.uniq.length == sitemap_urls.length

  indexable_urls = records.reject { |record| record[:noindex] }.map { |record| record[:canonical] }
  missing_urls = indexable_urls - sitemap_urls
  extra_urls = sitemap_urls - indexable_urls
  errors << "sitemap.xml is missing: #{missing_urls.join(', ')}" unless missing_urls.empty?
  errors << "sitemap.xml has non-canonical/unknown URLs: #{extra_urls.join(', ')}" unless extra_urls.empty?
end

if robots_path.file?
  robots = robots_path.read
  errors << 'robots.txt does not exclude generated Markdown duplicates' unless robots.include?('Disallow: /*.md$')
  errors << 'robots.txt has no sitemap declaration' unless robots.match?(%r{^Sitemap:\s+https?://})
end

indexable_urls = records.reject { |record| record[:noindex] }.map { |record| record[:canonical] }

if llms_path.file?
  llms = llms_path.read
  errors << 'llms.txt must start with an H1' unless llms.match?(/\A#\s+\S/)
  llms_urls = llms.scan(%r{^- \[[^\]]+\]\((https?://[^)]+)\)}).flatten
  llms_urls.reject! { |url| url.end_with?('/llms-full.txt') }
  errors << 'llms.txt contains duplicate canonical URLs' unless llms_urls.uniq.length == llms_urls.length
  errors << "llms.txt is missing: #{(indexable_urls - llms_urls).join(', ')}" unless (indexable_urls - llms_urls).empty?
  errors << "llms.txt has non-canonical/unknown URLs: #{(llms_urls - indexable_urls).join(', ')}" unless (llms_urls - indexable_urls).empty?
end

if llms_full_path.file?
  llms_full = llms_full_path.read
  errors << 'llms-full.txt must start with an H1' unless llms_full.match?(/\A#\s+\S/)
  full_urls = llms_full.scan(%r{^Canonical URL:\s+(https?://\S+)}).flatten
  errors << 'llms-full.txt contains duplicate canonical URLs' unless full_urls.uniq.length == full_urls.length
  missing_urls = indexable_urls - full_urls
  extra_urls = full_urls - indexable_urls
  errors << "llms-full.txt is missing: #{missing_urls.join(', ')}" unless missing_urls.empty?
  errors << "llms-full.txt has non-canonical/unknown URLs: #{extra_urls.join(', ')}" unless extra_urls.empty?
end

if errors.empty?
  puts "SEO audit passed for #{records.length} indexable HTML candidates in #{site_dir}"
else
  warn "SEO audit failed with #{errors.length} error(s):"
  errors.each { |error| warn "- #{error}" }
  exit 1
end
