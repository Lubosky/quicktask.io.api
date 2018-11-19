class Team::TeamMember::UpdateProfile < ApplicationInteractor
  string :first_name
  string :last_name
  string :email
  string :title

  def execute
    transaction do
      unless team_member.update(given_attributes)
        errors.merge!(team_member.errors)
        rollback
      end
      unless user.update(user_attributes)
        errors.merge!(user.errors)
        rollback
      end
    end
    team_member
  end

  private

  def user_attributes
    attributes.slice(:first_name, :last_name, :email)
  end

  def team_member
    @_team_member ||= current_account.account
  end

  def user
    @_user ||= current_user
  end
end
