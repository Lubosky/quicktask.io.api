module Mutations
  module WorkspaceAccount
    UpdateWorkspaceAccountSettingsMutation = GraphQL::Field.define do
      type Types::WorkspaceAccountType
      description 'Updates the workspace settings of currently authenticated user.'

      argument :workspaceId, !types.ID, as: :workspace_id
      argument :accountType, !Types::ImpersonationType, as: :account_type

      argument :input, Inputs::WorkspaceAccount::SettingsInput

      resource! ->(_obj, _args, ctx) { ctx[:current_account] }

      authorize! ->(workspace_account, _args, ctx) {
        ::WorkspaceAccountPolicy.new(ctx[:current_account], workspace_account).update?
      }

      resolve UpdateWorkspaceAccountSettingsMutationResolver.new
    end

    class UpdateWorkspaceAccountSettingsMutationResolver
      def call(workspace_account, args, ctx)
        context = ctx.to_h.slice(
          :current_user,
          :current_workspace,
          :current_account,
          :request
        )

        inputs = {}.tap do |hash|
          hash.merge!(args[:input].to_h)
          hash[:context] = context
          hash[:workspace_account] = workspace_account
        end

        action = ::WorkspaceAccount::UpdateSettings.run(inputs)
        if action.valid?
          action.result
        else
          action.errors
        end
      end
    end
  end
end
