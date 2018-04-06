class Team::Task::Destroy < ApplicationInteractor
  object :task

  def execute
    task.destroy
  end
end
