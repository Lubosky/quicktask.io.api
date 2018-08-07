class Team::TeamMember::UpdateProfile < ApplicationInteractor
  object :team_member

  string :first_name, default: nil
  string :last_name, default: nil
  string :email, default: nil
  string :title, default: nil

  def execute
    transaction do
      unless team_member.update(given_attributes.except(:team_member))
        errors.merge!(team_member.errors)
        rollback
      end
    end
    team_member
  end
end
