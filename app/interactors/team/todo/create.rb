class Team::Todo::Create < ApplicationInteractor
  object :task

  integer :assignee_id, default: nil

  string :title

  date_time :due_date, default: nil
  date_time :completed_date, default: nil

  boolean :completed, default: false

  def execute
    transaction do
      unless todo.save
        errors.merge!(todo.errors)
        rollback
      end
    end
    todo
  end

  private

  def todo
    @todo ||= task.todos.build(todo_attributes)
  end

  def todo_attributes
    attributes.tap do |hash|
      hash[:owner] = current_workspace_user
    end
  end
end
