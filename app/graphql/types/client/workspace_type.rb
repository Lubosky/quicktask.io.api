Types::Client::WorkspaceType = GraphQL::ObjectType.define do
  name 'ClientWorkspace'
  description 'A workspace is the highest-level organizational unit. All projects and tasks have an associated workspace.'

  field :id, !types.ID, 'Globally unique ID of the workspace.'
  field :uuid, !types.String, 'A unique substitute for a workspace ID.'

  field :name, !types.String, 'The name of the workspace.'
  field :business_name, types.String, 'The business name of the workspace.'
  field :status, !types.String, 'Workspace’s status. Enum: Pending, Active, Deactivated.'
end
