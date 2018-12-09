class TasklistSerializer < BaseSerializer
  set_id    :id
  set_type  :tasklist

  attributes :project_id,
             :owner_id,
             :workspace_id,
             :title,
             :task_count,
             :completed_task_count,
             :position,
             :created_at

  has_many :tasks
end
