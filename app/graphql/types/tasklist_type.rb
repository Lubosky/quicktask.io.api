Types::TasklistType = GraphQL::ObjectType.define do
  name 'Tasklist'
  description ''

  field :id, !types.ID, 'Globally unique ID of the tasklist.'
  field :uuid, !types.String, 'A unique substitute for a tasklisty ID.'

  field :owner_id, types.ID, 'Globally unique ID of the owner.'
  field :project_id, !types.ID, 'Globally unique ID of the project.'
  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :title, types.String, ''
  field :task_count, types.Int, ''
  field :completed_task_count, types.Int, ''
  field :position, !types.Int, ''

  field :created_at, Types::DateTimeType, 'The time at which this tasklist was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this tasklist was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this tasklist was deleted.'

  field :parent, Types::ProjectableType do
    description ''

    before_scope ->(obj, _args, _ctx) {
      AssociationLoader.for(Tasklist, :project).load(obj)
    }

    resolve ->(resource, _args, _ctx) { resource }
  end

  field :tasks do
    type types[!Types::TaskType]
    description ''

    resolve ->(obj, _args, _ctx) { AssociationLoader.for(Tasklist, :tasks).load(obj) }
  end
end
