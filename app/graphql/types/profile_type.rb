Types::ProfileType = GraphQL::UnionType.define do
  name 'Profile'
  description 'Possible workspace account types. [ContractorType, ClientContactType, TeamMemberType]'

  possible_types [
    Types::ContractorType,
    Types::ClientContactType,
    Types::TeamMemberType
  ]
end
