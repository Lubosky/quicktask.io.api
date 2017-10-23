require 'sinatra/base'

class FakeGoogle < Sinatra::Base
  set :show_exceptions, true
  set :raise_errors, true

  post '/oauth2/v4/token' do
    content_type :json

    successful_code_exchange_response.to_json
  end

  private

  def successful_code_exchange_response
    {
      'access_token': 'google_access_token',
      'expires_in':   3599,
      'id_token':     'google_id_token',
      'token_type':   'Bearer'
    }
  end
end

RSpec.configure do |config|
  GOOGLE_API_URL = 'https://www.googleapis.com'.freeze

  config.before do
    google_host = GOOGLE_API_URL.split('//')[1]

    WebMock.stub_request(
      :any,
      %r{https:\/\/(\S+:\S+@)?#{Regexp.escape(google_host)}.*}
    ).to_rack(FakeGoogle)
  end
end
