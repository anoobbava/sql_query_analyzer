# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup

require 'logger'
require 'active_support'
require 'active_record'
require 'sqlite3'
require 'sql_query_analyzer'

# Set up logging
ActiveRecord::Base.logger = Logger.new($stdout)

# Set up a test database
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clean up after each test
  config.after(:each) do
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end
end
