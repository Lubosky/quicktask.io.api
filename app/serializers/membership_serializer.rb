class MembershipSerializer < BaseSerializer
  set_id    :id
  set_type  :membership

  attributes :workspace_id,
             :plan_id,
             :owner_id,
             :status,
             :quantity,
             :billing_interval,
             :free_license,
             :scheduled_for_deactivation_on,
             :deactivated_on,
             :scheduled_for_reactivation_on,
             :reactivated_on,
             :next_payment_amount,
             :next_payment_on,
             :metadata

  attribute :subscription_id do |object|
    object.stripe_subscription_id
  end

  attribute :trial_end_date do |object|
    object.trial_period_end_date
  end

  attribute :trial_extension_days do |object|
    object.trial_period_extension_days
  end

  attribute :coupons do |object|
    object.coupon_codes
  end

end
