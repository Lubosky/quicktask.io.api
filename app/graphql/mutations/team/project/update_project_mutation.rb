module Mutations
  module Team
    module Project
      UpdateProjectMutation = GraphQL::Field.define do
        type Types::Team::ProjectType
        description 'Updates the project.'

        argument :id, !types.ID, 'Globally unique ID of the project.'
        argument :input, Inputs::Team::Project::BaseInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].projects.find(args[:id])
        }

        authorize! ->(project, _args, ctx) {
          ::Team::ProjectPolicy.new(ctx[:current_workspace_user], project).update?
        }

        resolve UpdateProjectMutationResolver.new
      end

      class UpdateProjectMutationResolver
        def call(project, args, ctx)
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

          action = ::Team::Project::Update.run(inputs.merge(project: project))
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
