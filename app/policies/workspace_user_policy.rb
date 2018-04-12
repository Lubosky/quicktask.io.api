class WorkspaceUserPolicy < ApplicationPolicy
  def update?
    workspace_user? && @user.id == @record.id
  end

  private

  def workspace_user?
    @user.is_a?(WorkspaceUser)
  end
end
