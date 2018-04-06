class Team::Task::Archive < ApplicationInteractor
  object :task

  def execute
    transaction do
      task.archive!
    end
    task
  end
end
