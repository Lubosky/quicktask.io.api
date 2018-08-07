class Team::Todo::Uncomplete < ApplicationInteractor
  object :todo

  def execute
    transaction do
      todo.uncomplete!
    end
    todo
  end
end
