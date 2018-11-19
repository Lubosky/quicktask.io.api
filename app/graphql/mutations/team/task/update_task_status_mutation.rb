module Mutations
  module Team
    module Task
      UpdateTaskStatusMutation = GraphQL::Field.define do
        type Types::TaskType
        description 'Updates a task’s status.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :taskId, !types.ID, 'Globally unique ID of the task.', as: :task_id
        argument :input, Inputs::Team::Task::StatusInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].tasks.find(args[:task_id])
        }

        authorize! ->(task, _args, ctx) {
          ::Team::TaskPolicy.new(ctx[:current_account], task).update?
        }

        resolve UpdateTaskStatusMutationResolver.new
      end

      class UpdateTaskStatusMutationResolver
        def call(task, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          status = args[:input][:status].to_sym
          case status
          when :completed
            action = ::Team::Task::Complete.run(context: context, task: task)
          when :uncompleted
            action = ::Team::Task::Uncomplete.run(context: context, task: task)
          when :reset
            action = ::Team::Task::Reset.run(context: context, task: task)
          end

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
