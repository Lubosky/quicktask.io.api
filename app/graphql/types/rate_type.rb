Types::RateType = GraphQL::ObjectType.define do
  name 'Rate'
  description ''

  field :id, !types.ID, 'Globally unique ID of the rate.'
  field :uuid, !types.String, 'A unique substitute for a rate ID.'


  field :source_language_id, types.ID, 'Globally unique ID of the language.'
  field :source_language, Types::LanguageType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Rate, :source_language).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :target_language_id, types.ID, 'Globally unique ID of the language.'
  field :target_language, Types::LanguageType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Rate, :target_language).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :task_type_id, types.ID, 'Globally unique ID of the task type.'
  field :task_type, Types::TaskTypeType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Rate, :task_type).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :unit_id, types.ID, 'Globally unique ID of the unit.'
  field :unit, Types::UnitType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Rate, :unit).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :rate_type, types.String, ''
  field :classification, types.String, ''
  field :price, !Types::BigDecimalType, ''
  field :currency, Types::CurrencyType, 'The currency of the contractor.'

  field :default_contractor, Types::ContractorType do
    description ''

    before_scope ->(obj, _args, _ctx) {
      return nil unless obj.rate_type.to_sym.in?([:client, :client_default])
      klass = obj.rate_type.to_sym == :client ? Rate::Client : Rate::Workspace::Client
      AssociationLoader.for(klass, :default_contractor).load(obj)
    }

    resolve ->(resource, _args, _ctx) { resource }
  end

  field :created_at, Types::DateTimeType, 'The time at which this record was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this record was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this record was deleted.'
end
