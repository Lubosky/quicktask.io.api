class Api::V1::Client::ApplicationController < Api::BaseController

  private

  def set_current_workspace_user
    current_workspace.collaborating_clients.find_by(user: current_user)
  end
end
