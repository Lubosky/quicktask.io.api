Raven.configure do |config|
  config.async = lambda { |event| SentryJob.perform_later(event) }
  config.environments = %w[production]
  config.excluded_exceptions += ['Sidekiq::Shutdown']
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.tags = { application: 'QuickTask.io.API' }
end
