Types::DateTimeType = GraphQL::ScalarType.define do
  name 'DateTime'

  coerce_input ->(value, _ctx) { Time.zone.parse(value).to_datetime }
  coerce_result ->(value, _ctx) { value.utc.iso8601 }
end
