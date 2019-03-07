Types::RateTypeType = GraphQL::EnumType.define do
  name 'RateType'

  value('CLIENT_DEFAULT', value: 'client_default')
  value('CONTRACTOR_DEFAULT', value: 'contractor_default')
  value('CLIENT', value: 'client')
  value('CONTRACTOR', value: 'contractor')
end
