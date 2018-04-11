Types::PlanType = GraphQL::ObjectType.define do
  name 'Plan'
  description ''

  field :id, !types.ID, 'Globally unique ID of the plan.'
  field :uuid, !types.String, 'A unique substitute for a plan ID.'

  field :stripe_plan_id, !types.String, ''
  field :name, !types.String, ''
  field :price, !Types::BigDecimalType, ''
  field :billing_interval, !types.String, ''
  field :trial_period_days, !types.Int, ''

  field :created_at, Types::DateTimeType, 'The time at which this record was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this record was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this record was deleted.'
end
