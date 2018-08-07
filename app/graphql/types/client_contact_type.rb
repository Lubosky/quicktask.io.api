Types::ClientContactType = GraphQL::ObjectType.define do
  name 'ClientContact'
  description ''

  field :id, !types.ID, 'Globally unique ID of the client contact.'
  field :uuid, !types.String, 'A unique substitute for a client contact ID.'

  field :client_id, !types.ID, 'Globally unique ID of the client.'
  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :title, types.String, 'Client contact title or position.'
  field :first_name, types.String, 'The first name of the client contact.'
  field :last_name, types.String, 'The last name of the client contact.'
  field :email, types.String, 'The email of the client contact.'
  field :phone_office, types.String, 'The office phone number of the client contact.'
  field :phone_mobile, Types::CurrencyType, 'The mobile phone number of the client contact.'

  field :created_at, Types::DateTimeType, 'The time at which this record was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this record was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this record was deleted.'
end
