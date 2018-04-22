module Mutations
  module Team
    module Client
      CreateClientMutation = GraphQL::Field.define do
        type Types::ClientType
        description 'Creates a new project in a workspace.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :input, Inputs::Team::Client::BaseInput

        authorize! ->(_obj, _args, ctx) {
          ::Team::ClientPolicy.new(ctx[:current_workspace_user], ::Client).create?
        }

        resolve CreateClientMutationResolver.new
      end

      class CreateClientMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
          end

          action = ::Team::Client::Create.run(inputs)
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
