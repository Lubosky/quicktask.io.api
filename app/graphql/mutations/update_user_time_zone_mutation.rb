Mutations::UpdateUserTimeZoneMutation = GraphQL::Field.define do
  type Types::UserType
  description 'Signs in a user via Google OAuth.'

  argument :timezone, !types.String, as: :time_zone

  resource ->(_obj, _args, ctx) { ctx[:current_user] }, pass_through: true

  authorize! :update

  resolve UpdateUserTimeZoneResolver.new
end

class UpdateUserTimeZoneResolver
  def call(_obj, args, ctx)
    context = ctx.to_h.slice(:current_user)

    inputs = {}.tap do |hash|
      hash[:time_zone] = args[:timezone]
      hash[:context] = context
    end

    action = ::User::UpdateTimeZone.run(inputs)
    if action.valid?
      action.result
    else
      action.errors
    end
  end
end
