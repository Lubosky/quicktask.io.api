class Team::Task::MoveTask < ApplicationInteractor
  object :task

  integer :position, default: 0
  integer :tasklist_id

  def execute
    transaction do
      unless task.move_task(given_attributes.except(:task))
        errors.merge!(task.errors)
        rollback
      end
    end
    task
  end
end




