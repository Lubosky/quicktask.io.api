class Api::V1::UsersController < Api::BaseController
  before_action :authenticate_user

  deserializable_resource :user, only: [:create]

  def create
    run User::Create do |action|
      respond_with_result(action: action)
    end
  end

  def me
    self.resource = current_user
    respond_with_resource
  end

  private

  def accessible_records
    User.all
  end
end
