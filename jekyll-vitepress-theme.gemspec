require_relative 'lib/jekyll/vitepress_theme/version'

Gem::Specification.new do |spec|
  spec.name          = 'jekyll-vitepress-theme'
  spec.version       = Jekyll::VitePressTheme::VERSION
  spec.authors       = ['Carmine Paolino']
  spec.email         = ['carmine@paolino.me']

  spec.summary       = 'A VitePress-like docs theme for Jekyll.'
  spec.description   = 'Jekyll VitePress Theme brings the VitePress default theme look and behavior to Jekyll sites.'
  spec.homepage      = 'https://jekyll-vitepress.dev'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/crmne/jekyll-vitepress-theme'
  spec.metadata['changelog_uri'] = "#{spec.metadata['source_code_uri']}/commits/master"
  spec.metadata['documentation_uri'] = spec.homepage
  spec.metadata['bug_tracker_uri'] = "#{spec.metadata['source_code_uri']}/issues"
  spec.metadata['funding_uri'] = 'https://github.com/sponsors/crmne'

  spec.files = Dir[
    'assets/**/*',
    '_includes/**/*',
    '_layouts/**/*',
    'lib/**/*',
    'LICENSE*',
    'README.md'
  ].select { |f| File.file?(f) }

  spec.require_paths = ['lib']

  spec.add_dependency 'jekyll', '>= 4.3', '< 5.0'
  spec.add_dependency 'rouge', '>= 3.0', '< 5.0'
end
