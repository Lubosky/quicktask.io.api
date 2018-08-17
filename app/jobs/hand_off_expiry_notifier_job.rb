# frozen_string_literal: true

class HandOffExpiryNotifierJob
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(task_id)
    task = Task.includes(:project_owner).find_by(id: task_id)
    deliver_email(task, task.project_owner) if task
  end

  private

  def deliver_email(task, owner)
    mail = TaskMailer.expiring_hand_offs_notification(task: task, owner: owner)
    mail.deliver_later
  end
end
