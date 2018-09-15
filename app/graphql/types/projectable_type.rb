Types::ProjectableType = GraphQL::UnionType.define do
  name 'ProjectableType'
  description 'Possible projectable types. [ProjectType, ProjectTemplateType]'

  possible_types [
    Types::ProjectType,
    Types::ProjectTemplateType
  ]
end
