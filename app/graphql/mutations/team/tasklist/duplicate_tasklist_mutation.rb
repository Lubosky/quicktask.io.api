module Mutations
  module Team
    module Tasklist
      DuplicateTasklistMutation = GraphQL::Field.define do
        type Types::TasklistType
        description 'Duplicates the tasklist.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :projectId, !types.ID, 'Globally unique ID of the project.', as: :project_id
        argument :tasklistId, !types.ID, 'Globally unique ID of the tasklist.', as: :tasklist_id

        authorize! ->(_obj, _args, ctx) {
          ::Team::TasklistPolicy.new(ctx[:current_account], ::Tasklist).create?
        }

        resolve DuplicateTasklistResolver.new
      end

      DuplicateTemplateTasklistMutation = GraphQL::Field.define do
        type Types::TasklistType
        description 'Duplicates the tasklist.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :projectTemplateId, !types.ID, 'Globally unique ID of the project template.', as: :project_template_id
        argument :tasklistId, !types.ID, 'Globally unique ID of the tasklist.', as: :tasklist_id

        authorize! ->(_obj, _args, ctx) {
          ::Team::TasklistPolicy.new(ctx[:current_account], ::Tasklist).create?
        }

        resolve DuplicateTasklistResolver.new
      end

      class DuplicateTasklistResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          tasklist = ctx[:current_workspace].tasklists.find_by(id: args[:tasklist_id])

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:tasklist] = tasklist
          end

          action = ::Team::Tasklist::Duplicate.run(inputs)
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
