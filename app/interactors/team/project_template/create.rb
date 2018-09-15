class Team::ProjectTemplate::Create < ApplicationInteractor
  string :template_name
  string :template_description, default: nil

  string :description, default: nil
  string :identifier, default: nil

  boolean :automated_workflow, default: true
  boolean :internal, default: false

  def execute
    transaction do
      unless project_template.save
        errors.merge!(project_template.errors)
        rollback
      end
    end
    project_template
  end

  private

  def project_template
    @project_template ||= current_workspace.project_templates.build(project_template_attributes)
  end

  def project_template_attributes
    attributes.tap do |hash|
      hash[:owner] = current_workspace_user.member
    end
  end
end
