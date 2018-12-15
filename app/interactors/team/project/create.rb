class Team::Project::Create < ApplicationInteractor
  integer :client_id
  integer :project_group_id, default: nil
  integer :template_id, default: nil

  string :name
  string :description, default: nil
  string :identifier, default: nil
  string :workflow_type, default: nil

  date_time :start_date, default: nil
  date_time :due_date, default: nil
  date_time :completed_date, default: nil

  boolean :internal, default: false

  def execute
    transaction do
      unless project.save
        errors.merge!(project.errors)
        rollback
      end
    end
    project
  end

  private

  def project
    if template.blank?
      @project ||= current_workspace.projects.build(project_attributes.except(:template_id))
    else
      @project ||= Template::ProjectCloner.call(template, template_attributes)
    end
  end

  def template
    @project_template ||= current_workspace.project_templates.find_by(id: template_id)
  end

  def project_attributes
    attributes.tap do |hash|
      hash[:owner] = current_account.profile
    end
  end

  def template_attributes
    project_attributes.slice(
      :owner,
      :client_id,
      :project_group_id,
      :name,
      :description,
      :workflow_type,
      :internal
    )
  end
end
