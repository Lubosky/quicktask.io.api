class Team::TaskPolicy < Team::ApplicationPolicy
  def index?
    @user.team_member? && @user.allowed_to?(:manage_tasks)
  end

  def show?
    @user.team_member? && @user.allowed_to?(:manage_tasks)
  end

  def create?
    @user.team_member? && @user.allowed_to?(:manage_tasks)
  end

  def update?
    @user.team_member? && @user.allowed_to?(:manage_tasks)
  end

  def destroy?
    @user.team_member? && @user.allowed_to?(:manage_tasks)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
