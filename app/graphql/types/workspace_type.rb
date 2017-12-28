Types::WorkspaceType = GraphQL::ObjectType.define do
  name 'Workspace'
  description 'A workspace is the highest-level organizational unit. All projects and tasks have an associated workspace.'

  field :id, !types.ID do
    description 'Globally unique ID of the workspace.'
  end

  field :uuid, !types.String do
    description 'A unique substitute for a Workspace ID.'
  end

  field :slug, !types.String do
    description 'The URL slug of the workspace.'
  end

  field :name, !types.String do
    description 'The name of the workspace.'
  end

  field :businessName, types.String do
    description 'The business name of the workspace.'
    property :business_name
  end

  field :status, !types.String do
    description 'Workspace’s status. Enum: Pending, Active, Deactivated.'
  end

  field :teamMemberCount, !types.Int do
    description ''
    property :team_member_count
  end

  field :teamMemberLimit, !types.Int do
    description ''
    property :team_member_limit
  end

  field :owner, Types::UserType do
    description ''

    resolve ->(obj, _args, _ctx) { obj.owner }
  end

  field :membership, Types::MembershipType do
    description ''

    resolve ->(obj, _args, _ctx) { obj.membership }
  end

  field :members do
    type !types[!Types::WorkspaceUserType]
    description 'Array of users who are members of this workspace.'
    scope ->(obj, _args, _ctx) { obj.members }

    argument :limit, types.Int do
      description 'A limit on the number of objects to be returned, between 1 and 100. The default is 20 if this parameter is omitted.'
    end

    argument :page, types.Int do
      description 'Indicates the number of the page. All paginated queries start at page 1.'
    end

    resolve ->(collection, args, _ctx) {
      collection.page(args['page']).per(args['limit'])
    }
  end

  field :roles do
    type !types[!Types::WorkspaceUserType]
    description ''
    scope ->(obj, _args, ctx) { obj.members.where(user_id: ctx[:current_user].id) }

    resolve ->(collection, _args, _ctx) {
      collection
    }
  end
end
