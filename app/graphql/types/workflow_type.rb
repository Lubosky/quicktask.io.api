Types::WorkflowType = GraphQL::EnumType.define do
  name 'WorkflowType'

  value('NONE', value: 'none')
  value('DEFAULT', value: 'default')
  value('CUSTOM', value: 'custom')
end
