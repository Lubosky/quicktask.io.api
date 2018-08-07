Mutations::UpdateUserPasswordMutation = GraphQL::Field.define do
  type Types::UserType
  description ''

  argument :input, Inputs::User::PasswordInput

  resource ->(_obj, _args, ctx) { ctx[:current_user] }, pass_through: true

  authorize! :update

  resolve UpdateUserPasswordResolver.new
end

class UpdateUserPasswordResolver
  def call(_obj, args, ctx)
    context = ctx.to_h.slice(:current_user)

    inputs = {}.tap do |hash|
      hash.merge!(args[:input].to_h)
      hash[:context] = context
    end

    action = ::Password::Update.run(inputs)
    if action.valid?
      action.result
    else
      action.errors
    end
  end
end
