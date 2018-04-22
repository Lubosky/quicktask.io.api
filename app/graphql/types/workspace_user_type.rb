Types::WorkspaceUserType = GraphQL::ObjectType.define do
  name 'WorkspaceUser'
  description 'Data of a workspace member.'

  field :id, !types.ID, 'Globally unique ID of the workspace user.'
  field :uuid, !types.String, 'A unique substitute for a workspace user ID.'

  field :type, !types.String do
    description 'Type of the workspace user.'
    property :member_type
  end

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'
  field :user_id, !types.ID, 'Globally unique ID of the user.'

  field :first_name, types.String, 'The first name of the workspace user.'
  field :last_name, types.String, 'The last name of the workspace user.'
  field :status, types.String, 'Workspace member’s status. Enum: Pending, Active, Deactivated.'
  field :currency, types.String, ''
  field :permission_level, types.String, ''
  field :permissions, types[!types.String], ''

  field :project_sort_option, types.String, ''
  field :project_view_type, types.String, ''
  field :task_view_type, types.String, ''

  field :created_at, Types::DateTimeType, 'The time at which this workspace member’s account was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this workspace member’s account was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this workspace member’s account was deleted.'
end
