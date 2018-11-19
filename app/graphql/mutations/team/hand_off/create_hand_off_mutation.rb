module Mutations
  module Team
    module HandOff
      CreateHandOffMutation = GraphQL::Field.define do
        type Types::HandOffType
        description 'Creates a hand-off.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :projectId, !types.ID, 'Globally unique ID of the project.', as: :project_id
        argument :taskId, !types.ID, 'Globally unique ID of the task.', as: :task_id
        argument :input, Inputs::Team::HandOff::BaseInput

        authorize! ->(_obj, _args, ctx) {
          ::Team::HandOffPolicy.new(ctx[:current_account], ::HandOff).create?
        }

        resolve CreateHandOffMutationResolver.new
      end

      class CreateHandOffMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          task = ctx[:current_workspace].tasks.find_by(id: args[:task_id])

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:task] = task
          end

          action = ::Team::HandOff::Create.run(inputs)
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
