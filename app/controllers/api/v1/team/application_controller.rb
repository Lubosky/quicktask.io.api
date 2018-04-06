class Api::V1::Team::ApplicationController < Api::BaseController

  private

  def pundit_user
    current_workspace_user
  end

  def set_current_workspace_user
    current_workspace.collaborating_team_members.find_by(user: current_user)
  end
end
