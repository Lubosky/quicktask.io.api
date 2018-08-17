class Team::HandOff::Resend < ApplicationInteractor
  object :hand_off

  def execute
    token = HandOffToken.generate_for(hand_off).to_s
    deliver_email(token)

    hand_off
  end

  private

  def assignee
    hand_off.assignee
  end

  def assign_directly?
    hand_off.assign_directly? || assignee.is_a?(TeamMember)
  end

  def deliver_email(token)
    return unless hand_off.pending?
    if assign_directly?
      mail = HandOffMailer.assignment_email(hand_off: hand_off, token: token)
    else
      mail = HandOffMailer.invitation_email(hand_off: hand_off, token: token)
    end
    mail.deliver_later
  end
end
