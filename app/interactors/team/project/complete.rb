class Team::Project::Complete < ApplicationInteractor
  object :project

  def execute
    transaction do
      project.complete!
    end
    project
  end
end
