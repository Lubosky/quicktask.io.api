class SerializableTask < SerializableBase
  type :task

  attribute :workspace_id
  attribute :project_id
  attribute :tasklist_id
  attribute :owner_id

  attribute :source_language_id
  attribute :target_language_id
  attribute :task_type_id
  attribute :unit_id

  attribute :title
  attribute :description
  attribute :color
  attribute :status
  attribute :start_date
  attribute :due_date
  attribute :completed_date

  attribute :unit_count
  attribute :completed_unit_count
  attribute :attachment_count
  attribute :comment_count
  attribute :position

  attribute :task_data
  attribute :metadata
end
