Types::ClientRequestType = GraphQL::ObjectType.define do
  name 'ClientRequest'
  description ''

  field :id, !types.ID, 'Globally unique ID of the client request.'
  field :uuid, !types.String, 'A unique substitute for a client request ID.'

  field :client_id, !types.ID, 'Globally unique ID of the client.'
  field :requester_id, !types.ID, 'Globally unique ID of the requester.'
  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :service_id, types.ID, 'Globally unique ID of the service.'
  field :source_language_id, types.ID, 'Globally unique ID of the source language.'
  field :target_language_ids, types[types.ID], 'Globally unique IDs of the target languages.'
  field :unit_id, types.ID, 'Globally unique ID of the source unit.'

  field :request_type, !types.String, ''
  field :status, !types.String, ''

  field :subject, types.String, ''
  field :identifier, types.String, ''
  field :unit_count, types.Int, ''
  field :estimated_cost, !Types::BigDecimalType, ''
  field :notes, types.String, ''

  field :start_date, Types::DateTimeType, ''
  field :due_date, Types::DateTimeType, ''

  field :request_data, Types::JSONType, ''
  field :currency_data, Types::JSONType, ''
  field :metadata, Types::JSONType, ''

  field :client, Types::ClientType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(ClientRequest, :client).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :requester, Types::ClientContactType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(ClientRequest, :requester).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :source_language, Types::LanguageType do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(ClientRequest, :source_language).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :target_languages do
    type types[Types::LanguageType]
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(ClientRequest, :target_languages).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :unit, Types::UnitType do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(ClientRequest, :unit).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :created_at, Types::DateTimeType, 'The time at which this record was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this record was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this record was deleted.'
end
