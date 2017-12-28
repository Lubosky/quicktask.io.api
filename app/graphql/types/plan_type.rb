Types::PlanType = GraphQL::ObjectType.define do
  name 'Plan'
  description ''

  field :id, !types.ID do
    description 'Globally unique ID of the membership.'
  end

  field :uuid, !types.String do
    description 'A unique substitute for a Membership ID.'
  end

  field :stripePlanId, !types.String do
    description ''
    property :stripe_plan_id
  end

  field :name, !types.String do
    description ''
  end

  field :price, !Types::BigDecimalType do
    description ''
    property :price
  end

  field :billingInterval, !types.String do
    description ''
    property :billing_interval
  end

  field :trialPeriodDays, !types.Int do
    description ''
    property :trial_period_days
  end

  field :createdAt, Types::DateTimeType do
    description 'The time at which this plan was created.'
    property :created_at
  end

  field :updatedAt, Types::DateTimeType do
    description 'The time at which this plan was last modified.'
    property :updated_at
  end

  field :deletedAt, Types::DateTimeType do
    description 'The time at which this plan was deleted.'
    property :deleted_at
  end
end
