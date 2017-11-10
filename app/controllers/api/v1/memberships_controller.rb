class Api::V1::MembershipsController < Api::BaseController
  before_action :authenticate_user
  before_action :ensure_workspace

  deserializable_resource :membership, only: [:create]

  def create
    run Membership::Create do |action|
      respond_with_result(action: action)
    end
  end
end
