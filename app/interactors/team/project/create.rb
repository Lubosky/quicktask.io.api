class Team::Project::Create < ApplicationInteractor
  integer :client_id
  integer :project_group_id, default: nil

  string :name
  string :description, default: nil
  string :identifier, default: nil

  date_time :start_date, default: nil
  date_time :due_date, default: nil
  date_time :completed_date, default: nil

  boolean :automated_workflow, default: true
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
    @project ||= current_workspace.projects.build(project_attributes)
  end

  def project_attributes
    attributes.tap do |hash|
      hash[:owner] = current_workspace_user
    end
  end
end