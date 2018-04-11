Types::Team::TasklistType = GraphQL::ObjectType.define do
  name 'TeamTasklist'
  description ''

  field :id, !types.ID, 'Globally unique ID of the tasklist.'
  field :uuid, !types.String, 'A unique substitute for a tasklisty ID.'

  field :project_id, !types.ID, 'Globally unique ID of the project.'
  field :owner_id, !types.ID, 'Globally unique ID of the owner.'
  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :title, types.String, ''
  field :task_count, !types.Int, ''
  field :completed_task_count, !types.Int, ''
  field :position, !types.Int, ''

  field :created_at, Types::DateTimeType, 'The time at which this tasklist was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this tasklist was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this tasklist was deleted.'

  field :tasks do
    type types[!Types::Team::TaskType]
    description ''

    resolve ->(obj, _args, _ctx) {
      AssociationLoader.for(Tasklist, :tasks).load(obj)
    }
  end
end
