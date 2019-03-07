module Mutations
  module Team
    module Rate
      CreateRateMutation = GraphQL::Field.define do
        type Types::RateType
        description 'Creates a rate.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :ownerId, !types.ID, 'Unique ID of the owner.', as: :owner_id
        argument :rateType, !Types::RateTypeType, 'The type of rate.', as: :rate_type
        argument :input, Inputs::Team::Rate::BaseInput

        authorize! ->(_obj, _args, ctx) {
          ::Team::RatePolicy.new(ctx[:current_account], ::Rate).create?
        }

        resolve CreateRateMutationResolver.new
      end

      class CreateRateMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:owner_id] = args[:owner_id]
            hash[:rate_type] = args[:rate_type]
            hash[:context] = context
          end

          action = ::Team::Rate::Create.run(inputs)
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
