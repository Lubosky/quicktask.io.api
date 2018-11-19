module Mutations
  module Team
    module Task
      DuplicateTaskMutation = GraphQL::Field.define do
        type Types::TaskType
        description 'Duplicates the task.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :tasklistId, !types.ID, 'Globally unique ID of the tasklist.', as: :tasklist_id
        argument :taskId, !types.ID, 'Globally unique ID of the task.', as: :task_id

        authorize! ->(_obj, _args, ctx) {
          ::Team::TaskPolicy.new(ctx[:current_account], ::Task).create?
        }

        resolve DuplicateTaskMutationResolver.new
      end

      class DuplicateTaskMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          task = ctx[:current_workspace].tasks.find_by(id: args[:task_id])

          inputs = {}.tap do |hash|
            hash[:context] = context
            hash[:task] = task
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
