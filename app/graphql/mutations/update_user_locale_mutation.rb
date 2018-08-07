Mutations::UpdateUserLocaleMutation = GraphQL::Field.define do
  type Types::UserType
  description 'Updates a user’s language interface.'

  argument :language, !types.String, as: :locale

  resource ->(_obj, _args, ctx) { ctx[:current_user] }, pass_through: true

  authorize! :update

  resolve UpdateUserLocaleResolver.new
end

class UpdateUserLocaleResolver
  def call(_obj, args, ctx)
    context = ctx.to_h.slice(:current_user)

    inputs = {}.tap do |hash|
      hash[:locale] = args[:language]
      hash[:context] = context
    end

    action = ::User::UpdateLocale.run(inputs)
    if action.valid?
      action.result
    else
      action.errors
    end
  end
end
