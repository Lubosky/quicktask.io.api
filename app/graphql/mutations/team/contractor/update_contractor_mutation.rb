module Mutations
  module Team
    module Contractor
      UpdateContractorMutation = GraphQL::Field.define do
        type Types::ContractorType
        description 'Updates the contractor.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :id, !types.ID, 'Globally unique ID of the contractor.'
        argument :input, Inputs::Team::Contractor::BaseInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].contractors.find(args[:id])
        }

        authorize! ->(contractor, _args, ctx) {
          ::Team::ContractorPolicy.new(ctx[:current_account], contractor).update?
        }

        resolve UpdateContractorMutationResolver.new
      end

      class UpdateContractorMutationResolver
        def call(contractor, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:contractor] = contractor
          end

          action = ::Team::Contractor::Update.run(inputs)
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
