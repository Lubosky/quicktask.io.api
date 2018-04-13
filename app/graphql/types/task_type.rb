Types::TaskType = GraphQL::ObjectType.define do
  name 'Task'
  description ''

  field :id, !types.ID, 'Globally unique ID of the task.'
  field :uuid, !types.String, 'A unique substitute for a task ID.'

  field :owner_id, types.ID, 'Globally unique ID of the owner.'
  field :project_id, !types.ID, 'Globally unique ID of the project.'
  field :tasklist_id, !types.ID, 'Globally unique ID of the tasklist.'
  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :source_language_id, types.ID, 'Globally unique ID of the language.'
  field :target_language_id, types.ID, 'Globally unique ID of the language.'
  field :task_type_id, types.ID, 'Globally unique ID of the task type.'
  field :unit_id, types.ID, 'Globally unique ID of the unit.'

  field :title, types.String, 'The title of the task.'
  field :description, types.String, 'The description of the task.'
  field :color, types.String, 'The color of the task.'
  field :status, types.String, 'The status of the task.'
  field :start_date, Types::DateTimeType, ''
  field :due_date, Types::DateTimeType, 'Due date of the task.'
  field :completed_date, Types::DateTimeType, 'Completed date of the task.'
  field :unit_count, types.Int, 'Count of the task units.'
  field :completed_unit_count, types.Int, 'Count of the completed task units.'
  field :attachment_count, types.Int, 'Count of the task attachments.'
  field :comment_count, types.Int, 'Count of the task comments.'
  field :position, !types.Int, ''

  field :created_at, Types::DateTimeType, 'The time at which this task was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this task was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this task was deleted.'

  field :todos do
    type types[!Types::TodoType]
    description ''

    resolve ->(obj, _args, _ctx) {
      AssociationLoader.for(Task, :todos).load(obj)
    }
  end
end
