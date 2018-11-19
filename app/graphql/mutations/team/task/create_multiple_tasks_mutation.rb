module Mutations
  module Team
    module Task
      CreateMultipleTasksMutation = GraphQL::Field.define do
        type types[Types::TaskType]
        description 'Adds multiple tasks to tasklist.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :tasklistId, !types.ID, 'Globally unique ID of the tasklist.', as: :tasklist_id
        argument :input, types[Inputs::Team::Task::BaseInput]

        authorize! ->(_obj, _args, ctx) {
          ::Team::TaskPolicy.new(ctx[:current_account], ::Task).create?
        }

        resolve CreateMultipleTasksMutationResolver.new
      end

      CreateMultipleTemplateTasksMutation = GraphQL::Field.define do
        type types[Types::TaskType]
        description 'Adds multiple tasks to tasklist within a project template.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :tasklistId, !types.ID, 'Globally unique ID of the tasklist.', as: :tasklist_id
        argument :input, types[Inputs::Team::Task::TemplateInput]

        authorize! ->(_obj, _args, ctx) {
          ::Team::TaskPolicy.new(ctx[:current_account], ::Task).create?
        }

        resolve CreateMultipleTasksMutationResolver.new
      end

      class CreateMultipleTasksMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          tasklist = ctx[:current_workspace].tasklists.find_by(id: args[:tasklist_id])

          inputs = {}.tap do |hash|
            hash[:tasks] = args[:input].map(&:to_h)
            hash[:context] = context
            hash[:tasklist] = tasklist
          end

          action = ::Team::Task::CreateMultiple.run(inputs)
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
