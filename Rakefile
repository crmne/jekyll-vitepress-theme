# frozen_string_literal: true

require "rake"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

desc "Run local quality checks (Ruby + Node + Jekyll)"
task verify: :test do
  sh "bundle exec rubocop --force-exclusion"
  sh "npm run lint"
  sh "bundle exec jekyll build"
  sh "bash scripts/smoke_test.sh _site"
  sh "gem build jekyll-vitepress-theme.gemspec"
end

desc "Run configured overcommit hooks"
task :overcommit do
  sh "bundle exec overcommit --run"
end
