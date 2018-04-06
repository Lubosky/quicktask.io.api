class Team::Project::Destroy < ApplicationInteractor
  object :project

  def execute
    project.destroy
  end
end
