Types::Team::WorkspaceType = GraphQL::ObjectType.define do
  name 'TeamWorkspace'
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

    scope ->(obj, _args, ctx) { obj.members.where(user_id: ctx[:current_user].id) }

    resolve ->(collection, _args, _ctx) {
      collection
    }
  end

  field :clients do
    type types[!Types::Team::ClientType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::ClientPolicy.new(ctx[:current_workspace_user], Client).index?
    }

    argument :limit, types.Int, 'A limit on the number of records to be returned, between 1 and 100. The default is 20 if this parameter is omitted.'
    argument :page, types.Int, 'Indicates the number of the page. All paginated queries start at page 1.'

    before_scope ->(obj, _args, ctx) { ctx[:current_workspace].clients }
    resolve ->(collection, args, _ctx) {
      collection.page(args['page']).per(args['limit'])
    }
  end

  field :contractors do
    type types[!Types::Team::ContractorType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::ContractorPolicy.new(ctx[:current_workspace_user], Contractor).index?
    }

    argument :limit, types.Int, 'A limit on the number of records to be returned, between 1 and 100. The default is 20 if this parameter is omitted.'
    argument :page, types.Int, 'Indicates the number of the page. All paginated queries start at page 1.'

    before_scope ->(obj, _args, ctx) { ctx[:current_workspace].contractors }
    resolve ->(collection, args, _ctx) {
      collection.page(args['page']).per(args['limit'])
    }
  end

  field :projects do
    type types[!Types::Team::ProjectType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::ProjectPolicy.new(ctx[:current_workspace_user], Project).index?
    }

    argument :limit, types.Int, 'A limit on the number of records to be returned, between 1 and 100. The default is 20 if this parameter is omitted.'
    argument :page, types.Int, 'Indicates the number of the page. All paginated queries start at page 1.'

    before_scope ->(obj, _args, ctx) { ctx[:current_workspace].projects }
    resolve ->(collection, args, _ctx) {
      collection.page(args['page']).per(args['limit'])
    }
  end
end
