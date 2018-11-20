module Mutations
  module Team
    module Tag
      CreateSingleTagMutation = GraphQL::Field.define do
        type Types::TagType
        description 'Creates a tag and attaches it to parent record.'

        argument :workspaceId, !types.ID, as: :workspace_id
        argument :accountType, !Types::ImpersonationType, as: :account_type

        argument :parentId, !types.ID, 'Unique ID of the parent.', as: :parent_id
        argument :parentType, !Types::TaggableType, 'The type of this parent.', as: :parent_type
        argument :input, Inputs::Team::Tag::BaseInput

        authorize! ->(_obj, _args, ctx) {
          ::Team::TagPolicy.new(ctx[:current_account], ::Tag).create?
        }

        resolve CreateSingleTagMutationResolver.new
      end

      class CreateSingleTagMutationResolver
        def call(_obj, args, ctx)
          context = ctx.to_h.slice(
            :current_user,
            :current_workspace,
            :current_account,
            :request
          )

          parent_type = args[:parent_type]
          taggable_type = parent_type.camelize.safe_constantize

          parent = taggable_type.find_by(id: args[:parent_id], workspace: ctx[:current_workspace])

          inputs = {}.tap do |hash|
            hash.merge!(args[:input].to_h)
            hash[:context] = context
            hash[:taggable] = parent
          end

          action = ::Team::Tag::Create.run(inputs)
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
