module Mutations
  module Team
    module TeamMember
      UpdateTeamMemberProfileMutation = GraphQL::Field.define do
        type Types::TeamMemberType
        description 'Updates the project.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :input, Inputs::Team::TeamMember::BaseInput

        resource! ->(_obj, _args, ctx) {
          ctx[:current_workspace_user].member
        }

        authorize! ->(team_member, _args, ctx) {
          ::Team::TeamMemberPolicy.new(ctx[:current_workspace_user], team_member).update_profile?
        }

        resolve UpdateTeamMemberProfileMutationResolver.new
      end

      class UpdateTeamMemberProfileMutationResolver
        def call(team_member, args, ctx)
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

          action = ::Team::TeamMember::UpdateProfile.run(inputs)
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
