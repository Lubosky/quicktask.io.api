class Team::TasklistPolicy < Team::ApplicationPolicy
  def index?
    @user.team_member? && @user.allowed_to?(:manage_tasklists)
  end

  def create?
    @user.team_member? && @user.allowed_to?(:manage_tasklists)
  end

  def update?
    @user.team_member? && @user.allowed_to?(:manage_tasklists)
  end

  def destroy?
    @user.team_member? && @user.allowed_to?(:manage_tasklists)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
