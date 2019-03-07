module Mutations
  module Team
    module Rate
      DeleteRateMutation = GraphQL::Field.define do
        type Types::RateType
        description 'Deletes the rate.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :rateId, !types.ID, 'Unique ID of the rate.', as: :rate_id

        resource! ->(_obj, args, ctx) {
          ::Rate.find(args[:rate_id])
        }

        authorize! ->(rate, _args, ctx) {
          ::Team::RatePolicy.new(ctx[:current_account], rate).destroy?
        }

        resolve DeleteRateMutationResolver.new
      end

      class DeleteRateMutationResolver
        def call(rate, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          action = ::Team::Rate::Destroy.run(context: context, rate: rate)
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
