class Team::Todo::Complete < ApplicationInteractor
  object :todo

  def execute
    transaction do
      todo.complete!
    end
    todo
  end
end
