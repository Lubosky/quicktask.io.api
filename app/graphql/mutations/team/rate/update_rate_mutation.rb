module Mutations
  module Team
    module Rate
      UpdateRateMutation = GraphQL::Field.define do
        type Types::RateType
        description 'Updates the rate.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :rateId, !types.ID, 'Unique ID of the rate.', as: :rate_id

        argument :input, Inputs::Team::Rate::BaseInput

        resource! ->(_obj, args, ctx) {
          ::Rate.find(args[:rate_id])
        }

        authorize! ->(rate, _args, ctx) {
          ::Team::RatePolicy.new(ctx[:current_account], rate).update?
        }

        resolve UpdateRateMutationResolver.new
      end

      class UpdateRateMutationResolver
        def call(rate, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:rate] = rate
          end

          action = ::Team::Rate::Update.run(inputs)
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
