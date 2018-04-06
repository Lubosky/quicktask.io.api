class Team::ProjectPolicy < Team::ApplicationPolicy
  def index?
    @user.team_member? && @user.allowed_to?(:manage_projects)
  end

  def show?
    @user.team_member? && @user.allowed_to?(:manage_projects)
  end

  def create?
    @user.team_member? && @user.allowed_to?(:manage_projects)
  end

  def update?
    @user.team_member? && @user.allowed_to?(:manage_projects)
  end

  def destroy?
    @user.team_member? && @user.allowed_to?(:manage_projects)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
