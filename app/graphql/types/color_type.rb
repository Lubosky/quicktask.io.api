Types::ColorType = GraphQL::ScalarType.define do
  name 'Color'

  coerce_input ->(value, _ctx) { value.underscore }
  coerce_result ->(value, _ctx) { value.camelize(:lower) }
end
