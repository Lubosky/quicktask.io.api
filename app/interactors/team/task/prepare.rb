class Team::Task::Prepare < ApplicationInteractor
  object :task

  def execute
    transaction do
      task.prepare!
    end
    task
  end
end
