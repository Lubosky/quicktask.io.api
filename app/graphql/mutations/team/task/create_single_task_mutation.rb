module Mutations
  module Team
    module Task
      CreateSingleTaskMutation = GraphQL::Field.define do
        type Types::TaskType
        description 'Creates a task.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :tasklistId, !types.ID, 'Globally unique ID of the tasklist.', as: :tasklist_id
        argument :input, Inputs::Team::Task::BaseInput

        authorize! ->(_obj, _args, ctx) {
          ::Team::TaskPolicy.new(ctx[:current_workspace_user], ::Task).create?
        }

        resolve CreateSingleTaskMutationResolver.new
      end

      CreateSingleTemplateTaskMutation = GraphQL::Field.define do
        type Types::TaskType
        description 'Creates a task within a template.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :tasklistId, !types.ID, 'Globally unique ID of the tasklist.', as: :tasklist_id
        argument :input, Inputs::Team::Task::TemplateInput

        authorize! ->(_obj, _args, ctx) {
          ::Team::TaskPolicy.new(ctx[:current_workspace_user], ::Task).create?
        }

        resolve CreateSingleTaskMutationResolver.new
      end

      class CreateSingleTaskMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          tasklist = ctx[:current_workspace].tasklists.find_by(id: args[:tasklist_id])

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:tasklist] = tasklist
          end

          action = ::Team::Task::Create.run(inputs)
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
