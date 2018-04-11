module Mutations
  module Team
    module Project
      CreateProjectMutation = GraphQL::Field.define do
        type Types::Team::ProjectType
        description 'Creates a new project in a workspace.'

        argument :input, Inputs::Team::Project::BaseInput

        authorize! ->(_obj, _args, ctx) {
          ::Team::ProjectPolicy.new(ctx[:current_workspace_user], ::Project).create?
        }

        resolve CreateProjectMutationResolver.new
      end

      class CreateProjectMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_workspace_user,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
          end

          action = ::Team::Project::Create.run(inputs)
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
