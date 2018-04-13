Types::TodoType = GraphQL::ObjectType.define do
  name 'Todo'
  description ''

  field :id, !types.ID, 'Globally unique ID of the todo.'
  field :uuid, !types.String, 'A unique substitute for a todo ID.'

  field :assignee_id, types.ID, 'Globally unique ID of the assignee.'
  field :owner_id, types.ID, 'Globally unique ID of the owner.'
  field :task_id, !types.ID, 'Globally unique ID of the task.'
  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :title, types.String, 'The title of the todo.'
  field :due_date, Types::DateTimeType, 'Due date of the todo.'
  field :completed_date, Types::DateTimeType, 'Completed date of the todo.'
  field :completed, types.Boolean, 'Indicates whether the todo item is completed or not. False by default.'
  field :position, !types.Int, ''

  field :created_at, Types::DateTimeType, 'The time at which this todo was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this todo was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this todo was deleted.'
end
