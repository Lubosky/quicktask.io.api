Types::UserType = GraphQL::ObjectType.define do
  name 'User'
  description 'A user object represents an account that can be given access to various workspaces, projects, and tasks.'

  field :id, !types.ID, 'Globally unique ID of the user.'
  field :uuid, !types.String, 'A unique substitute for a user ID.'
  field :email, !types.String, 'The user’s email address.'

  field :google_id, types.String do
    description 'A Google identifier for the user.'
    property :google_uid
  end

  field :name, !types.String, 'The user’s name.'
  field :first_name, !types.String, 'The user’s first name.'
  field :last_name, !types.String, 'The user’s last name.'
  field :email_confirmed, !types.Boolean, 'True if the user’s email is currently marked confirmed, false if not.'
  field :status, !types.String, 'User’s status. Enum: Inactive, Pending, Active.'
  field :last_login_at, Types::DateTimeType, 'The time at which this user logged in for the last time.'
  field :language, types.String do
    description 'Locale selected by the user.'
    property :locale
  end

  field :timezone, types.String do
    description 'Time zone assigned by the system or selected by the user.'
    property :time_zone
  end

  field :time_twelve_hour, !types.Boolean, ''

  field :created_at, Types::DateTimeType, 'The time at which this user’s account was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this user’s account was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this user’s account was deleted.'
  field :deactivated_at, Types::DateTimeType, 'The time at which this user’s account was deactivated.'

  field :workspaces, !types[!Types::WorkspaceType] do
    description 'Workspaces and organizations this user may access.'
    before_scope ->(obj, _args, _ctx) { Workspace.accessible_by(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :workspace_users, !types[!Types::WorkspaceUserType] do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(User, :members).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end
end
