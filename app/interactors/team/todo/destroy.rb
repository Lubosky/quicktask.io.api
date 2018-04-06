class Team::Todo::Destroy < ApplicationInteractor
  object :todo

  def execute
    todo.destroy
  end
end
