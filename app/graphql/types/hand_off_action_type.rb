Types::HandOffActionType = GraphQL::EnumType.define do
  name 'HandOffAction'

  value('ACCEPT', value: 'accept')
  value('REJECT', value: 'reject')
  value('CANCEL', value: 'cancel')
  value('RESEND', value: 'resend')
end
