# frozen_string_literal: true

require 'simplecov'
require 'English'
require 'factory_bot'
require 'database_cleaner'
require 'timecop'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib/")
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../")

require 'searchndroch_bot'

ActiveRecord::Base.establish_connection(SND.cfg.options['database'])

# @param [String] str
# @return [Time]
def time_to_tz(str)
  Time.parse(str).localtime.strftime('%d.%m %T')
end

RSpec.configure do |config|
  include R18n::Helpers
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
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

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    FactoryBot.find_definitions
  end

  config.before(:each) do
    DatabaseCleaner.clean
    allow(SND.tlg.api).to receive(:send_message) { |p| p[:text] }
  end
end
