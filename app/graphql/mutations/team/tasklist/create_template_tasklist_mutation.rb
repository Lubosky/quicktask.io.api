module Mutations
  module Team
    module Tasklist
      CreateTemplateTasklistMutation = GraphQL::Field.define do
        type Types::TasklistType
        description 'Creates a tasklist.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :projectTemplateId, !types.ID, 'Globally unique ID of the project template.', as: :project_template_id
        argument :input, Inputs::Team::Tasklist::TemplateInput

        authorize! ->(_obj, _args, ctx) {
          ::Team::TasklistPolicy.new(ctx[:current_workspace_user], ::Tasklist).create?
        }

        resolve CreateTemplateTasklistMutationResolver.new
      end

      class CreateTemplateTasklistMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          project_template = ctx[:current_workspace].project_templates.find_by(id: args[:project_template_id])

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:parent] = project_template
          end

          action = ::Team::Tasklist::Create.run(inputs)
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
