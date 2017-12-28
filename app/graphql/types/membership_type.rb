Types::MembershipType = GraphQL::ObjectType.define do
  name 'Membership'
  description ''

  field :id, !types.ID do
    description 'Globally unique ID of the membership.'
  end

  field :uuid, !types.String do
    description 'A unique substitute for a Membership ID.'
  end

  field :plan, !Types::PlanType do
    description ''

    resolve ->(obj, _args, _ctx) { obj.plan }
  end

  field :stripeSubscriptionId, !types.String do
    description ''
    property :stripe_subscription_id
  end

  field :status, types.String do
    description 'Membership’s status. Enum: Trialing, Active, Unpaid, Deactivated.'
  end

  field :quantity, !types.Int do
    description ''
  end

  field :freeLicense, !types.Boolean do
    description ''
    property :free_license
  end

  field :trialPeriodEndDate, Types::DateTimeType do
    description ''
    property :trial_period_end_date
  end

  field :trialPeriodExtensionDays, !types.Int do
    description ''
    property :trial_period_extension_days
  end

  field :scheduledForDeactivationOn, Types::DateType do
    description ''
    property :scheduled_for_deactivation_on
  end

  field :deactivatedOn, Types::DateType do
    description ''
    property :deactivated_on
  end

  field :scheduledForReactivationOn, Types::DateType do
    description ''
    property :scheduled_for_reactivation_on
  end

  field :reactivatedOn, Types::DateType do
    description ''
    property :reactivated_on
  end

  field :nextPaymentAmount, Types::BigDecimalType do
    description ''
    property :next_payment_amount
  end

  field :nextPaymentOn, Types::DateType do
    description ''
    property :next_payment_on
  end

  field :createdAt, Types::DateTimeType do
    description 'The time at which this membership was created.'
    property :created_at
  end

  field :updatedAt, Types::DateTimeType do
    description 'The time at which this membership was last modified.'
    property :updated_at
  end

  field :deletedAt, Types::DateTimeType do
    description 'The time at which this membership was deleted.'
    property :deleted_at
  end
end
