module Mutations
  module Team
    module Tasklist
      UpdateTasklistMutation = GraphQL::Field.define do
        type Types::TasklistType
        description 'Updates a tasklist.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :tasklistId, !types.ID, 'Globally unique ID of the tasklist.', as: :tasklist_id
        argument :input, Inputs::Team::Tasklist::BaseInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].tasklists.find(args[:tasklist_id])
        }

        authorize! ->(tasklist, _args, ctx) {
          ::Team::TasklistPolicy.new(ctx[:current_account], tasklist).update?
        }

        resolve UpdateTasklistMutationResolver.new
      end

      class UpdateTasklistMutationResolver
        def call(tasklist, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:tasklist] = tasklist
          end

          action = ::Team::Tasklist::Update.run(inputs)
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
