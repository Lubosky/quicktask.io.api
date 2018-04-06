class SerializableProject < SerializableBase
  type :project

  attribute :workspace_id
  attribute :client_id
  attribute :owner_id
  attribute :project_group_id

  attribute :name
  attribute :description
  attribute :identifier
  attribute :status
  attribute :start_date
  attribute :due_date
  attribute :completed_date
  attribute :task_count
  attribute :completed_task_count
  attribute :completion_ratio

  attribute :billed

  attribute :settings
  attribute :notification_settings
  attribute :metadata

  belongs_to :client
  belongs_to :owner
  belongs_to :project_group

  has_many :tasklists
  has_many :tasks
end
