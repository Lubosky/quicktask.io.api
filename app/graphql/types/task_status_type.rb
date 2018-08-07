Types::TaskStatusType = GraphQL::EnumType.define do
  name 'TaskStatus'

  value('COMPLETED', value: 'completed')
  value('UNCOMPLETED', value: 'uncompleted')
  value('RESET', value: 'reset')
end
