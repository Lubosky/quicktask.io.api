class Team::Task::Uncomplete < ApplicationInteractor
  object :task

  def execute
    transaction do
      task.uncomplete!
    end
    task
  end
end
