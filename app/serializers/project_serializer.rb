class ProjectSerializer < BaseSerializer
  set_id    :id
  set_type  :project

  attributes :workspace_id,
             :client_id,
             :owner_id,
             :project_group_id,
             :name,
             :description,
             :identifier,
             :status,
             :start_date,
             :due_date,
             :completed_date,
             :task_count,
             :completed_task_count,
             :completion_ratio,
             :billed,
             :settings,
             :notification_settings,
             :metadata

  belongs_to :client
  belongs_to :owner
  belongs_to :project_group

  has_many :tasklists
  has_many :tasks
end
