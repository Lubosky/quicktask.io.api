module Mutations
  module Team
    module Client
      DeleteClientMutation = GraphQL::Field.define do
        type Types::ClientType
        description 'Deletes the client from the workspace.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :id, !types.ID, 'Globally unique ID of the client.'

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].clients.find(args[:id])
        }

        authorize! ->(client, _args, ctx) {
          ::Team::ClientPolicy.new(ctx[:current_account], client).destroy?
        }

        resolve DeleteClientMutationResolver.new
      end

      class DeleteClientMutationResolver
        def call(client, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          action = ::Team::Client::Destroy.run(context: context, client: client)

          if action.valid?
            action.result
          else
            action.errors
          end
        end
      end
    end
  end
end
