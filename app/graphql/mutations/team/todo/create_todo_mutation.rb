module Mutations
  module Team
    module Todo
      CreateTodoMutation = GraphQL::Field.define do
        type Types::TodoType
        description 'Creates a todo.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :taskId, !types.ID, 'Globally unique ID of the task.', as: :task_id
        argument :input, Inputs::Team::Todo::BaseInput

        authorize! ->(_obj, _args, ctx) {
          ::Team::TodoPolicy.new(ctx[:current_workspace_user], ::Todo).create?
        }

        resolve CreateTodoMutationResolver.new
      end

      class CreateTodoMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          task = ctx[:current_workspace].tasks.find_by(id: args[:task_id])

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:task] = task
          end

          action = ::Team::Todo::Create.run(inputs)
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
