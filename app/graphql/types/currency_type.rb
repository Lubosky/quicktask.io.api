Types::CurrencyType = GraphQL::ScalarType.define do
  name 'Currency'

  coerce_input ->(value, _ctx) { value.downcase.to_s }
  coerce_result ->(value, _ctx) {
    if currency = Money::Currency.find(value)
      {}.tap do |hash|
        hash[:code] = currency.id
        hash[:isoCode] = currency.iso_code
        hash[:name] = currency.name
        hash[:symbol] = currency.symbol
      end
    else
      nil
    end
  }
end
