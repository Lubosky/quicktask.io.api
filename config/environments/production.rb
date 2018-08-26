Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.action_controller.perform_caching = true
  config.cache_classes = true
  config.consider_all_requests_local = false
  config.eager_load = true

  config.assets.compile = false

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.read_encrypted_secrets = true

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  # config.active_storage.service = :local

  config.active_support.deprecation = :notify

  config.i18n.fallbacks = true

  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :warn
  config.log_tags = [:request_id]

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false

  config.after_initialize do
    if ENV['REDIS_CACHE_URL'].present?
      Readthis.serializers << Oj
      Readthis.serializers.freeze!
      Readthis::Cache.new(marshal: Oj)

      config.cache_store = :readthis_store, {
        expires_in: 1.week.to_i,
        namespace: 'quicktask-cache',
        compress: true,
        compression_threshold: 2.kilobytes,
        redis: { url: ENV.fetch('REDIS_CACHE_URL'), driver: :hiredis }
      }
    else
      config.cache_store = :memory_store, { size: 64.megabytes }
    end
  end
end
