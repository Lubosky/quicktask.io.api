ruby `cat .ruby-version`.strip
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'active_interaction', github: 'AaronLasseigne/active_interaction', branch: 'v4.0.0'
gem 'active_record_union'
gem 'acts_as_list'
gem 'addressable'
gem 'bcrypt'
gem 'bootsnap'
gem 'bson'
gem 'commonmarker'
gem 'config'
gem 'counter_culture'
gem 'clowne'
gem 'discriminator'
gem 'geocoder'
gem 'google-id-token'
gem 'graphiql-rails'
gem 'graphql-batch'
gem 'graphql-errors'
gem 'graphql-pundit'
gem 'graphql'
gem 'has_scope'
gem 'hiredis'
gem 'html-pipeline'
gem 'httparty'
gem 'jsonapi-rails', github: 'jsonapi-rb/jsonapi-rails', branch: 'charset'
gem 'jsonb_accessor'
gem 'jwt'
gem 'kaminari-activerecord'
gem 'lograge'
gem 'money-oxr'
gem 'money-rails'
gem 'oj'
gem 'pg'
gem 'premailer-rails'
gem 'pry-byebug'
gem 'pry-rails'
gem 'puma', '~> 3.7'
gem 'pundit'
gem 'rack-attack'
gem 'rack-canonical-host'
gem 'rack-cors'
gem 'rack-timeout'
gem 'rails'
gem 'rbtrace'
gem 'readthis'
gem 'redis'
gem 'rinku'
gem 'sanitize'
gem 'sass-rails'
gem 'sentry-raven'
gem 'sidekiq'
gem 'sidekiq-unique-jobs'
gem 'simple_scheduler'
gem 'stateful_enum'
gem 'sinatra', require: false
gem 'stripe'
gem 'twemoji'

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
