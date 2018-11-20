Types::TaggableType = GraphQL::EnumType.define do
  name 'Taggable'

  value('CLIENT', value: 'client')
  value('CONTRACTOR', value: 'contractor')
  value('TASK', value: 'task')
end
