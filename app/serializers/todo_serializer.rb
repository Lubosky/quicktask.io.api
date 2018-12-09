class TodoSerializer < BaseSerializer
  set_id    :id
  set_type  :todo

  attributes :assignee_id,
             :owner_id,
             :task_id,
             :workspace_id,
             :title,
             :due_date,
             :completed_date,
             :completed,
             :todo_data

  belongs_to :assignee
  belongs_to :owner
  belongs_to :task
end
