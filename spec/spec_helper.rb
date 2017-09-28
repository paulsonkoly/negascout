require 'simplecov'

SimpleCov.start do |c|
  add_filter 'spec/'
end

require "bundler/setup"
require "negascout"
require 'support/node_double'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
