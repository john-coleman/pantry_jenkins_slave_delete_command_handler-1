unless ENV['SKIP_COV']
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter
  ]
  SimpleCov.start
end

require 'aws-sdk-v1'
require 'chef/knife'
require 'spec_support/shared_daemons'
require 'chef_zero'
require 'chef_zero/server'
require 'vcr'
require 'pry'

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
puts "ChefZero Server listening on #{server.instance.inspect}"

Chef::Knife.new.configure_chef
Chef::Config[:chef_server_url] = 'http://127.0.0.1:8889'
Chef::Config[:client_key] = File.join(File.expand_path(File.dirname(File.realpath(__FILE__))), 'chef.pem')
Chef::Config[:node_name] = 'test_name'

AWS.config access_key_id: 'test', secret_access_key: 'test'
AWS.stub!

VCR.configure do |c|
  c.ignore_hosts '127.0.0.1'
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end

RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  config.before(:each) do
    ChefZero::SingleServer.instance.clean
  end
end
