ruby `cat .ruby-version`.strip
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'active_interaction'
gem 'addressable'
gem 'bcrypt'
gem 'bootsnap'
gem 'bson'
gem 'commonmarker'
gem 'config'
gem 'email_validator'
gem 'google-id-token'
gem 'has_scope'
gem 'hiredis'
gem 'html-pipeline'
gem 'httparty'
gem 'jsonapi-rails', github: 'jsonapi-rb/jsonapi-rails', branch: 'charset'
gem 'jwt'
gem 'lograge'
gem 'oj'
gem 'pg'
gem 'premailer-rails'
gem 'pry-byebug'
gem 'pry-rails'
gem 'puma', '~> 3.7'
gem 'pundit'
gem 'rack-attack'
gem 'rack-canonical-host'
gem 'rack-timeout'
gem 'rails', '~> 5.1.4'
gem 'rbtrace'
gem 'readthis'
gem 'rinku'
gem 'sanitize'
gem 'sass-rails'
gem 'sentry-raven', '~> 2.7'
gem 'sidekiq'
gem 'sidekiq-unique-jobs'
gem 'stateful_enum'
gem 'sinatra', require: false
gem 'stripe'
gem 'twemoji'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  gem 'dotenv-rails'
  gem 'faker'
  gem 'marginalia'
  gem 'rubocop', '~> 0.51.0', require: false
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_rewinder'
  gem 'email_spec'
  gem 'factory_bot_rails'
  gem 'fuubar', require: false
  gem 'mocha'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'stripe-ruby-mock', require: 'stripe_mock'
  gem 'timecop'
  gem 'webmock'
end
