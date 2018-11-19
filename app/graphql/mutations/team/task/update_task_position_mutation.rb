module Mutations
  module Team
    module Task
      UpdateTaskPositionMutation = GraphQL::Field.define do
        type Types::TaskType
        description 'Updates the position of the task.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :taskId, !types.ID, 'Globally unique ID of the task.', as: :task_id
        argument :input, Inputs::Team::Task::BaseInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].tasks.find(args[:task_id])
        }

        authorize! ->(task, _args, ctx) {
          ::Team::TaskPolicy.new(ctx[:current_account], task).update?
        }

        resolve UpdateTaskPositionMutationResolver.new
      end

      UpdateTemplateTaskPositionMutation = GraphQL::Field.define do
        type Types::TaskType
        description 'Updates the position of the task within a template.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :taskId, !types.ID, 'Globally unique ID of the task.', as: :task_id
        argument :input, Inputs::Team::Task::TemplateInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].tasks.find(args[:task_id])
        }

        authorize! ->(task, _args, ctx) {
          ::Team::TaskPolicy.new(ctx[:current_account], task).update?
        }

        resolve UpdateTaskPositionMutationResolver.new
      end

      class UpdateTaskPositionMutationResolver
        def call(task, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:task] = task
          end

          action = ::Team::Task::MoveTask.run(inputs)
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
