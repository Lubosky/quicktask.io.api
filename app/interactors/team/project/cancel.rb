class Team::Project::Cancel < ApplicationInteractor
  object :project

  def execute
    transaction do
      project.cancel!
    end
    project
  end
end
