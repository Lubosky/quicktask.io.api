$: << File.expand_path('../..', __FILE__)

require 'action_mailer'
require 'email_spec'
require 'email_spec/rspec'
require 'pundit/rspec'
require 'rspec/collection_matchers'
require 'simplecov'
require 'webmock/rspec'

SimpleCov.start

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = [:expect, :should]
  end

  config.mock_with :mocha

  config.disable_monkey_patching!
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.filter_run_when_matching :focus
  config.shared_context_metadata_behavior = :apply_to_host_groups

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10
  config.order = :random

  WebMock.disable_net_connect!(allow_localhost: true)

  Kernel.srand config.seed
end
