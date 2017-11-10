class Api::V1::UsersController < Api::BaseController
  before_action :authenticate_user

  def me
    self.resource = current_user
    respond_with_resource
  end

  private

  def accessible_records
    User.all
  end
end
