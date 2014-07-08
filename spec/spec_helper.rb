unless ENV['SKIP_COV']
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter
  ]
  SimpleCov.start
end

require 'aws'
require 'chef/knife'
require 'spec_support/shared_daemons'
require 'chef_zero'
require 'chef_zero/server'
require 'vcr'

class ChefZero::SingleServer
  def initialize
    @server = ChefZero::Server.new
    @server.start_background
  end
  include Singleton

  def clean
    @server.clear_data
  end
end

server = ChefZero::SingleServer

Chef::Knife.new.configure_chef
Chef::Config[:chef_server_url] = 'http://127.0.0.1:8889'

AWS.config access_key_id: 'test', secret_access_key: 'test'
AWS.stub!

VCR.configure do |c|
  c.ignore_hosts '127.0.0.1'
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.before(:each) do
    ChefZero::SingleServer.instance.clean
  end
end
