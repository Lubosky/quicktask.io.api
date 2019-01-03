Types::QuoteType = GraphQL::ObjectType.define do
  name 'Quote'
  description ''

  field :id, !types.ID, 'Globally unique ID of the client request.'
  field :uuid, !types.String, 'A unique substitute for a client request ID.'

  field :client_id, !types.ID, 'Globally unique ID of the client.'
  field :owner_id, !types.ID, 'Globally unique ID of the owner.'
  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :quote_type, !types.String, ''
  field :status, !types.String, ''

  field :subject, types.String, ''
  field :identifier, types.String, ''
  field :purchase_order_number, types.String, ''
  field :purchase_order_data, types.String, ''
  field :notes, types.String, ''
  field :terms, types.String, ''

  field :issue_date, Types::DateTimeType, ''
  field :expiry_date, Types::DateTimeType, ''
  field :start_date, Types::DateTimeType, ''
  field :due_date, Types::DateTimeType, ''

  field :quote_data, Types::JSONType, ''
  field :currency_data, Types::JSONType, ''
  field :settings, Types::JSONType, ''
  field :metadata, Types::JSONType, ''

  field :discount, !Types::BigDecimalType, ''
  field :surcharge, !Types::BigDecimalType, ''
  field :subtotal, !Types::BigDecimalType, ''
  field :total, !Types::BigDecimalType, ''

  field :is_billed, types.Boolean do
    description ''
    property :billed?
  end


  field :client, Types::ClientType do
    description ''

    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Quote, :client).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :owner, Types::TeamMemberType do
    description ''

    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Quote, :owner).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :client_request, Types::ClientRequestType do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Quote, :client_request).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :project, Types::ProjectType do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Quote, :project).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :line_items do
    type types[!Types::LineItemType]
    description ''

    before_scope ->(obj, _args, ctx) { AssociationLoader.for(Quote, :line_items).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :created_at, Types::DateTimeType, 'The time at which this record was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this record was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this record was deleted.'
end
