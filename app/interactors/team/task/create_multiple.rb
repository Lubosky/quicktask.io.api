class Team::Task::CreateMultiple < ApplicationInteractor
  object :tasklist

  array :tasks do
    hash do
      integer :source_language_id, default: nil
      integer :target_language_id, default: nil
      integer :task_type_id, default: nil
      integer :unit_id, default: nil

      string :title
      string :description, default: nil
      string :color, default: nil

      date_time :start_date, default: nil
      date_time :due_date, default: nil
      date_time :completed_date, default: nil
    end
  end

  def execute
    transaction do
      unless collection.each(&:save)
        errors.merge!(collection.each(&:errors))
        rollback
      end
    end
    collection
  end

  private

  def collection
    @collection ||= tasklist.tasks.build(tasks_attributes)
  end

  def tasks_attributes
    attributes[:tasks].each do |task_attributes|
      task_attributes.tap do |hash|
        hash[:owner] = current_account.profile
      end
    end
  end
end
