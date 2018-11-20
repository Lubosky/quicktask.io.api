class TagPolicy < ApplicationPolicy
  def index?
    @user
  end

  def show?
    @user && @user.workspace_id == @record.workspace_id
  end

  def create?
    @user.team_member?
  end

  def update?
    @user.team_member? && @user.workspace_id == @record.workspace_id
  end

  def add?
    @user.team_member? && @user.workspace_id == @record.workspace_id
  end

  def remove?
    @user.team_member? && @user.workspace_id == @record.workspace_id
  end

  def destroy?
    @user.team_member? && @user.workspace_id == @record.workspace_id
  end

  private

  class Scope < Scope
    def resolve
      scope
    end
  end
end
