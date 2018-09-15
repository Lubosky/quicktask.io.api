module Mutations
  module Team
    module ProjectTemplate
      DeleteProjectTemplateMutation = GraphQL::Field.define do
        type Types::ProjectTemplateType
        description 'Deletes the project template from the workspace.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :projectTemplateId, !types.ID, 'Globally unique ID of the project template.', as: :project_template_id

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].project_templates.find(args[:project_template_id])
        }

        authorize! ->(project_template, _args, ctx) {
          ::Team::ProjectTemplatePolicy.new(ctx[:current_workspace_user], project_template).destroy?
        }

        resolve DeleteProjectTemplateMutationResolver.new
      end

      class DeleteProjectTemplateMutationResolver
        def call(project_template, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          action = ::Team::ProjectTemplate::Destroy.run(context: context, project_template: project_template)

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
