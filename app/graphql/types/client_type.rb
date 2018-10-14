Types::ClientType = GraphQL::ObjectType.define do
  name 'Client'
  description ''

  field :id, !types.ID, 'Globally unique ID of the client.'
  field :uuid, !types.String, 'A unique substitute for a client ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :name, !types.String, 'The name of the client.'
  field :email, types.String, 'The email of the client.'
  field :phone, types.String, 'The phone of the client.'
  field :currency, Types::CurrencyType, 'The currency of the client.'
  field :tax_number, types.String, 'The tax number of the client.'

  field :client_rates, types[!Types::RateType] do
    description ''

    before_scope ->(obj, args, _ctx) {
      AssociationLoader.for(Client, :client_rates).load(obj)
    }

    resolve ->(collection, _args, _ctx) { collection }
  end

  field :tags, types[!Types::TagType] do
    description ''
    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Client, :tags).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :created_at, Types::DateTimeType, 'The time at which this record was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this record was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this record was deleted.'
end
