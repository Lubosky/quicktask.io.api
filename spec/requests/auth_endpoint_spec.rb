require 'rails_helper'

RSpec.describe 'POST /api/auth/login', type: :request do
  let(:user) { create(:user) }

  describe 'successful authentication' do
    it 'returns a 201 upon successful verification' do
      post url_for([:api, :auth, :login]), params: { email: user.email, password: user.password }

      expect(response).to have_http_status(:success)
      expect(response.code).to eq('201')
    end

    it 'returns access token upon successful verification' do
      post url_for([:api, :auth, :login]), params: { email: user.email, password: user.password }

      expect(JSON.parse(response.body).keys).to contain_exactly('token')
    end
  end

  describe 'unsuccessful authentication' do
    it 'returns a 401 when user submits incorrect password' do
      post url_for([:api, :auth, :login]), params: { email: user.email, password: 'p@zzword' }

      expect(response).to have_http_status(:unauthorized)
      expect(response.code).to eq('401')
    end

    it 'returns a 401 when user doesn\'t exist' do
      post url_for([:api, :auth, :login]), params: { email: 'qwerty@qwerty.dev', password: 'password' }

      expect(response).to have_http_status(:unauthorized)
      expect(response.code).to eq('401')
    end
  end

  describe 'successful logout' do
    it 'deletes authentication token' do
      valid_token_authentication

      expect do
        delete url_for([:api, :auth, :logout]), headers: { 'HTTP_AUTHORIZATION' => "Bearer #{@authentication_token}" }
      end.to change { Token.count }.by -1
    end
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
