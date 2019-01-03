Types::WorkspaceType = GraphQL::ObjectType.define do
  name 'Workspace'
  description 'A workspace is the highest-level organizational unit. All projects and tasks have an associated workspace.'

  field :id, !types.ID, 'Globally unique ID of the workspace.'
  field :uuid, !types.String, 'A unique substitute for a workspace ID.'

  field :owner_id, !types.ID, 'Globally unique ID of the owner.'

  field :name, !types.String, 'The name of the workspace.'
  field :business_name, types.String, 'The business name of the workspace.'
  field :status, !types.String, 'Workspace’s status. Enum: Pending, Active, Deactivated.'
  field :team_member_count, !types.Int, ''
  field :team_member_limit, !types.Int, ''

  field :me, Types::WorkspaceAccountType do
    description 'Returns the workspace user record for the currently authorized workspace user.'
    resolve ->(_obj, _args, ctx) { ctx[:current_account] }
  end

  field :owner, Types::UserType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :owner).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :membership, Types::MembershipType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :membership).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :available_tags do
    type !types[!Types::TagType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::TagPolicy.new(ctx[:current_account], Tag).index?
    }

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :tags).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :workspace_accounts do
    type !types[!Types::WorkspaceAccountType]
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :accounts).load(obj) }
    resolve ->(promise, _args, ctx) {
      promise.then(proc { |collection| collection.where(user: ctx[:current_user]) })
    }
  end

  field :clients do
    type types[!Types::ClientType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::ClientPolicy.new(ctx[:current_account], Client).index?
    }

    argument :limit, types.Int, 'A limit on the number of records to be returned, between 1 and 100. The default is 20 if this parameter is omitted.'
    argument :page, types.Int, 'Indicates the number of the page. All paginated queries start at page 1.'

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :clients).load(obj) }
    resolve ->(promise, args, _ctx) {
      promise.then(proc { |collection| collection })
    }
  end

  field :client_requests do
    type types[Types::ClientRequestType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::ClientRequestPolicy.new(ctx[:current_account], ClientRequest).index?
    }

    argument :limit, types.Int, 'A limit on the number of records to be returned, between 1 and 100. The default is 20 if this parameter is omitted.'
    argument :page, types.Int, 'Indicates the number of the page. All paginated queries start at page 1.'

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :client_requests).load(obj) }
    resolve ->(promise, args, _ctx) {
      promise.then(proc { |collection| collection })
    }
  end

  field :contractors do
    type types[!Types::ContractorType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::ContractorPolicy.new(ctx[:current_account], Contractor).index?
    }

    argument :limit, types.Int, 'A limit on the number of records to be returned, between 1 and 100. The default is 20 if this parameter is omitted.'
    argument :page, types.Int, 'Indicates the number of the page. All paginated queries start at page 1.'

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :contractors).load(obj) }
    resolve ->(promise, args, _ctx) {
      promise.then(proc { |collection| collection.page(args[:page]).per(args[:limit]) })
    }
  end

  field :languages do
    type types[!Types::LanguageType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::LanguagePolicy.new(ctx[:current_account], Language).index?
    }

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :languages).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :projects do
    type types[!Types::ProjectType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::ProjectPolicy.new(ctx[:current_account], Project::Regular).index?
    }

    argument :limit, types.Int, 'A limit on the number of records to be returned, between 1 and 100. The default is 20 if this parameter is omitted.'
    argument :page, types.Int, 'Indicates the number of the page. All paginated queries start at page 1.'

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :projects).load(obj) }
    resolve ->(promise, args, _ctx) {
      promise.then(proc { |collection| collection.page(args[:page]).per(args[:limit]) })
    }
  end

  connection :projects_connection, Types::ProjectType.connection_type do
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::ProjectPolicy.new(ctx[:current_account], Project::Regular).index?
    }

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :projects).load(obj) }
    resolve ->(promise, args, _ctx) {
      promise.then(proc { |collection| collection })
    }
  end

  field :project, Types::ProjectType do
    description ''

    argument :project_id, types.ID, 'Globally unique ID of the project.'

    resource ->(obj, args, _ctx) {
      obj.projects.find(args[:project_id])
    }, pass_through: true

    authorize! ->(project, _args, ctx) {
      ::Team::ProjectPolicy.new(ctx[:current_account], project).show?
    }

    resolve ->(project, _args, _ctx) { project }
  end


  field :project_templates do
    type types[!Types::ProjectTemplateType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::ProjectTemplatePolicy.new(ctx[:current_account], Project::Template).index?
    }

    argument :limit, types.Int, 'A limit on the number of records to be returned, between 1 and 100. The default is 20 if this parameter is omitted.'
    argument :page, types.Int, 'Indicates the number of the page. All paginated queries start at page 1.'

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :project_templates).load(obj) }
    resolve ->(promise, args, _ctx) {
      promise.then(proc { |collection| collection.page(args[:page]).per(args[:limit]) })
    }
  end

  field :project_template, Types::ProjectTemplateType do
    description ''

    argument :project_template_id, types.ID, 'Globally unique ID of the project template.'

    resource ->(obj, args, _ctx) {
      obj.project_templates.find(args[:project_template_id])
    }, pass_through: true

    authorize! ->(project_template, _args, ctx) {
      ::Team::ProjectTemplatePolicy.new(ctx[:current_account], project_template).show?
    }

    resolve ->(project_template, _args, _ctx) { project_template }
  end

  field :purchase_orders do
    type types[!Types::PurchaseOrderType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::PurchaseOrderPolicy.new(ctx[:current_account], PurchaseOrder).index?
    }

    argument :limit, types.Int, 'A limit on the number of records to be returned, between 1 and 100. The default is 20 if this parameter is omitted.'
    argument :page, types.Int, 'Indicates the number of the page. All paginated queries start at page 1.'

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :purchase_orders).load(obj) }
    resolve ->(promise, args, _ctx) {
      promise.then(proc { |collection| collection.page(args[:page]).per(args[:limit]) })
    }
  end

  field :quotes do
    type types[Types::QuoteType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::QuotePolicy.new(ctx[:current_account], Quote).index?
    }

    argument :limit, types.Int, 'A limit on the number of records to be returned, between 1 and 100. The default is 20 if this parameter is omitted.'
    argument :page, types.Int, 'Indicates the number of the page. All paginated queries start at page 1.'

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :quotes).load(obj) }
    resolve ->(promise, args, _ctx) {
      promise.then(proc { |collection| collection })
    }
  end

  field :supported_currencies do
    type types[!Types::WorkspaceCurrencyType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::WorkspaceCurrencyPolicy.new(ctx[:current_account], WorkspaceCurrency).index?
    }

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :supported_currencies).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :task_types do
    type types[!Types::TaskTypeType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::Team::TaskTypePolicy.new(ctx[:current_account], TaskType).index?
    }

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :task_types).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :units do
    type types[!Types::UnitType]
    description ''

    authorize ->(_obj, _args, ctx) {
      ::UnitPolicy.new(ctx[:current_account], Unit).index?
    }

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Workspace, :units).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end
end
