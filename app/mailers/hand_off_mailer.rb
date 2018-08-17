class HandOffMailer < BaseMailer
  helper :application
  helper :email

  def acceptance_email(hand_off:)
    @hand_off = hand_off
    @owner = hand_off&.project&.owner
    @project = hand_off.project
    @task = hand_off.task

    send_single_email to: @owner.email,
                      subject_key: :'email.hand_off.acceptance.subject',
                      locale: locale_for(@owner.user)
  end

  def assignment_email(hand_off:, token:)
    @hand_off = hand_off
    @assignee = hand_off.assignee
    @link = build_url(:hand_off_assignment, token: token)

    send_single_email to: @assignee.email,
                      subject_key: :'email.hand_off.assignment.subject',
                      locale: locale_for(@assignee)

    hand_off.increment!(:email_count)
    hand_off.update_columns(last_emailed_at: Time.current.to_formatted_s(:db))
  end

  def invitation_email(hand_off:, token:)
    @hand_off = hand_off
    @assignee = hand_off.assignee
    @link = build_url(:hand_off_invitation, token: token)

    send_single_email to: @assignee.email,
                      subject_key: :'email.hand_off.invitation.subject',
                      locale: locale_for(@assignee)

    hand_off.increment!(:email_count)
    hand_off.update_columns(last_emailed_at: Time.current.to_formatted_s(:db))
  end
end
