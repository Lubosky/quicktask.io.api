Types::ProjectStatusType = GraphQL::EnumType.define do
  name 'ProjectStatus'

  value('NO_STATUS', value: 'no_status')
  value('DRAFT', value: 'draft')
  value('PLANNED', value: 'planned')
  value('ACTIVE', value: 'active')
  value('ON_HOLD', value: 'on_hold')
  value('COMPLETED', value: 'completed')
  value('CANCELLED', value: 'cancelled')
  value('ARCHIVED', value: 'archived')
end
