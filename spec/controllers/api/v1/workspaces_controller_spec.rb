require 'rails_helper'

RSpec.describe Api::V1::WorkspacesController, type: :controller do
  describe '#show' do
    it 'returns a 401 when user is not authenticated' do
      workspace = build_stubbed(:workspace)
      get :show, params: { identifier: workspace.id }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 when invalid token is supplied' do
      invalid_token_authentication
      get :show, params: { identifier: @workspace.id }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 when invalid user is supplied' do
      invalid_entity_authentication
      get :show, params: { identifier: @workspace.id }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 when invalid workspace ID is supplied' do
      valid_token_authentication
      workspace = build_stubbed(:workspace)
      get :show, params: { identifier: 'subscribed' }

      expect(response).to have_http_status(:unauthorized)
      expect(@controller.current_workspace).to eq(nil)
    end

    it 'returns a 200 when user is successfully authenticated and workspace exists' do
      valid_token_authentication
      get :show, params: { identifier: @workspace.id }

      expect(response).to have_http_status(200)
    end

    it 'returns current_workspace upon successful authentication' do
      valid_token_authentication
      get :show, params: { identifier: @workspace.id }

      expect(response).to have_http_status(200)
      expect(@controller.current_workspace.id).to eq @workspace.id
    end
  end

  def valid_token_authentication
    build_workspace_with_user
    authentication_token = token_for(user_id: @user.id, token_id: @token.id)
    request.env['HTTP_AUTHORIZATION'] = "Bearer #{authentication_token}"
  end

  def invalid_token_authentication
    build_workspace_with_user
    authentication_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
    request.env['HTTP_AUTHORIZATION'] = "Bearer #{authentication_token}"
  end

  def invalid_entity_authentication
    build_workspace_with_user
    authentication_token = token_for(user_id: 0, token_id: 0)
    request.env['HTTP_AUTHORIZATION'] = "Bearer #{authentication_token}"
  end

  def build_workspace_with_user
    @user = create(:user)
    @workspace = create(:workspace, :with_roles, owner: @user, name: 'Subscribed Space')
    role = @workspace.roles.find_by(permission_level: :owner)
    team_member = create(:team_member, workspace: @workspace)
    create(:workspace_user, role: role, user: @user, workspace: @workspace)
    @token = create(:token, user: @user)
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
