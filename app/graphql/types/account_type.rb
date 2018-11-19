Types::AccountType = GraphQL::UnionType.define do
  name 'Account'
  description 'Possible workspace account types. [ContractorType, ClientContactType, TeamMemberType]'

  possible_types [
    Types::ContractorType,
    Types::ClientContactType,
    Types::TeamMemberType
  ]
end
