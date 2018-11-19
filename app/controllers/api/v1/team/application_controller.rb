class Api::V1::Team::ApplicationController < Api::BaseController

  private

  def pundit_user
    current_account
  end

  def set_current_account
    current_workspace.collaborating_team_members.find_by(user: current_user)
  end
end
