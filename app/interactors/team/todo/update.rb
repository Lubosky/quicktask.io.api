class Team::Todo::Update < ApplicationInteractor
  object :todo

  integer :assignee_id, default: nil

  string :title, default: nil

  date_time :due_date, default: nil
  date_time :completed_date, default: nil

  boolean :completed, default: false

  def execute
    transaction do
      unless todo.update(given_attributes.except(:todo))
        errors.merge!(todo.errors)
        rollback
      end
    end
    todo
  end
end
