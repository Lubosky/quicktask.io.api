class Team::Project::Plan < ApplicationInteractor
  object :project

  def execute
    transaction do
      project.plan!
    end
    project
  end
end
