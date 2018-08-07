class Team::Todo::MoveTodo < ApplicationInteractor
  object :todo

  integer :position, default: 0

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
