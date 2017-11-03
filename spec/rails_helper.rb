ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'shoulda/matchers'
require 'sidekiq/testing'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.filter_rails_from_backtrace!
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true

  config.before(:suite) do
    DatabaseRewinder.clean_all
  end

  config.after(:each) do
    DatabaseRewinder.clean
  end

  config.before(:each) do |f|
    Sidekiq::Worker.clear_all

    if f.metadata[:sidekiq] == :fake
      Sidekiq::Testing.fake!
    elsif f.metadata[:sidekiq] == :inline
      Sidekiq::Testing.inline!
    elsif f.metadata[:sidekiq] == true
      Sidekiq::Testing.inline!
    elsif f.metadata[:type] == :feature
      Sidekiq::Testing.inline!
    else
      Sidekiq::Testing.fake!
    end
  end

  config.after(:suite) do
    Sidekiq::Worker.clear_all
  end

  config.include FactoryBot::Syntax::Methods
  config.include StripeHelper
end

def fixture_for(*path, filetype: 'image/jpeg')
  ActionDispatch::Http::UploadedFile.new(
    tempfile: File.open(File.join(path.unshift(Rails.root, 'spec', 'fixtures'))),
    filename: path.last,
    type: filetype
  )
end

def described_model_name
  described_class.model_name.singular
end
