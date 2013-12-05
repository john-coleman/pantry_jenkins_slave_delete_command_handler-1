unless ENV["SKIP_COV"]
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter
  ]
  SimpleCov.start
end

require 'aws'
require 'rspec/fire'
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

AWS.config :access_key_id=>"test", :secret_access_key=>"test"
AWS.stub!

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.include(RSpec::Fire)

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  
  config.before(:each) do
    ChefZero::SingleServer.instance.clean
  end 
end
