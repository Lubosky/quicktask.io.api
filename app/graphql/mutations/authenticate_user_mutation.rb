Mutations::AuthenticateUserMutation = GraphQL::Field.define do
  type Types::AuthenticationTokenType
  description 'Signs in a user with an email address and password.'

  argument :email, !types.String, 'The user’s email address.'
  argument :password, !types.String, 'The user’s password.'

  resolve AuthenticationResolver.new
end

class AuthenticationResolver
  def call(_obj, args, _ctx)
    entity = User.find_by_normalized_email(args[:email])

    if entity.present? &&
       entity.password_digest.present? &&
       entity.authenticate(args[:password])

      token = generate_token(entity)

      OpenStruct.new(token: token, me: entity)
    else
      message = 'Invalid email or password'
      GraphQL::ExecutionError.new(message)
    end
  end

  protected

  def generate_token(entity)
    AuthenticationToken.new(payload: entity.to_token_payload).token
  end
end
