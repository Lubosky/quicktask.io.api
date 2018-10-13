Types::TagType = GraphQL::ObjectType.define do
  name 'Tag'
  description 'A tag is a label that can be attached to some of the records in the application.'

  field :id, !types.ID, 'Globally unique ID of the tag.'
  field :uuid, !types.String, 'A unique substitute for a tag ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :name, !types.String, 'Name of the tag.'
  field :color, types.Int, 'Color of the tag.'
  field :tagging_count, !types.Int, ''

  field :created_at, Types::DateTimeType, 'The time at which this tag was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this tag was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this tag was deleted.'
end
