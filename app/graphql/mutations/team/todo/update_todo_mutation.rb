module Mutations
  module Team
    module Todo
      UpdateTodoMutation = GraphQL::Field.define do
        type Types::TodoType
        description 'Updates a task’s status.'

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

        resolve UpdateTodoMutationResolver.new
      end

      class UpdateTodoMutationResolver
        def call(todo, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:todo] = todo
          end

          action = ::Team::Todo::Update.run(inputs)
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
