class Team::Project::Update < ApplicationInteractor
  object :project

  integer :client_id, default: nil
  integer :owner_id, default: nil
  integer :project_group_id, default: nil

  string :name, default: nil
  string :description, default: nil
  string :identifier, default: nil
  string :workflow_type, default: nil

  date_time :start_date, default: nil
  date_time :due_date, default: nil
  date_time :completed_date, default: nil

  boolean :internal, default: false

  def execute
    transaction do
      unless project.update(given_attributes.except(:project))
        errors.merge!(project.errors)
        rollback
      end
    end
    project
  end
end
