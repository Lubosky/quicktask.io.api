Types::NoteType = GraphQL::ObjectType.define do
  name 'Note'
  description ''

  field :id, !types.ID, 'Globally unique ID of the note.'
  field :uuid, !types.String, 'A unique substitute for a note ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :parent, Types::AnnotatableType do
    description ''
    before_scope ->(obj, _args, _ctx) {
      if obj.annotatable_type == 'Project'
        AssociationLoader.for(Note, :annotatable).load(obj)
      elsif obj.annotatable_type == 'Task'
        AssociationLoader.for(Note, :annotatable).load(obj)
      end
    }

    resolve ->(resource, _args, _ctx) { resource }
  end

  field :author, Types::ProfileType do
    description ''
    before_scope ->(obj, _args, _ctx) {
      if obj.author_type == 'TeamMember'
        AssociationLoader.for(Note, :author).load(obj)
      end
    }

    resolve ->(resource, _args, _ctx) { resource }
  end

  field :content, types.String, 'The content of the note.'

  field :created_at, Types::DateTimeType, 'The time at which this note was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this note was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this note was deleted.'
end
