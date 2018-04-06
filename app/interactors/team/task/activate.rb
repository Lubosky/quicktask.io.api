class Team::Task::Activate < ApplicationInteractor
  object :task

  def execute
    transaction do
      task.activate!
    end
    task
  end
end
