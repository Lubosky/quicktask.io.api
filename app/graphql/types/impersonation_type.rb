Types::ImpersonationType = GraphQL::EnumType.define do
  name 'Impersonation'

  value('CLIENT_CONTACT', value: 'client_contact')
  value('CONTRACTOR', value: 'contractor')
  value('TEAM_MEMBER', value: 'team_member')
end
