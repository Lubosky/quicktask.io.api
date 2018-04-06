class SerializableTodo < SerializableBase
  type :todo

  attribute :assignee_id
  attribute :owner_id
  attribute :task_id
  attribute :workspace_id

  attribute :title
  attribute :due_date
  attribute :completed_date

  attribute :completed

  attribute :todo_data

  belongs_to :assignee
  belongs_to :owner
  belongs_to :task
end
