module Mutations
  module Team
    module Contractor
      DeleteContractorMutation = GraphQL::Field.define do
        type Types::ContractorType
        description 'Deletes the project from the workspace.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :id, !types.ID, 'Globally unique ID of the project.'

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].projects.find(args[:id])
        }

        authorize! ->(project, _args, ctx) {
          ::Team::ContractorPolicy.new(ctx[:current_account], project).destroy?
        }

        resolve DeleteContractorMutationResolver.new
      end

      class DeleteContractorMutationResolver
        def call(project, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          action = ::Team::Contractor::Destroy.run(context: context, project: project)

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
