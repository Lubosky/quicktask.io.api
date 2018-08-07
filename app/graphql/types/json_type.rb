Types::JSONType = GraphQL::ScalarType.define do
  name 'JSON'

  coerce_input ->(value, _ctx) { value.deep_transform_keys!(&:underscore) }
  coerce_result ->(value, _ctx) { value.deep_transform_keys! { |key| key.camelize(:lower) } }
end
