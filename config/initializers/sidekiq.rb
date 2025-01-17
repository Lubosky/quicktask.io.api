Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379') }
end

Sidekiq.default_worker_options = { backtrace: true,
                                   retry: 5,
                                   unique: :until_executed }
