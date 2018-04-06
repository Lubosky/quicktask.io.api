class Team::Project::Suspend < ApplicationInteractor
  object :project

  def execute
    transaction do
      project.suspend!
    end
    project
  end
end
