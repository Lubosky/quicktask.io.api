Types::MembershipType = GraphQL::ObjectType.define do
  name 'Membership'
  description ''

  field :id, !types.ID, 'Globally unique ID of the membership.'
  field :uuid, !types.String, 'A unique substitute for a membership ID.'

  field :plan, !Types::PlanType do
    description ''

    resolve ->(obj, _args, _ctx) { obj.plan }
  end

  field :stripe_subscription_id, !types.String, ''
  field :status, types.String, 'Membership’s status. Enum: Trialing, Active, Unpaid, Deactivated.'
  field :quantity, !types.Int, ''
  field :free_license, !types.Boolean, ''
  field :trial_period_end_date, Types::DateTimeType, ''
  field :trial_period_extension_days, !types.Int, ''
  field :scheduled_for_deactivation_on, Types::DateType, ''
  field :deactivated_on, Types::DateType, ''
  field :scheduled_for_reactivation_on, Types::DateType, ''
  field :reactivated_on, Types::DateType, ''
  field :next_payment_amount, Types::BigDecimalType, ''
  field :next_payment_on, Types::DateType, ''

  field :created_at, Types::DateTimeType, 'The time at which this record was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this record was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this record was deleted.'
end
