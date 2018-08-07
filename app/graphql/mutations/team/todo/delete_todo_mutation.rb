module Mutations
  module Team
    module Todo
      DeleteTodoMutation = GraphQL::Field.define do
        type Types::TodoType
        description 'Deletes the todo from the workspace.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :todoId, !types.ID, 'Globally unique ID of the todo.', as: :todo_id

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].todos.find(args[:todo_id])
        }

        authorize! ->(todo, _args, ctx) {
          ::Team::TodoPolicy.new(ctx[:current_workspace_user], todo).destroy?
        }

        resolve DeleteTodoMutationResolver.new
      end

      class DeleteTodoMutationResolver
        def call(todo, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          action = ::Team::Todo::Destroy.run(context: context, todo: todo)

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
