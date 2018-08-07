module Mutations
  module Team
    module TeamMember
      UpdateTeamMemberMutation = GraphQL::Field.define do
        type Types::TeamMemberType
        description 'Updates the attributes of team member.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :impersonationType, !Types::ImpersonationType, as: :impersonation_type

        argument :id, !types.ID, 'Globally unique ID of the team member.'
        argument :input, Inputs::Team::TeamMember::BaseInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].team_members.find(args[:id])
        }

        authorize! ->(team_member, _args, ctx) {
          ::Team::TeamMemberPolicy.new(ctx[:current_workspace_user], team_member).update?
        }

        resolve UpdateTeamMemberMutationResolver.new
      end

      class UpdateTeamMemberMutationResolver
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
            hash[:team_member] = team_member
          end

          action = ::Team::TeamMember::Update.run(inputs)
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
