Types::BookkeepableType = GraphQL::UnionType.define do
  name 'BookkeepableType'
  description 'Possible bookkeepable types. [PurchaseOrderType]'

  possible_types [
    Types::PurchaseOrderType
  ]
end
