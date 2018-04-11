Types::Team::ProjectType = GraphQL::ObjectType.define do
  name 'TeamProject'
  description 'A project represents a prioritized list of tasks or a board with columns of tasks represented as cards.'

  field :id, !types.ID, 'Globally unique ID of the project.'
  field :uuid, !types.String, 'A unique substitute for a project ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'
  field :client_id, !types.ID, 'Globally unique ID of the client.'
  field :owner_id, !types.ID, 'Globally unique ID of the owner.'
  field :project_group_id, types.ID, 'Globally unique ID of the project group.'

  field :identifier, types.String, ''
  field :name, !types.String, 'Name of the project'
  field :description, types.String, 'Description of the project.'
  field :status, types.String, 'The status of the project.'
  field :start_date, Types::DateTimeType, 'Start date of the project.'
  field :due_date, Types::DateTimeType, 'Due date of the project.'
  field :completed_date, Types::DateTimeType, 'Completed date of the project.'
  field :task_count, !types.Int, 'Count of the tasks.'
  field :completed_task_count, !types.Int, 'Count of the completed tasks.'
  field :completion_ratio, !types.Float, ''
  field :billed, !types.Boolean, 'Indicates whether the project is billed or not.'
  field :automated_workflow, !types.Boolean, ''
  field :internal, !types.Boolean, 'Indicates whether this project is internal or for external client.'

  field :created_at, Types::DateTimeType, 'The time at which this project was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this project was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this project was deleted.'

  field :owner, !Types::WorkspaceUserType do
    description ''

    resolve ->(obj, _args, _ctx) {
      AssociationLoader.for(Project, :owner).load(obj)
    }
  end

  field :tasklists do
    type types[Types::Team::TasklistType]
    description ''

    resolve ->(obj, _args, _ctx) {
      AssociationLoader.for(Project, :tasklists).load(obj)
    }
  end
end
