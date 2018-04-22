class WorkspaceUser::UpdateSettings < ApplicationInteractor
  object :workspace_user

  string :project_sort_option, default: 'due_date'
  string :project_view_type, default: 'grid'
  string :task_view_type, default: 'column'

  def execute
    transaction do
      unless workspace_user.update(given_attributes.except(:workspace_user))
        errors.merge!(workspace_user.errors)
        rollback
      end
    end
    workspace_user
  end
end
