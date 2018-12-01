module Mutations
  module Team
    module Note
      CreateNoteMutation = GraphQL::Field.define do
        type Types::NoteType
        description 'Creates the note.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :parentId, !types.ID, 'Unique ID of the parent.', as: :parent_id
        argument :parentType, !types.String, 'The type of this parent.', as: :parent_type

        argument :input, Inputs::Team::Note::BaseInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].tags.find(args[:tag_id])
        }

        authorize! ->(note, _args, ctx) {
          ::Team::NotePolicy.new(ctx[:current_account], note).add?
        }

        resolve CreateNoteMutationResolver.new
      end

      class CreateNoteMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          parent_type = args[:parent_type]
          annotatable_type = parent_type.camelize.safe_constantize
          parent = annotatable_type.find_by(id: args[:parent_id], workspace: ctx[:current_workspace])

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:annotatable] = parent
          end

          action = ::Team::Note::Create.run(inputs)
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
