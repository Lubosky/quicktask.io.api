Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'
  description 'Base mutation type to rule them all.'

  field :authenticateUser, Mutations::AuthenticateUserMutation
  field :authenticateUserWithGoogle, Mutations::AuthenticateUserWithGoogleMutation
end
