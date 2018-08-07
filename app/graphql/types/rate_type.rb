Types::RateType = GraphQL::ObjectType.define do
  name 'Rate'
  description ''

  field :id, !types.ID, 'Globally unique ID of the rate.'
  field :uuid, !types.String, 'A unique substitute for a rate ID.'

  field :rate_type, types.String, ''
  field :classification, types.String, ''
  field :price, !Types::BigDecimalType, ''
  field :currency, Types::CurrencyType, 'The currency of the contractor.'

  field :created_at, Types::DateTimeType, 'The time at which this record was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this record was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this record was deleted.'
end
