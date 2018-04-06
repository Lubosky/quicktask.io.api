class Team::Task::Update < ApplicationInteractor
  object :tasklist

  integer :owner_id, default: nil
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
      unless task.update(given_attributes.except(:task))
        errors.merge!(task.errors)
        rollback
      end
    end
    task
  end
end
