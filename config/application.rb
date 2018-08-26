require_relative 'boot'

require 'rails'

require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
# require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module GliderPathApi
  class Application < Rails::Application
    config.load_defaults 5.1

    config.generators do |generate|
      generate.test_framework :rspec, fixture: false
      generate.factory_bot false
      generate.helper = false
      generate.helper_specs false
      generate.view_specs false
    end

    config.api_only = true
    config.autoload_paths += %W(#{config.root}/lib)
    config.encoding = 'utf-8'
    config.force_ssl = ENV.has_key?('FORCE_SSL')

    config.i18n.default_locale = :en
    I18n.config.enforce_available_locales = true

    config.middleware.use Rack::Attack
    config.middleware.use Rack::Deflater
    config.middleware.use Rack::CanonicalHost, ENV['CANONICAL_HOST'] if ENV['CANONICAL_HOST']

    config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 10

    config.active_job.queue_adapter = :sidekiq

    config.action_mailer.default(charset: 'utf-8')
    config.action_mailer.perform_caching = false
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true

    if ENV['SMTP_SERVER']
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = {
        address: ENV.fetch('SMTP_SERVER', 'localhost'),
        port: ENV.fetch('SMTP_PORT', 1025).to_i,
        authentication: ENV.fetch('SMTP_AUTHENTICATION', nil),
        user_name: ENV.fetch('SMTP_USERNAME', nil),
        password: ENV.fetch('SMTP_PASSWORD', nil),
        domain: ENV.fetch('SMTP_DOMAIN', 'quicktask.test'),
        openssl_verify_mode: 'none'
      }.compact
    else
      config.action_mailer.delivery_method = :test
    end

    config.action_mailer.default_url_options = config.action_controller.default_url_options = {
      host:     ENV['CANONICAL_HOST'],
      port:     ENV['CANONICAL_PORT'],
      protocol: ENV['FORCE_SSL'] ? 'https' : 'http'
    }.compact
  end
end
