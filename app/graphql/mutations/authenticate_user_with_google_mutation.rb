Mutations::AuthenticateUserWithGoogleMutation = GraphQL::Field.define do
  type Types::AuthenticationTokenType
  description 'Signs in a user via Google OAuth.'

  argument :code, !types.String, 'An authorization code to exchange for an access token.'

  resolve GoogleAuthenticationResolver.new
end

class GoogleAuthenticationResolver
  def call(_obj, args, _ctx)
    entity = GoogleIdentity.new(args[:code]).authenticate

    if entity.present?
      token = generate_token(entity)

      OpenStruct.new(token: token, me: entity)
    else
      message = 'Invalid credentials'
      GraphQL::ExecutionError.new(message)
    end
  end

  protected

  def generate_token(entity)
    AuthenticationToken.new(payload: entity.to_token_payload).token
  end
end
