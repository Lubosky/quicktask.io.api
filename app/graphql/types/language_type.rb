Types::LanguageType = GraphQL::ObjectType.define do
  name 'Language'
  description ''

  field :id, !types.ID, 'Globally unique ID of the task.'
  field :uuid, !types.String, 'A unique substitute for a task ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :code, !types.String, 'ISO language code.'
  field :name, !types.String, 'Name of the language.'
  field :is_preferred, types.Boolean do
    description ''
    property :preferred
  end
end

