Types::QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'Base query type to rule them all.'

  field :me, Types::UserType do
    description 'Returns the user record for the currently authenticated user.'
    resolve ->(_obj, _args, ctx) { ctx[:current_user] }
  end

  field :currentWorkspace, Types::WorkspaceType do
    description 'Returns the workspace record for the currently used workspace.'
    resolve ->(_obj, _args, ctx) { ctx[:current_workspace] }
  end

  field :contractorWorkspace, Types::Contractor::WorkspaceType do
    description ''

    authorize ->(_obj, _args, ctx) {
      ctx[:current_workspace_user] && ctx[:current_workspace_user].contractor?
    }

    resolve ->(_obj, _args, ctx) { ctx[:current_workspace] }
  end

  field :clientWorkspace, Types::Client::WorkspaceType do
    description ''

    authorize ->(_obj, _args, ctx) {
      ctx[:current_workspace_user] && ctx[:current_workspace_user].client?
    }

    resolve ->(_obj, _args, ctx) { ctx[:current_workspace] }
  end

  field :teamWorkspace, Types::Team::WorkspaceType do
    description ''

    authorize ->(_obj, _args, ctx) {
      ctx[:current_workspace_user] && ctx[:current_workspace_user].team_member?
    }

    resolve ->(_obj, _args, ctx) { ctx[:current_workspace] }
  end

  field :currentWorkspaceUser, Types::WorkspaceUserType do
    description 'Returns the workspace user record for the currently authorized workspace user.'
    resolve ->(_obj, _args, ctx) { ctx[:current_workspace_user] }
  end
end
