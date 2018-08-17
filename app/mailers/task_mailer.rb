class TaskMailer < BaseMailer
  helper :application
  helper :email

  def expiring_hand_offs_notification(task:, owner:)
    @task = task
    @owner = owner

    send_single_email to: @owner.email,
                      subject_key: :'email.task.expiring_hand_offs.subject',
                      locale: locale_for(@owner.user)
  end
end
