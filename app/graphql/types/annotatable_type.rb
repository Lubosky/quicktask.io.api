Types::AnnotatableType = GraphQL::UnionType.define do
  name 'Annotatable'
  description 'Possible annotatable types. [ProjectType, TaskType]'

  possible_types [
    Types::ProjectType,
    Types::TaskType
  ]
end
