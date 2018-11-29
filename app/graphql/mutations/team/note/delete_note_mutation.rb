module Mutations
  module Team
    module Note
      DeleteNoteMutation = GraphQL::Field.define do
        type Types::NoteType
        description 'Deletes the note.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :noteId, !types.ID, 'Unique ID of the note.', as: :note_id

        resource! ->(_obj, args, ctx) {
          Note.find_by(id: args[:note_id], workspace_id: ctx[:current_workspace].id)
        }

        authorize! ->(note, _args, ctx) {
          ::Team::NotePolicy.new(ctx[:current_account], note).destroy?
        }

        resolve DeleteNoteMutationResolver.new
      end

      class DeleteNoteMutationResolver
        def call(note, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          action = ::Team::Note::Destroy.run(context: context, note: note)
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
