Types::ProjectType = GraphQL::ObjectType.define do
  name 'Project'
  description 'A project represents a prioritized list of tasks or a board with columns of tasks represented as cards.'

  field :id, !types.ID, 'Globally unique ID of the project.'
  field :uuid, !types.String, 'A unique substitute for a project ID.'

  field :client_id, types.ID, 'Globally unique ID of the client.'
  field :owner_id, types.ID, 'Globally unique ID of the owner.'
  field :project_group_id, types.ID, 'Globally unique ID of the project group.'
  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :identifier, types.String, ''
  field :name, types.String, 'Name of the project'
  field :description, types.String, 'Description of the project.'
  field :status, types.String, 'The status of the project.'
  field :start_date, Types::DateTimeType, 'Start date of the project.'
  field :due_date, Types::DateTimeType, 'Due date of the project.'
  field :completed_date, Types::DateTimeType, 'Completed date of the project.'
  field :task_count, types.Int, 'Count of the tasks.'
  field :completed_task_count, types.Int, 'Count of the completed tasks.'
  field :completion_ratio, types.Float, ''
  field :billed, types.Boolean, 'Indicates whether the project is billed or not.'
  field :automated_workflow, types.Boolean, ''
  field :internal, types.Boolean, 'Indicates whether this project is internal or for external client.'

  field :ordered_tasklist_ids, types[types.String], ''
  field :ordered_task_ids, Types::JSONType, ''

  field :created_at, Types::DateTimeType, 'The time at which this project was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this project was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this project was deleted.'

  field :owner, Types::TeamMemberType do
    description ''

    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Project::Regular, :owner).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :hand_offs do
    type types[Types::HandOffType]
    description ''

    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Project::Regular, :hand_offs).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :tasklists do
    type types[Types::TasklistType]
    description ''

    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Project::Regular, :tasklists).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :tasks do
    type types[Types::TaskType]
    description ''

    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Project::Regular, :tasks).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end


  field :task, Types::TaskType do
    description ''

    argument :task_id, types.ID, 'Globally unique ID of the task.'

    resource ->(obj, args, _ctx) { obj.tasks.find(args[:task_id]) }, pass_through: true
    authorize! ->(task, _args, ctx) { ::Team::TaskPolicy.new(ctx[:current_workspace_user], task).show? }
    resolve ->(task, _args, _ctx) { task }
  end
end
