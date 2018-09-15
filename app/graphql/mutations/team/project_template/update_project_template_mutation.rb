module Mutations
  module Team
    module ProjectTemplate
      UpdateProjectTemplateMutation = GraphQL::Field.define do
        type Types::ProjectTemplateType
        description 'Updates the project template.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :projectTemplateId, !types.ID, 'Globally unique ID of the project template.', as: :project_template_id
        argument :input, Inputs::Team::Project::TemplateInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].project_templates.find(args[:project_template_id])
        }

        authorize! ->(project_template, _args, ctx) {
          ::Team::ProjectTemplatePolicy.new(ctx[:current_workspace_user], project_template).update?
        }

        resolve UpdateProjectTemplateMutationResolver.new
      end

      class UpdateProjectTemplateMutationResolver
        def call(project_template, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:project_template] = project_template
          end

          action = ::Team::ProjectTemplate::Update.run(inputs)
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
