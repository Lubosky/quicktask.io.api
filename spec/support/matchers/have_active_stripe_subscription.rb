RSpec::Matchers.define :have_active_stripe_subscription do |plan|
  match do |stripe_customer|
    stripe_customer.subscriptions.first.plan.id == plan.stripe_plan_id
  end
end
