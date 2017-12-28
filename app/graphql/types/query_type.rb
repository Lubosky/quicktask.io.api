Types::QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'Base query type to rule them all'

  field :me, Types::UserType do
    description 'Returns the user record for the currently authenticated user.'

    resolve ->(_obj, _args, ctx) {
      ctx[:current_user]
    }
  end
end
