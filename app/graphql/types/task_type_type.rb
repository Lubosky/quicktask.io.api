Types::TaskTypeType = GraphQL::ObjectType.define do
  name 'TaskType'
  description ''

  field :id, !types.ID, 'Globally unique ID of the task type.'
  field :uuid, !types.String, 'A unique substitute for a task type ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :name, types.String, 'The name of the task type.'
  field :classification, types.String, 'The classification of the task.'
  field :billable, types.Boolean, ''
  field :internal, types.Boolean, ''
  field :preferred, types.Boolean, ''
  field :net_rate_scheme, types.Boolean, ''
  field :hourly_cost, Types::BigDecimalType, ''

  field :created_at, Types::DateTimeType, 'The time at which this task was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this task was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this task was deleted.'
end
