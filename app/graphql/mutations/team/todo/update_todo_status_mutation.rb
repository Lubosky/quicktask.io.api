module Mutations
  module Team
    module Todo
      UpdateTodoStatusMutation = GraphQL::Field.define do
        type Types::TodoType
        description 'Updates a todo’s status.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :todoId, !types.ID, 'Globally unique ID of the todo.', as: :todo_id
        argument :input, Inputs::Team::Todo::BaseInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].todos.find(args[:todo_id])
        }

        authorize! ->(todo, _args, ctx) {
          ::Team::TodoPolicy.new(ctx[:current_workspace_user], todo).update?
        }

        resolve UpdateTodoStatusMutationResolver.new
      end

      class UpdateTodoStatusMutationResolver
        def call(todo, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          status = args[:input][:completed]
          case status
          when true
            action = ::Team::Todo::Complete.run(context: context, todo: todo)
          when false
            action = ::Team::Todo::Uncomplete.run(context: context, todo: todo)
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
