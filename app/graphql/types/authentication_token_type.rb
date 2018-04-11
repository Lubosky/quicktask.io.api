Types::AuthenticationTokenType = GraphQL::ObjectType.define do
  name 'AuthenticationToken'
  description ''

  field :token, !types.String, 'Authentication token authenticating the HTTP requests.'
  field :me, !Types::UserType, 'Returns the user record for the currently authenticated user.'
end
