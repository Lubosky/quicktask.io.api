module Mutations
  module Team
    module ProjectTemplate
      CreateProjectTemplateMutation = GraphQL::Field.define do
        type Types::ProjectTemplateType
        description 'Creates a new project template in a workspace.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :input, Inputs::Team::Project::TemplateInput

        authorize! ->(_obj, _args, ctx) {
          ::Team::ProjectTemplatePolicy.new(ctx[:current_account], ::Project::Template).create?
        }

        resolve CreateProjectTemplateMutationResolver.new
      end

      class CreateProjectTemplateMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
          end

          action = ::Team::ProjectTemplate::Create.run(inputs)
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
