module Mutations
  module Team
    module Task
      DuplicateTaskMutation = GraphQL::Field.define do
        type Types::TaskType
        description 'Duplicates the task.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :projectId, !types.ID, 'Globally unique ID of the task.', as: :project_id
        argument :taskId, !types.ID, 'Globally unique ID of the task.', as: :task_id

        authorize! ->(_obj, _args, ctx) {
          ::Team::TaskPolicy.new(ctx[:current_workspace_user], ::Task).create?
        }

        resolve DuplicateTaskMutationResolver.new
      end

      class DuplicateTaskMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          inputs = {}.tap do |hash|
            hash[:context] = context
            hash[:task_id] = args[:task_id]
          end

          action = ::Team::Task::Duplicate.run(inputs)
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
