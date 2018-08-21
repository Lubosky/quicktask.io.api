module Mutations
  module Team
    module Project
      DuplicateProjectMutation = GraphQL::Field.define do
        type Types::ProjectType
        description 'Duplicates the project.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :projectId, !types.ID, 'Globally unique ID of the project.', as: :project_id

        authorize! ->(_obj, _args, ctx) {
          ::Team::ProjectPolicy.new(ctx[:current_workspace_user], ::Project::Base).create?
        }

        resolve DuplicateProjectMutationResolver.new
      end

      class DuplicateProjectMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          inputs = {}.tap do |hash|
            hash[:context] = context
            hash[:project_id] = args[:project_id]
          end

          action = ::Team::Project::Duplicate.run(inputs)
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
