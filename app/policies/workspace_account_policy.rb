class WorkspaceAccountPolicy < ApplicationPolicy
  def update?
    workspace_account? && @user.id == @record.id
  end

  private

  def workspace_account?
    @user.is_a?(WorkspaceAccount)
  end
end
