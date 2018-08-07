module Mutations
  module Team
    module Project
      UpdateProjectStatusMutation = GraphQL::Field.define do
        type Types::ProjectType
        description 'Updates a project’s status.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :projectId, !types.ID, 'Globally unique ID of the project.', as: :project_id
        argument :input, Inputs::Team::Project::StatusInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].projects.find(args[:project_id])
        }

        authorize! ->(project, _args, ctx) {
          ::Team::ProjectPolicy.new(ctx[:current_workspace_user], project).update?
        }

        resolve UpdateProjectStatusMutationResolver.new
      end

      class UpdateProjectStatusMutationResolver
        def call(project, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          status = args[:input][:status].to_sym
          case status
          when :no_status
            action = ::Team::Project::Nullify.run(context: context, project: project)
          when :draft
            action = ::Team::Project::Prepare.run(context: context, project: project)
          when :planned
            action = ::Team::Project::Plan.run(context: context, project: project)
          when :active
            action = ::Team::Project::Activate.run(context: context, project: project)
          when :on_hold
            action = ::Team::Project::Suspend.run(context: context, project: project)
          when :completed
            action = ::Team::Project::Complete.run(context: context, project: project)
          when :cancelled
            action = ::Team::Project::Cancel.run(context: context, project: project)
          when :archived
            action = ::Team::Project::Archive.run(context: context, project: project)
          end

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
