# frozen_string_literal: true

class ExpiringHandOffsCheckerJob
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform
    task_ids = Task.with_expiring_hand_offs.ids
    task_ids.each do |task_id|
      HandOffExpiryNotifierJob.perform_async(task_id)
    end
  end
end
