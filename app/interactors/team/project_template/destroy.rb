class Team::ProjectTemplate::Destroy < ApplicationInteractor
  object :project_template, class: Project::Template

  def execute
    project_template.destroy
  end
end
