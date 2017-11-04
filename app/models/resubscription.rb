class Resubscription
  def initialize(plan:, quantity:, workspace:)
    @plan = plan
    @quantity = quantity
    @workspace = workspace
  end

  attr_reader :plan, :quantity, :workspace

  def fulfill
    if former_subscriber?
      stripe_subscription_id = create_new_stripe_subscription
      update_membership(stripe_subscription_id)
      true
    end
  end

  private

  def former_subscriber?
    has_no_subscription? && stripe_customer?
  end

  def has_no_subscription?
    !workspace.subscribed?
  end

  def stripe_customer?
    workspace.has_credit_card?
  end

  def stripe_customer_id
    workspace.stripe_customer_id
  end

  def create_new_stripe_subscription
    stripe_customer.subscriptions.create(
      plan: plan.stripe_plan_id,
      quantity: quantity
    ).id
  end

  def update_membership(stripe_subscription_id)
    workspace.membership.update_attributes(
      deactivated_on: nil,
      plan: plan,
      quantity: quantity,
      scheduled_for_deactivation_on: nil,
      stripe_subscription_id: stripe_subscription_id
    )
  end

  def stripe_customer
    if stripe_customer?
      @stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id)
    end
  end
end
