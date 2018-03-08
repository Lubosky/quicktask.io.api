Types::AuthenticationTokenType = GraphQL::ObjectType.define do
  name 'AuthenticationToken'
  description ''

  field :token, !types.String do
    description 'Authentication token authenticating the HTTP requests.'
  end

  field :me, !Types::UserType do
    description 'Returns the user record for the currently authenticated user.'
  end
end
