class Team::Project::Prepare < ApplicationInteractor
  object :project

  def execute
    transaction do
      project.prepare!
    end
    project
  end
end
