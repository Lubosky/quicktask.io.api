class Team::TodoPolicy < Team::ApplicationPolicy
  def show?
    @user.team_member? && @user.allowed_to?(:manage_todos)
  end

  def create?
    @user.team_member? && @user.allowed_to?(:manage_todos)
  end

  def update?
    @user.team_member? && @user.allowed_to?(:manage_todos)
  end

  def destroy?
    @user.team_member? && @user.allowed_to?(:manage_todos)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
