Types::UnitType = GraphQL::ObjectType.define do
  name 'Unit'
  description ''

  field :id, !types.ID, 'Globally unique ID of the task.'
  field :uuid, !types.String, 'A unique substitute for a task ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :unit_type, !types.String, ''
  field :name, !types.String, 'Name of the unit.'

  field :is_deletable, types.Boolean do
    description ''
    property :deletable
  end

  field :is_internal, types.Boolean do
    description ''
    property :internal
  end

  field :is_preferred, types.Boolean do
    description ''
    property :preferred
  end
end
