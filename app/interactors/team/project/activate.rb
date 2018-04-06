class Team::Project::Activate < ApplicationInteractor
  object :project

  def execute
    transaction do
      project.activate!
    end
    project
  end
end
