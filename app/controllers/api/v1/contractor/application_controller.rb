class Api::V1::Contractor::ApplicationController < Api::BaseController

  private

  def pundit_user
    current_workspace_user
  end

  def set_current_workspace_user
    current_workspace.collaborating_contractors.find_by(user: current_user)
  end
end
