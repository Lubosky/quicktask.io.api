module Mutations
  module Team
    module Tag
      AddTagMutation = GraphQL::Field.define do
        type Types::TagType
        description 'Attaches the tag to parent record.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :parentId, !types.ID, 'Unique ID of the parent.', as: :parent_id
        argument :parentType, !Types::TaggableType, 'The type of this parent.', as: :parent_type
        argument :tagId, !types.ID, 'Unique ID of the tag.', as: :tag_id

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].tags.find(args[:tag_id])
        }

        authorize! ->(tag, _args, ctx) {
          ::Team::TagPolicy.new(ctx[:current_account], tag).add?
        }

        resolve AddTagMutationResolver.new
      end

      class AddTagMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )
          p args

          parent_type = args[:parent_type]
          taggable_type = parent_type.camelize.safe_constantize
          p taggable_type
          parent = taggable_type.find_by(id: args[:parent_id], workspace: ctx[:current_workspace])

          p parent

          inputs = {}.tap do |hash|
            hash[:tag_id] = args[:tag_id]
            hash[:context] = context
            hash[:taggable] = parent
          end

          action = ::Team::Tag::Add.run(inputs)
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
