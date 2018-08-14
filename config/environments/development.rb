Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = false
  config.consider_all_requests_local = true
  config.eager_load = false
  config.reload_classes_only_on_change = false

  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    if ENV['REDIS_CACHE_URL'].present?
      Readthis.serializers << Oj
      Readthis.serializers.freeze!
      Readthis::Cache.new(marshal: Oj)

      config.cache_store = :readthis_store, {
        expires_in: 1.week.to_i,
        namespace: 'gliderpath-cache',
        compress: true,
        compression_threshold: 2.kilobytes,
        redis: { url: ENV.fetch('REDIS_CACHE_URL'), driver: :hiredis }
      }
    else
      config.cache_store = :memory_store, { size: 64.megabytes }
    end

    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.assets.debug = true
  config.assets.digest = true
  config.assets.raise_runtime_errors = true
  config.assets.quiet = true

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = {
    host: ENV.fetch('CANONICAL_HOST', 'localhost'),
    port: ENV.fetch('CANONICAL_PORT', '3000')
  }

  config.active_record.migration_error = :page_load
  config.active_support.deprecation = :log
  # Store uploaded files on the local file system (see config/storage.yml for options)
  # config.active_storage.service = :local

  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
