class Team::Task::Cancel < ApplicationInteractor
  object :task

  def execute
    transaction do
      task.cancel!
    end
    task
  end
end
