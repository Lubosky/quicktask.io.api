Types::WorkspaceUserType = GraphQL::ObjectType.define do
  name 'WorkspaceUser'
  description 'Data of a workspace member.'

  field :id, !types.ID do
    description 'Globally unique ID of the workspace user.'
  end

  field :uuid, !types.String do
    description 'A unique substitute for a User ID.'
  end

  field :type, !types.String do
    description ''
    property :member_type
  end

  field :workspaceId, !types.ID do
    description 'Globally unique ID of the workspace.'
    property :workspace_id
  end

  field :userId, !types.ID do
    description 'Globally unique ID of the user.'
    property :user_id
  end

  field :status, types.String do
    description 'Workspace member’s status. Enum: Pending, Active, Deactivated.'
  end

  field :currency, !types.String do
    description ''
  end

  field :permissionLevel, !types.String do
    description ''
    property :permission_level
  end

  field :permissions, !types[!types.String] do
    description ''
  end

  field :createdAt, Types::DateTimeType do
    description 'The time at which this user’s account was created.'
    property :created_at
  end

  field :updatedAt, Types::DateTimeType do
    description 'The time at which this user’s account was last modified.'
    property :updated_at
  end

  field :deletedAt, Types::DateTimeType do
    description 'The time at which this user’s account was deleted.'
    property :deleted_at
  end
end
