Types::Team::ContractorType = GraphQL::ObjectType.define do
  name 'TeamContractor'
  description ''

  field :id, !types.ID, 'Globally unique ID of the contractor.'
  field :uuid, !types.String, 'A unique substitute for a contractor ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :first_name, !types.String, 'The first name of the contractor.'
  field :last_name, !types.String, 'The first name of the contractor.'
  field :email, !types.String, 'The email of the contractor.'
  field :phone, types.String, 'The phone of the contractor.'
  field :currency, !types.String, 'The currency of the contractor.'

  field :created_at, Types::DateTimeType, 'The time at which this record was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this record was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this record was deleted.'
end
