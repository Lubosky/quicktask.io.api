Types::ClientType = GraphQL::ObjectType.define do
  name 'Client'
  description ''

  field :id, !types.ID, 'Globally unique ID of the client.'
  field :uuid, !types.String, 'A unique substitute for a client ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :name, !types.String, 'The name of the client.'
  field :email, types.String, 'The email of the client.'
  field :phone, types.String, 'The phone of the client.'
  field :currency, types.String, 'The currency of the client.'

  field :created_at, Types::DateTimeType, 'The time at which this record was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this record was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this record was deleted.'
end
