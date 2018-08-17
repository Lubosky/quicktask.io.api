class Team::HandOff::Reject < ApplicationInteractor
  object :hand_off

  def execute
    transaction do
      hand_off.reject!
    end
    hand_off
  end
end
