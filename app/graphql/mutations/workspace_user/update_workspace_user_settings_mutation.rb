module Mutations
  module WorkspaceUser
    UpdateWorkspaceUserSettingsMutation = GraphQL::Field.define do
      type Types::WorkspaceUserType
      description 'Updates the workspace settings of currently authenticated user.'

      argument :input, Inputs::WorkspaceUser::SettingsInput

      resource! ->(_obj, _args, ctx) { ctx[:current_workspace_user] }

      authorize! ->(workspace_user, _args, ctx) {
        ::WorkspaceUserPolicy.new(ctx[:current_workspace_user], workspace_user).update?
      }

      resolve UpdateWorkspaceUserSettingsMutationResolver.new
    end

    class UpdateWorkspaceUserSettingsMutationResolver
      def call(workspace_user, args, ctx)
        context = ctx.to_h.slice(
          :current_user,
          :current_workspace,
          :current_workspace_user,
          :request
        )

        inputs = {}.tap do |hash|
          hash.merge!(args[:input].to_h)
          hash[:context] = context
          hash[:workspace_user] = workspace_user
        end

        action = ::WorkspaceUser::UpdateSettings.run(inputs)
        if action.valid?
          action.result
        else
          action.errors
        end
      end
    end
  end
end
