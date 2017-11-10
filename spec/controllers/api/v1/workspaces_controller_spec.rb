require 'rails_helper'

RSpec.describe Api::V1::WorkspacesController, type: :controller do
  describe '#show' do
    it 'returns a 401 when user is not authenticated' do
      workspace = build_stubbed(:workspace, slug: 'subscribed-space')
      get :show, params: { workspace_identifier: workspace.slug }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 when invalid token is supplied' do
      invalid_token_authentication
      workspace = build_stubbed(:workspace, slug: 'subscribed-space')
      get :show, params: { workspace_identifier: workspace.slug }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 when invalid user is supplied' do
      invalid_entity_authentication
      workspace = build_stubbed(:workspace, slug: 'subscribed-space')
      get :show, params: { workspace_identifier: workspace.slug }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 when invalid workspace slug is supplied' do
      valid_token_authentication
      workspace = build_stubbed(:workspace, slug: 'subscribed-space')
      get :show, params: { workspace_identifier: 'subscribed' }

      expect(response).to have_http_status(:unauthorized)
      expect(@controller.current_workspace).to eq(nil)
    end

    it 'returns a 200 when user is successfully authenticated and workspace exists' do
      valid_token_authentication
      get :show, params: { workspace_identifier: @workspace.slug }

      expect(response).to have_http_status(:success)
    end

    it 'returns current_workspace upon successful authentication' do
      valid_token_authentication
      get :show, params: { workspace_identifier: @workspace.slug }

      expect(response).to have_http_status(:success)
      expect(@controller.current_workspace.slug).to eq @workspace.slug
    end
  end

  def valid_token_authentication
    user = create(:user)
    @workspace = create(:workspace, owner: user, name: 'Subscribed Space')
    token = create(:token, user: user)
    authentication_token = token_for(user_id: user.id, token_id: token.id)
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
