class Team::HandOff::Create < ApplicationInteractor
  object :task

  integer :assignee_id, default: nil
  boolean :assignment, default: false
  decimal :rate_applied, default: nil

  def execute
    transaction do
      unless hand_off.save
        errors.merge!(hand_off.errors)
        rollback
      end

      hand_off.tap(&:assign!) if hand_off.valid? && assign_directly?
    end

    token = HandOffToken.generate_for(hand_off).to_s
    deliver_email(token)

    hand_off
  end

  private

  def assignee
    assignee_scope.find_by(id: assignee_id)
  end

  def assignee_scope
    return ::TeamMember if task.other_task?
    return ::Contractor
  end

  def assign_directly?
    task.other_task? || assignment
  end

  def deliver_email(token)
    return unless hand_off.valid?
    if assign_directly?
      mail = HandOffMailer.assignment_email(hand_off: hand_off, token: token)
    else
      mail = HandOffMailer.invitation_email(hand_off: hand_off, token: token)
    end
    mail.deliver_later
  end

  def hand_off
    @hand_off ||= task.hand_offs.build(hand_off_attributes)
  end

  def hand_off_attributes
    attributes.tap do |hash|
      hash[:assigner] = current_workspace_user.member
      hash[:assignee] = assignee
      hash[:assignment] = assign_directly?
    end
  end
end

