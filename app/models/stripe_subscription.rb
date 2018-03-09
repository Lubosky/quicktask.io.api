class StripeSubscription
  attr_reader :id

  def initialize(membership)
    @membership = membership
  end

  def create
    rescue_stripe_exception do
      ensure_customer_exists
      update_subscription
    end
  end

  private

  def rescue_stripe_exception
    yield
    true
  rescue Stripe::StripeError => exception
    @membership.
      errors.
      add(:base, exception.message)
    false
  end

  def workspace
    @membership.workspace
  end

  def ensure_customer_exists
    if customer_exists?
      update_card
    else
      create_customer
    end
  end

  def update_card
    stripe_customer.card = @membership.stripe_token
    stripe_customer.save
  end

  def customer_exists?
    @membership.stripe_customer_id.present?
  end

  def create_customer
    new_stripe_customer = Stripe::Customer.create(
      stripe_customer_attributes
    )

    @membership.workspace.stripe_customer_id = new_stripe_customer.id
  end

  def update_subscription
    if stripe_customer.subscriptions.total_count.zero?
      subscription =
        stripe_customer.subscriptions.create(stripe_subscription_attributes)
    else
      subscription = stripe_customer.subscriptions.first
      stripe_subscription_attributes.each { |k, v| subscription[k] = v }
      subscription.save
    end

    @id = subscription.id
  end

  def stripe_subscription_attributes
    base_subscription_attributes.merge(coupon_attributes)
  end

  def base_subscription_attributes
    {
      plan: @membership.stripe_plan_id,
      quantity: @membership.quantity
    }
  end

  def coupon_attributes
    if @membership.stripe_coupon.present?
      { coupon: @membership.stripe_coupon }
    else
      {}
    end
  end

  def stripe_customer_attributes
    {
      source: @membership.stripe_token,
      description: workspace.business_name,
      email: workspace&.owner&.email,
      metadata: metadata_attributes
    }
  end

  def metadata_attributes
    {
      owner_uuid: workspace&.owner&.uuid,
      workspace_uuid: workspace.uuid,
      workspace_name: workspace.name
    }
  end

  def stripe_customer
    @stripe_customer ||=
      Stripe::Customer.retrieve(workspace.stripe_customer_id)
  end
end
