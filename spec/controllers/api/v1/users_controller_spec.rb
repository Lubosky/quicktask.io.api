require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe '#index' do
    it 'returns a 401 when user is not authenticated' do
      get :index

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 when invalid token is supplied' do
      invalid_token_authentication
      get :index

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 when invalid entity is supplied' do
      invalid_entity_authentication
      get :index

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 200 when entity is successfully authenticated' do
      valid_token_authentication
      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe '#me' do
    it 'returns a 401 when user is not authenticated' do
      get :me

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 when invalid token is supplied' do
      invalid_token_authentication
      get :me

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 when invalid entity is supplied' do
      invalid_entity_authentication
      get :me

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 200 when entity is successfully authenticated' do
      valid_token_authentication
      get :me

      expect(response).to have_http_status(:success)
    end

    it 'returns current_user upon successful authentication' do
      valid_token_authentication
      get :me

      expect(response).to have_http_status(:success)
      expect(@controller.current_user.id).to eq @user.id
    end
  end

  it 'accepts any prefix in the authorization header' do
    user = create(:user)
    token = create(:token, user: user)
    authentication_token = token_for(user_id: user.id, token_id: token.id)
    request.env['HTTP_AUTHORIZATION'] = "Other #{authentication_token}"

    get :index

    expect(response).to have_http_status(:success)
  end

  it 'accepts authorization header without prefix' do
    user = create(:user)
    token = create(:token, user: user)
    authentication_token = token_for(user_id: user.id, token_id: token.id)
    request.env['HTTP_AUTHORIZATION'] = "#{authentication_token}"

    get :index

    expect(response).to have_http_status(:success)
  end

  describe do
    before :all do
      @user = create(:user)
      token = create(:token, user: @user)
      @token = token_for(user_id: @user.id, token_id: token.id)
    end

    it 'responds with 200' do
      authenticate
      get :me

      expect(@controller.current_user.id).to eq @user.id
      expect(response).to have_http_status(:success)
    end

    it 'responds with 200 #2' do
      authenticate
      get :me

      expect(@controller.current_user.id).to eq @user.id
      expect(response).to have_http_status(:success)
    end

    def authenticate(token: @token)
      @request.env['HTTP_AUTHORIZATION'] = "Bearer #{token}"
    end
  end

  def valid_token_authentication
    @user = create(:user)
    token = create(:token, user: @user)
    authentication_token = token_for(user_id: @user.id, token_id: token.id)
    request.env['HTTP_AUTHORIZATION'] = "Bearer #{authentication_token}"
  end

  def invalid_token_authentication
    authentication_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
    request.env['HTTP_AUTHORIZATION'] = "Bearer #{authentication_token}"
  end

  def invalid_entity_authentication
    authentication_token = token_for(user_id: 0, token_id: 0)
    request.env['HTTP_AUTHORIZATION'] = "Bearer #{authentication_token}"
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
