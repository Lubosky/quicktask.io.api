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
  field :source_language_name, types.String, ''
  field :source_language_code, types.String, ''
  field :source_language, Types::LanguageType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :source_language).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :target_language_id, types.ID, 'Globally unique ID of the language.'
  field :target_language_name, types.String, ''
  field :target_language_code, types.String, ''
  field :target_language, Types::LanguageType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :target_language).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :task_type_id, types.ID, 'Globally unique ID of the task type.'
  field :task_type_name, types.String, ''
  field :task_type_classification, types.String, ''
  field :task_type, Types::TaskTypeType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :task_type).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :unit_id, types.ID, 'Globally unique ID of the unit.'
  field :unit_name, types.String, ''
  field :unit, Types::UnitType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :unit).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :following_task, Types::TaskType, ''
  field :precedent_task, Types::TaskType, ''

  field :title, types.String, 'The title of the task.'
  field :description, types.String, 'The description of the task.'
  field :classification, types.String, 'The classification of the task.'
  field :color, types.String, 'The color of the task.'
  field :status, types.String, 'The status of the task.'
  field :start_date, Types::DateTimeType, ''
  field :due_date, Types::DateTimeType, 'Due date of the task.'
  field :completed_date, Types::DateTimeType, 'Completed date of the task.'
  field :unit_count, types.Float, 'Count of the task units.'
  field :completed_unit_count, types.Float, 'Count of the completed task units.'
  field :attachment_count, types.Int, 'Count of the task attachments.'
  field :comment_count, types.Int, 'Count of the task comments.'
  field :position, !types.Int, ''

  field :is_assignable, types.Boolean do
    description ''
    property :assignable?
  end

  field :task_meta, Types::JSONType do
    description ''
    property :task_data
  end

  field :created_at, Types::DateTimeType, 'The time at which this task was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this task was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this task was deleted.'

  field :project, Types::ProjectType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :project).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :todos do
    type types[!Types::TodoType]
    description ''

    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Task, :todos).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :potential_assignees do
    type types[!Types::MemberType]
    description ''

    before_scope ->(obj, _args, _ctx) {
      return [] unless obj.assignable?

      RecordLoader.for(TaskType).load(obj.task_type_id).then do |_|
        if obj.other_task?
          RecordLoader.for(Workspace).load(obj.workspace_id).then do |workspace|
            AssociationLoader.for(Workspace, :team_members).load(workspace)
          end
        else
          RecordLoader.for(Contractor).load_many(
            PotentialAssigneesQuery.build_query(obj).ids
          )
        end
      end
    }

    resolve ->(collection, _args, _ctx) { collection }
  end
end
