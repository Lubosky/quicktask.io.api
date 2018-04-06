class SerializableTasklist < SerializableBase
  type :tasklist

  attribute :project_id
  attribute :owner_id
  attribute :workspace_id
  attribute :title
  attribute :task_count
  attribute :completed_task_count
  attribute :position
  attribute :created_at

  has_many :tasks
end
