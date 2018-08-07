module Mutations
  module Team
    module Project
      DeleteProjectMutation = GraphQL::Field.define do
        type Types::ProjectType
        description 'Deletes the project from the workspace.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :projectId, !types.ID, 'Globally unique ID of the project.', as: :project_id

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].projects.find(args[:project_id])
        }

        authorize! ->(project, _args, ctx) {
          ::Team::ProjectPolicy.new(ctx[:current_workspace_user], project).destroy?
        }

        resolve DeleteProjectMutationResolver.new
      end

      class DeleteProjectMutationResolver
        def call(project, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          action = ::Team::Project::Destroy.run(context: context, project: project)

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
