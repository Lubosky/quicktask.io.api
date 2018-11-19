module Mutations
  module Team
    module Tasklist
      CreateTasklistMutation = GraphQL::Field.define do
        type Types::TasklistType
        description 'Creates a tasklist.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :projectId, !types.ID, 'Globally unique ID of the project.', as: :project_id
        argument :input, Inputs::Team::Tasklist::BaseInput

        authorize! ->(_obj, _args, ctx) {
          ::Team::TasklistPolicy.new(ctx[:current_account], ::Tasklist).create?
        }

        resolve CreateTasklistMutationResolver.new
      end

      class CreateTasklistMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          project = ctx[:current_workspace].projects.find_by(id: args[:project_id])

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:parent] = project
          end

          action = ::Team::Tasklist::Create.run(inputs)
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
