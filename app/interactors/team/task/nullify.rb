class Team::Task::Nullify < ApplicationInteractor
  object :task

  def execute
    transaction do
      task.nullify!
    end
    task
  end
end
