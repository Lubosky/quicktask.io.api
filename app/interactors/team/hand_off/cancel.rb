class Team::HandOff::Cancel < ApplicationInteractor
  object :hand_off

  def execute
    transaction do
      hand_off.cancel!({ canceller: canceller })
    end
    hand_off
  end

  private

  def canceller
    current_workspace_user.member
  end
end
