class Team::ProjectTemplate::Update < ApplicationInteractor
  object :project_template, class: Project::Template

  integer :owner_id, default: nil

  string :template_name, default: nil
  string :template_description, default: nil
  string :workflow_type, default: nil

  string :description, default: nil
  string :identifier, default: nil

  boolean :internal, default: false

  def execute
    transaction do
      unless project_template.update(given_attributes.except(:project_template))
        errors.merge!(project_template.errors)
        rollback
      end
    end
    project_template
  end
end
