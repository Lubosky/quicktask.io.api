class Team::Project::Nullify < ApplicationInteractor
  object :project

  def execute
    transaction do
      project.nullify!
    end
    project
  end
end
