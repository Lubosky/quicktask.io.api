class Team::ClientPolicy < Team::ApplicationPolicy
  def index?
    @user.team_member? && @user.allowed_to?(:manage_clients)
  end

  def show?
    @user.team_member? && @user.allowed_to?(:manage_clients)
  end

  def create?
    @user.team_member? && @user.allowed_to?(:manage_clients)
  end

  def update?
    @user.team_member? && @user.allowed_to?(:manage_clients)
  end

  def destroy?
    @user.team_member? && @user.allowed_to?(:manage_clients)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
