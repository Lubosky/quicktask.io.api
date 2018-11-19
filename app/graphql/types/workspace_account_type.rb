Types::WorkspaceAccountType = GraphQL::ObjectType.define do
  name 'WorkspaceAccount'
  description 'Data of a workspace account.'

  field :id, !types.ID, 'Globally unique ID of the workspace user.'
  field :uuid, !types.String, 'A unique substitute for a workspace user ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'
  field :user_id, !types.ID, 'Globally unique ID of the user.'

  field :account_type, !types.String, 'Type of the workspace user.'
  field :account, Types::AccountType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(WorkspaceAccount, :account).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :first_name, types.String, 'The first name of the workspace user.'
  field :last_name, types.String, 'The last name of the workspace user.'
  field :status, types.String, 'Workspace account’s status. Enum: Pending, Active, Deactivated.'
  field :currency, Types::CurrencyType, ''
  field :permission_level, types.String, ''
  field :permissions, types[!types.String], ''

  field :project_sort_option, types.String, ''
  field :project_view_type, types.String, ''
  field :task_view_type, types.String, ''

  field :created_at, Types::DateTimeType, 'The time at which this workspace account’s account was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this workspace account’s account was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this workspace account’s account was deleted.'
end
