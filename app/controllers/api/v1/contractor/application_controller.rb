class Api::V1::Contractor::ApplicationController < Api::BaseController

  private

  def pundit_user
    current_account
  end

  def set_current_account
    current_workspace.collaborating_contractors.find_by(user: current_user)
  end
end
