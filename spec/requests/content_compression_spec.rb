require 'rails_helper'

RSpec.describe Rack::Deflater, type: :request do
  it 'deflates the content' do
    create_list(:user, 2)

    valid_token_authentication

    get url_for([:api, :users]), headers: { 'CONTENT_TYPE' => 'application/vnd.gliderpath.v1+json',
                                            'HTTP_AUTHORIZATION' => "Bearer #{@authentication_token}"
                                          }

    expect(response.headers['Content-Encoding']).not_to be
    content_length = response.headers['Content-Length']

    get url_for([:api, :users]), headers: { 'CONTENT_TYPE' => 'application/vnd.gliderpath.v1+json',
                                            'HTTP_ACCEPT_ENCODING' => 'gzip',
                                            'HTTP_AUTHORIZATION' => "Bearer #{@authentication_token}"
                                          }

    expect(response.headers['Content-Encoding']).to eq('gzip')
    expect(response.headers['Content-Length']).not_to eq(content_length)
  end

  def valid_token_authentication
    user = create(:user)
    token = create(:token, user: user)
    @authentication_token = token_for(user_id: user.id, token_id: token.id)
  end

  def token_audience
    AuthenticationToken.token_audience_identifier.call
  end

  def token_issuer
    AuthenticationToken.token_issuer_identifier.call
  end

  def token_for(user_id:, token_id:)
    AuthenticationToken.new(
      payload: {
        sub: user_id,
        jti: token_id,
        aud: token_audience,
        iss: token_issuer
      }
    ).token
  end
end
