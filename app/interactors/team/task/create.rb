class Team::Task::Create < ApplicationInteractor
  object :tasklist

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

  def execute
    transaction do
      unless task.save
        errors.merge!(task.errors)
        rollback
      end
    end
    task
  end

  private

  def task
    @task ||= tasklist.tasks.build(task_attributes)
  end

  def task_attributes
    attributes.tap do |hash|
      hash[:owner] = current_workspace_user
    end
  end
end
