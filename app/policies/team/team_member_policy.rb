class Team::TeamMemberPolicy < ApplicationPolicy
  def update?
    @user.team_member? && @user.allowed_to?(:manage_team_members)
  end

  def update_profile?
    @user.team_member? && @user.member.id == @record.id
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
