module Mutations
  module Team
    module Client
      UpdateClientMutation = GraphQL::Field.define do
        type Types::ClientType
        description 'Updates the client.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :id, !types.ID, 'Globally unique ID of the client.'
        argument :input, Inputs::Team::Client::BaseInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].clients.find(args[:id])
        }

        authorize! ->(client, _args, ctx) {
          ::Team::ClientPolicy.new(ctx[:current_account], client).update?
        }

        resolve UpdateClientMutationResolver.new
      end

      class UpdateClientMutationResolver
        def call(client, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:client] = client
          end

          action = ::Team::Client::Update.run(inputs)
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
