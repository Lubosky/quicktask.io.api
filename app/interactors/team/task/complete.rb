class Team::Task::Complete < ApplicationInteractor
  object :task

  def execute
    transaction do
      task.complete!
    end
    task
  end
end
