class Team::Project::Archive < ApplicationInteractor
  object :project

  def execute
    transaction do
      project.archive!
    end
    project
  end
end
