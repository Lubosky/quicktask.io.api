Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '/api/*',
      headers: ['Authorization', 'Content-Type', 'If-None-Match'],
      methods: [:get, :post, :delete, :put, :patch, :options, :head],
      expose: ['WWW-Authenticate', 'Server-Authorization']
  end
end
