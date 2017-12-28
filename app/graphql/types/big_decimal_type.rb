Types::BigDecimalType = GraphQL::ScalarType.define do
  name 'BigDecimal'

  coerce_input ->(value, _ctx) { value.to_s }
  coerce_result ->(value, _ctx) { value.to_d }
end
