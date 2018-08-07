class Team::Task::Reset < ApplicationInteractor
  object :task

  def execute
    transaction do
      task.reset!
    end
    task
  end
end
