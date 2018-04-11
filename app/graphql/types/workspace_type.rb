Types::WorkspaceType = GraphQL::ObjectType.define do
  name 'Workspace'
  description 'A workspace is the highest-level organizational unit. All projects and tasks have an associated workspace.'

  field :id, !types.ID, 'Globally unique ID of the workspace.'
  field :uuid, !types.String, 'A unique substitute for a workspace ID.'

  field :name, !types.String, 'The name of the workspace.'
  field :business_name, types.String, 'The business name of the workspace.'
  field :status, !types.String, 'Workspace’s status. Enum: Pending, Active, Deactivated.'
  field :team_member_count, !types.Int, ''
  field :team_member_limit, !types.Int, ''

  field :owner, Types::UserType do
    description ''
    resolve ->(obj, _args, _ctx) { obj.owner }
  end

  field :membership, Types::MembershipType do
    description ''
    resolve ->(obj, _args, _ctx) { obj.membership }
  end

  field :userRoles do
    type !types[!Types::WorkspaceUserType]
    description ''

    before_scope ->(obj, _args, ctx) { obj.members.where(user_id: ctx[:current_user].id) }
    resolve ->(collection, _args, _ctx) { collection }
  end
end
