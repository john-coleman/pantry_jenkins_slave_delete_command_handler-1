source 'https://rubygems.org'

gem 'pantry_daemon_common', github: 'wongatech/pantry_daemon_common'
gem 'chef', '~> 11.18'
gem 'mechanize'
gem 'nokogiri'
gem 'aws-sdk-v1'

group :development do
  gem 'guard-rspec'
  gem 'guard-bundler'
end

group :test, :development do
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'rspec'
  gem 'chef-zero'
  gem 'rake'
  gem 'rubocop'
end

group :test do
  gem 'vcr'
  gem 'webmock'
end
