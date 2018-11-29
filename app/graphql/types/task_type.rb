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
  field :source_language, Types::LanguageType do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :source_language).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :target_language_id, types.ID, 'Globally unique ID of the language.'
  field :target_language, Types::LanguageType do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :target_language).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :task_type_id, types.ID, 'Globally unique ID of the task type.'
  field :task_type, Types::TaskTypeType do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :task_type).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :unit_id, types.ID, 'Globally unique ID of the unit.'
  field :unit, Types::UnitType do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :unit).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :dependent_tasks, types[Types::TaskType] do
    description ''

    before_scope ->(obj, _args, _ctx) {
      AssociationLoader.for(Task, :project).load(obj).then do |project|
        workflow_type = project.workflow_type.to_sym

        return [] if workflow_type == :none
        if workflow_type == :custom
          AssociationLoader.for(Task, :dependent_tasks).load(obj)
        else
          position = { position: obj.position + 1 }
          RecordLoader.for(Task, column: :tasklist_id, where: position).load(obj.tasklist_id)
        end
      end
    }

    resolve ->(collection, _args, _ctx) { result.then { |collection| collection.is_a?(Array) ? collection : Array.wrap(collection) } }
  end

  field :precedent_tasks, types[Types::TaskType] do
    description ''

    before_scope ->(obj, _args, _ctx) {
      AssociationLoader.for(Task, :project).load(obj).then do |project|
        workflow_type = project.workflow_type.to_sym

        return [] if workflow_type == :none
        if workflow_type == :custom
          AssociationLoader.for(Task, :precedent_tasks).load(obj)
        else
          position = { position: obj.position - 1 }
          RecordLoader.for(Task, column: :tasklist_id, where: position).load(obj.tasklist_id)
        end
      end
    }

    resolve ->(result, _args, _ctx) { result.then { |collection| collection.is_a?(Array) ? collection : Array.wrap(collection) } }
  end

  field :prior_task, Types::TaskType do
    description ''

    before_scope ->(obj, args, _ctx) {
      if obj.position.zero?
        return nil
      else
        params = { position: obj.position - 1 }
        RecordLoader.for(Task, column: :tasklist_id, where: params).load(obj.tasklist_id)
      end
    }

    resolve ->(resource, _args, _ctx) {
      resource
    }
  end

  field :next_task, Types::TaskType do
    description ''

    before_scope ->(obj, args, _ctx) {
      params = { position: obj.position + 1 }
      RecordLoader.for(Task, column: :tasklist_id, where: params).load(obj.tasklist_id)
    }

    resolve ->(resource, _args, _ctx) {
      resource
    }
  end

  field :title, types.String, 'The title of the task.'
  field :description, types.String, 'The description of the task.'
  field :classification, types.String, 'The classification of the task.'
  field :color, Types::ColorType, 'The color of the task.'
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

  field :equipment_needed, types.Boolean, ''

  field :task_meta, Types::JSONType do
    description ''
    property :metadata
  end

  field :created_at, Types::DateTimeType, 'The time at which this task was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this task was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this task was deleted.'

  field :parent, Types::ProjectableType do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :project).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :tags, types[!Types::TagType] do
    description ''
    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Task, :tags).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :todos, types[!Types::TodoType] do
    description ''
    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Task, :todos).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :potential_assignees, types[!Types::AccountType] do
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

  field :invitees, types[!Types::ContractorType] do
    description ''
    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Task, :invitees).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :assignee, Types::AccountType do
    description ''
    before_scope ->(obj, _args, _ctx) {
      AssociationLoader.for(Task, :assignment).load(obj).then do |assignment|
        if assignment
          if assignment.assignee_type == 'Contractor'
            AssociationLoader.for(Task, :contractor_assignee).load(obj)
          elsif assignment.assignee_type == 'TeamMember'
            AssociationLoader.for(Task, :team_member_assignee).load(obj)
          end
        end
      end
    }

    resolve ->(resource, _args, _ctx) { resource }
  end

  field :hand_offs, types[!Types::HandOffType] do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :hand_offs).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :hand_off, Types::HandOffType do
    description ''
    argument :hand_off_id, types.ID, 'Globally unique ID of the hand-off.'
    resource ->(obj, args, _ctx) { obj.hand_offs.find(args[:hand_off_id]) }, pass_through: true
    authorize! ->(hand_off, _args, ctx) { ::Team::HandOffPolicy.new(ctx[:current_account], hand_off).show? }
    resolve ->(hand_off, _args, _ctx) { hand_off }
  end

  field :pending_hand_offs, types[!Types::HandOffType] do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :pending_hand_offs).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :assignment, Types::HandOffType do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :assignment).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :purchase_orders, types[!Types::PurchaseOrderType] do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :purchase_orders).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :accepted_purchase_order, Types::PurchaseOrderType do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :accepted_purchase_order).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :notes, types[!Types::NoteType] do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Task, :notes).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end
end
