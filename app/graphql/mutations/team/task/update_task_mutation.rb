module Mutations
  module Team
    module Task
      UpdateTaskMutation = GraphQL::Field.define do
        type Types::TaskType
        description 'Updates a task’s status.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :projectId, !types.ID, 'Globally unique ID of the task.', as: :project_id
        argument :taskId, !types.ID, 'Globally unique ID of the task.', as: :task_id
        argument :input, Inputs::Team::Task::BaseInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].tasks.find(args[:task_id])
        }

        authorize! ->(task, _args, ctx) {
          ::Team::TaskPolicy.new(ctx[:current_workspace_user], task).update?
        }

        resolve UpdateTaskMutationResolver.new
      end

      class UpdateTaskMutationResolver
        def call(task, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:task] = task
          end

          action = ::Team::Task::Update.run(inputs)
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
