class Api::V1::WorkspacesController < Api::BaseController
  before_action :authenticate_user
  before_action :ensure_workspace

  def show
    self.resource = current_workspace
    respond_with_resource
  end
end
