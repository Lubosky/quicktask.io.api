module Mutations
  module Team
    module HandOff
      UpdateHandOffStatusMutation = GraphQL::Field.define do
        type Types::HandOffType
        description 'Updates a hand-off’s status.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :handOffId, !types.ID, 'Globally unique ID of the hand-off.', as: :hand_off_id
        argument :input, Inputs::Team::HandOff::ActionInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].hand_offs.find(args[:hand_off_id])
        }

        authorize! ->(hand_off, _args, ctx) {
          ::Team::HandOffPolicy.new(ctx[:current_account], hand_off).update?
        }

        resolve UpdateHandOffStatusMutationResolver.new
      end

      class UpdateHandOffStatusMutationResolver
        def call(hand_off, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          action = args[:input][:action].to_sym
          case action
          when :accept
            action = ::Team::HandOff::Accept.run(context: context, hand_off: hand_off)
          when :cancel
            action = ::Team::HandOff::Cancel.run(context: context, hand_off: hand_off)
          when :reject
            action = ::Team::HandOff::Reject.run(context: context, hand_off: hand_off)
          when :resend
            action = ::Team::HandOff::Resend.run(context: context, hand_off: hand_off)
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
