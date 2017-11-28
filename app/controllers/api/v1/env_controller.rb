class Api::V1::EnvController < Api::BaseController
  def show
    render json: resource, status: :ok
  end

  private

  def resource
    {}.tap do |hash|
      hash[:backend_url] = backend_url
      hash[:google_client_id] = ENV['GOOGLE_KEY']
    end
  end

  def backend_url
    url = "URI::#{ENV.has_key?('FORCE_SSL') ? 'HTTPS' : 'HTTP'}".constantize
    url.build(host: ENV['CANONICAL_HOST'], port: ENV['CANONICAL_PORT']).to_s
  end
end
