Types::UserType = GraphQL::ObjectType.define do
  name 'User'
  description 'A user object represents an account that can be given access to various workspaces, projects, and tasks.'

  field :id, !types.ID do
    description 'Globally unique ID of the user.'
  end

  field :uuid, !types.String do
    description 'A unique substitute for a User ID.'
  end

  field :email, !types.String do
    description 'The user’s email address.'
  end

  field :googleId, types.String do
    description 'A Google identifier for the user.'
    property :google_uid
  end

  field :emailConfirmed, !types.Boolean do
    description 'True if the user’s email is currently marked confirmed, false if not.'
    property :email_confirmed
  end

  field :status, !types.String do
    description 'User’s status. Enum: Inactive, Pending, Active.'
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

  field :deactivatedAt, Types::DateTimeType do
    description 'The time at which this user’s account was deactivated.'
    property :deactivated_at
  end

  field :lastLoginAt, Types::DateTimeType do
    description 'The time at which this user logged in for the last time.'
    property :last_login_at
  end

  field :firstName, !types.String do
    description 'The user’s first name.'
    property :first_name
  end

  field :lastName, !types.String do
    description 'The user’s last name.'
    property :last_name
  end

  field :language, !types.String do
    description 'Locale selected by the user.'
  end

  field :timezone, types.String do
    description 'Time zone assigned by the system or selected by the user.'
    property :time_zone
  end

  field :workspaces, !types[!Types::WorkspaceType] do
    description 'Workspaces and organizations this user may access.'
    scope ->(obj, _args, ctx) { Workspace.accessible_by(obj) }

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
end
