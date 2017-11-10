class SerializableMembership < SerializableBase
  type :membership

  attribute :workspace_id
  attribute :plan_id
  attribute :owner_id
  attribute :subscription_id do
    @object.stripe_subscription_id
  end

  attribute :status
  attribute :quantity
  attribute :billing_interval
  attribute :free_license
  attribute :trial_end_date do
    @object.trial_period_end_date
  end
  attribute :trial_extension_days do
    @object.trial_period_extension_days
  end
  attribute :scheduled_for_deactivation_on
  attribute :deactivated_on
  attribute :scheduled_for_reactivation_on
  attribute :reactivated_on
  attribute :next_payment_amount
  attribute :next_payment_on
  attribute :coupons do
    @object.coupon_codes
  end
  attribute :metadata
end
