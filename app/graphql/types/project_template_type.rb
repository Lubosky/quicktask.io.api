Types::ProjectTemplateType = GraphQL::ObjectType.define do
  name 'ProjectTemplate'
  description ''

  field :id, !types.ID, 'Globally unique ID of the project template.'
  field :uuid, !types.String, 'A unique substitute for a project template ID.'

  field :owner_id, types.ID, 'Globally unique ID of the owner.'
  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :template_name, types.String, 'Name of the project template.'
  field :template_description, types.String, 'Description of the project template.'
  field :system_template, types.Boolean, ''
  field :workflow_template, types.String, ''

  field :workflow_type, Types::WorkflowType, ''

  field :identifier, types.String, ''

  field :description, types.String, 'Description of the created project.'

  field :start_date, Types::DateTimeType, 'Start date of the created project.'
  field :due_date, Types::DateTimeType, 'Due date of the created project.'

  field :task_count, types.Int, 'Count of the tasks.'

  field :internal, types.Boolean, 'Indicates whether the created project will be for internal or for external client.'


  field :tasklist_ids, types[types.String] do
    description ''

    before_scope ->(obj, _args, _ctx) {
      AssociationLoader.for(Project::Template, :tasklists).load(obj).then(&:ids)
    }
    resolve ->(ids, _args, _ctx) { ids }
  end

  field :task_ids, Types::JSONType do
    description ''

    before_scope ->(obj, _args, ctx) {
      Promise.all([
        AssociationLoader.for(Project::Template, :tasklists).load(obj),
        AssociationLoader.for(Project::Template, :tasks).load(obj),
      ]).then do |result|
        keys = result.first.ids
        tasks = result.last.group_by(&:tasklist_id)

        keys.each_with_object({}) do |key, hash|
          hash[key] = tasks[key] ? tasks[key].map { |task| task.id.to_s } : []
        end
      end
    }
    resolve ->(result, _args, _ctx) { result.then { |values| values } }
  end


  field :created_at, Types::DateTimeType, 'The time at which this project was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this project was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this project was deleted.'

  field :owner, Types::TeamMemberType do
    description ''

    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Project::Template, :owner).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :tasklists do
    type types[Types::TasklistType]
    description ''

    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Project::Template, :tasklists).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :tasks do
    type types[Types::TaskType]
    description ''

    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Project::Template, :tasks).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end


  field :task, Types::TaskType do
    description ''

    argument :task_id, types.ID, 'Globally unique ID of the task.'

    resource ->(obj, args, _ctx) { obj.tasks.find(args[:task_id]) }, pass_through: true
    authorize! ->(task, _args, ctx) { ::Team::TaskPolicy.new(ctx[:current_account], task).show? }
    resolve ->(task, _args, _ctx) { task }
  end
end
