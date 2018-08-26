Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = true
  config.eager_load = false

  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  config.action_controller.allow_forgery_protection = false
  config.action_controller.perform_caching = false

  config.action_dispatch.show_exceptions = false

  config.action_mailer.default_url_options = { host: 'quicktask.test' }

  config.active_support.deprecation = :stderr

  # Store uploaded files on the local file system in a temporary directory
  # config.active_storage.service = :test

  config.consider_all_requests_local = true

  ENV['SECRET_KEY_BASE']      = 'xxxxxxxxxxxxxxxxxx'
  ENV['SECRET_SALT']          = 'xxxxxxxxx'
  ENV['GOOGLE_KEY']           = '123456789.apps.googleusercontent.com'
  ENV['GOOGLE_SECRET']        = '999000999'
end
