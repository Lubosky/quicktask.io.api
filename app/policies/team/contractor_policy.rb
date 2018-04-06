class Team::ContractorPolicy < Team::ApplicationPolicy
  def index?
    @user.team_member? && @user.allowed_to?(:manage_contractors)
  end

  def show?
    @user.team_member? && @user.allowed_to?(:manage_contractors)
  end

  def create?
    @user.team_member? && @user.allowed_to?(:manage_contractors)
  end

  def update?
    @user.team_member? && @user.allowed_to?(:manage_contractors)
  end

  def destroy?
    @user.team_member? && @user.allowed_to?(:manage_contractors)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
