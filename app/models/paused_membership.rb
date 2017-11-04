class PausedMembership
  PAUSE_DURATION = 90.days

  def initialize(membership:)
    @membership = membership
  end

  def schedule
    membership.update(scheduled_for_reactivation_on: reactivation_date)
    cancel_current_subscription
  end

  def last_billing_date
    Time.zone.at(billing_period_end)
  end

  def reactivation_date
    last_billing_date + PAUSE_DURATION
  end

  protected

  attr_reader :membership

  private

  def cancel_current_subscription
    Cancellation.new(membership: membership).schedule
  end

  def billing_period_end
    stripe_customer.
      subscriptions.
      first.
      current_period_end
  end

  def stripe_customer
    @_stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id)
  end

  def stripe_customer_id
    Workspace.where(id: membership.workspace_id).pluck(:stripe_customer_id).first
  end
end
