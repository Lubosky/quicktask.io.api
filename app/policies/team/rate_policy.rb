class Team::RatePolicy < Team::ApplicationPolicy
  def index?
    @user.team_member?
  end

  def show?
    @user.team_member?
  end

  def create?
    @user.team_member?
  end

  def update?
    @user.team_member?
  end

  def destroy?
    @user.team_member?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
