source 'https://rubygems.org'

gem 'pantry_daemon_common', git: 'git@github.com:wongatech/pantry_daemon_common.git', :tag => 'v0.2.1'
gem 'chef','~> 11.8.2'
gem 'mechanize'
gem 'nokogiri'

group :development do
  gem 'guard-rspec'
  gem 'guard-bundler'
end

group :test, :development do
  gem 'em-winrm', git: 'https://github.com/besol/em-winrm.git'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'rspec-fire'
  gem 'rspec'
  gem 'chef-zero'
  gem 'pry-debugger'
  gem 'rake'
end

group :test do
  gem 'vcr'
  gem 'webmock'
end
