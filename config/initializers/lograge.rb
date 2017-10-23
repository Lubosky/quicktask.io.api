Rails.application.configure do
  config.lograge.base_controller_class = 'ActionController::API'
  config.lograge.enabled = true

  config.lograge.custom_options = lambda do |event|
    options = event.payload.slice(:host, :remote_ip, :request_id, :user_agent, :user_id)
    options[:params] = event.payload[:params].except('controller', 'action', 'format', 'utf8')
    options
  end
end
