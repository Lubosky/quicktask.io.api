module Mutations
  module Team
    module Project
      UpdateProjectMutation = GraphQL::Field.define do
        type Types::ProjectType
        description 'Updates the project.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :projectId, !types.ID, 'Globally unique ID of the project.', as: :project_id
        argument :input, Inputs::Team::Project::BaseInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].projects.find(args[:project_id])
        }

        authorize! ->(project, _args, ctx) {
          ::Team::ProjectPolicy.new(ctx[:current_account], project).update?
        }

        resolve UpdateProjectMutationResolver.new
      end

      class UpdateProjectMutationResolver
        def call(project, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:project] = project
          end

          action = ::Team::Project::Update.run(inputs)
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
