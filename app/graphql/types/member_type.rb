Types::MemberType = GraphQL::UnionType.define do
  name 'WorkspaceMember'
  description 'Possible workspace member types. [ContractorType, ClientContactType, TeamMemberType]'

  possible_types [
    Types::ContractorType,
    Types::ClientContactType,
    Types::TeamMemberType
  ]
end
