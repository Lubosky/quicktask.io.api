module Mutations
  module Team
    module Note
      UpdateNoteMutation = GraphQL::Field.define do
        type Types::NoteType
        description 'Updates the note.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :noteId, !types.ID, 'Unique ID of the note.', as: :note_id

        argument :input, Inputs::Team::Note::BaseInput

        resource! ->(_obj, args, ctx) {
          Note.find_by(id: args[:note_id], workspace_id: ctx[:current_workspace].id)
        }

        authorize! ->(note, _args, ctx) {
          ::Team::NotePolicy.new(ctx[:current_account], note).update?
        }

        resolve UpdateNoteMutationResolver.new
      end

      class UpdateNoteMutationResolver
        def call(note, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:note] = note
          end

          action = ::Team::Note::Update.run(inputs)
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
