module Mutations
  module Team
    module Tag
      UpdateTagMutation = GraphQL::Field.define do
        type Types::TagType
        description 'Updates the tag.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :parentId, !types.ID, 'Unique ID of the parent.', as: :parent_id
        argument :parentType, !Types::TaggableType, 'The type of this parent.', as: :parent_type
        argument :tagId, !types.ID, 'Unique ID of the tag.', as: :tag_id

        argument :input, Inputs::Team::Tag::BaseInput

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].tags.find(args[:tag_id])
        }

        authorize! ->(tag, _args, ctx) {
          ::Team::TagPolicy.new(ctx[:current_account], tag).update?
        }

        resolve UpdateTagMutationResolver.new
      end

      class UpdateTagMutationResolver
        def call(tag, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:tag] = tag
          end

          action = ::Team::Tag::Update.run(inputs)
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
