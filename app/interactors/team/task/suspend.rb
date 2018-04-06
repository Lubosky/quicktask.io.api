class Team::Task::Suspend < ApplicationInteractor
  object :task

  def execute
    transaction do
      task.suspend!
    end
    task
  end
end
