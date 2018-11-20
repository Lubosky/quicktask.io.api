module Mutations
  module Team
    module Tag
      DeleteTagMutation = GraphQL::Field.define do
        type Types::TagType
        description 'Deletes the tag.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :tagId, !types.ID, 'Unique ID of the tag.', as: :tag_id

        resource! ->(_obj, args, ctx) {
          ctx[:current_workspace].tags.find(args[:tag_id])
        }

        authorize! ->(tag, _args, ctx) {
          ::Team::TagPolicy.new(ctx[:current_account], tag).destroy?
        }

        resolve DeleteTagMutationResolver.new
      end

      class DeleteTagMutationResolver
        def call(tag, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          action = ::Team::Tag::Destroy.run(context: context, tag: tag)
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
