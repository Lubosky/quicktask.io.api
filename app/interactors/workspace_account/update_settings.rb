class WorkspaceAccount::UpdateSettings < ApplicationInteractor
  object :workspace_account

  string :project_sort_option, default: 'due_date'
  string :project_view_type, default: 'grid'
  string :task_view_type, default: 'column'

  def execute
    transaction do
      unless workspace_account.update(given_attributes.except(:workspace_account))
        errors.merge!(workspace_account.errors)
        rollback
      end
    end
    workspace_account
  end
end
