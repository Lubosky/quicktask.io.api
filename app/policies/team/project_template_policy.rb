class Team::ProjectTemplatePolicy < Team::ApplicationPolicy
  def index?
    @user.team_member? && @user.allowed_to?(:manage_project_templates)
  end

  def show?
    @user.team_member? && @user.allowed_to?(:manage_project_templates)
  end

  def create?
    @user.team_member? && @user.allowed_to?(:manage_project_templates)
  end

  def update?
    @user.team_member? && @user.allowed_to?(:manage_project_templates)
  end

  def destroy?
    @user.team_member? && @user.allowed_to?(:manage_project_templates)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
