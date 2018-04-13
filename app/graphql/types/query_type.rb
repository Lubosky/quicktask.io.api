Types::QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'Base query type to rule them all.'

  field :me, Types::UserType do
    description 'Returns the user record for the currently authenticated user.'
    resolve ->(_obj, _args, ctx) { ctx[:current_user] }
  end

  field :workspace, Types::WorkspaceType do
    argument :workspaceId, !types.ID, as: :workspace_id
    argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

    authorize ->(_obj, args, ctx) {
      ctx[:current_workspace_user] &&
        ctx[:current_workspace_user].workspace_id == args[:workspace_id].to_i
    }

    resolve ->(_obj, _args, ctx) { ctx[:current_workspace] }
  end
end
