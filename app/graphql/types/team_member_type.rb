Types::TeamMemberType = GraphQL::ObjectType.define do
  name 'TeamMember'
  description ''

  field :id, !types.ID, 'Globally unique ID of the team member.'
  field :uuid, !types.String, 'A unique substitute for a team member ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :name, types.String, 'The name of the contractor.'
  field :title, types.String, 'Team member title or position.'
  field :first_name, types.String, 'The first name of the team member.'
  field :last_name, types.String, 'The last name of the team member.'
  field :email, types.String, 'The email of the team member.'

  field :created_at, Types::DateTimeType, 'The time at which this record was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this record was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this record was deleted.'
end
