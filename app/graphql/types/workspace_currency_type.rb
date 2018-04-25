Types::WorkspaceCurrencyType = GraphQL::ObjectType.define do
  name 'WorkspaceCurrency'
  description ''

  field :id, !types.ID, 'Globally unique ID of the workspace currency.'
  field :uuid, !types.String, 'A unique substitute for a workspace currency ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :currency, Types::CurrencyType, 'The code of the currency.', property: :code
  field :exchange_rate, types.String, 'The exchange rate against workspace default currency.'

  field :created_at, Types::DateTimeType, 'The time at which this workspace currency was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this workspace currency was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this workspace currency was deleted.'
end
