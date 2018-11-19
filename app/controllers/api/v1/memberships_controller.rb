class Api::V1::MembershipsController < Api::BaseController
  before_action :authenticate_user
  before_action :ensure_workspace
  before_action :ensure_workspace_account

  deserializable_resource :membership, only: [:create]

  def create
    run Onboarding::CreateSubscription do |action|
      respond_with_result(action: action)
    end
  end
end
