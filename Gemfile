source 'https://rubygems.org'

gem 'pantry_daemon_common', git: 'git@github.com:wongatech/pantry_daemon_common.git', tag: 'v0.2.6'
gem 'chef', '~> 11.12'
gem 'mechanize'
gem 'nokogiri'

group :development do
  gem 'guard-rspec'
end

group :test, :development do
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'rspec'
  gem 'chef-zero'
  gem 'rake'
end

group :test do
  gem 'vcr'
  gem 'webmock'
end
