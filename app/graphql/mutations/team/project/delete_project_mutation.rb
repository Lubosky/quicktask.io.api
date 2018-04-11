module Mutations
  module Team
    module Project
      DeleteProjectMutation = GraphQL::Field.define do
        type Types::Team::ProjectType
        description 'Deletes the project from the workspace.'

        argument :id, !types.ID, 'Globally unique ID of the project.'

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].projects.find(args[:id])
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
