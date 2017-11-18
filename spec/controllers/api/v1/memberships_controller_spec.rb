require 'rails_helper'

RSpec.describe Api::V1::MembershipsController, type: :controller do
  before :each do
    StripeMock.start
    stub_stripe_plan('tms.GliderPath.AirborneBucket.Monthly')
  end

  after :each do
    StripeMock.stop
  end

  describe '#create' do
    it 'creates and saves a stripe customer and charges it for the subscription' do
      valid_token_authentication
      plan = create(:plan)
      card_token = StripeMock.generate_card_token

      post :create, params: {
        membership: {
          stripe_token: card_token, quantity: 1, interval: 'month'
        },
        workspace_identifier: @workspace.slug
      }

      expect(response).to have_http_status(:success)
    end
  end

  def build_workspace_with_user
    @user = create(:user)
    @workspace = create(:workspace, :with_roles, owner: @user, name: 'Subscribed Space')
    role = @workspace.roles.find_by(permission_level: :owner)
    team_member = create(:team_member, workspace: @workspace)
    create(:workspace_user, role: role, user: @user, workspace: @workspace)
    @token = create(:token, user: @user)
  end

  def valid_token_authentication
    build_workspace_with_user
    authentication_token = token_for(user_id: @user.id, token_id: @token.id)
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
