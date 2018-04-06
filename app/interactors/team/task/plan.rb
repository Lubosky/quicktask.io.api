class Team::Task::Plan < ApplicationInteractor
  object :task

  def execute
    transaction do
      task.plan!
    end
    task
  end
end
