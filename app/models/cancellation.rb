class Cancellation
  include ActiveModel::Model

  def initialize(membership:)
    @membership = membership
  end

  def schedule
    if valid?
      cancel_at_period_end
      true
    else
      false
    end
  end

  def cancel_now
    Membership.transaction do
      stripe_customer.subscriptions.first.delete
      @membership.deactivate
    end
  end

  def process
    if @membership.active?
      @membership.deactivate
    end
  end

  private

  def cancel_at_period_end
    Membership.transaction do
      stripe_customer.subscriptions.first.delete(at_period_end: true)
      record_date_when_membership_will_deactivate
    end
  end

  def record_date_when_membership_will_deactivate
    @membership.update_column(
      :scheduled_for_deactivation_on,
      end_of_billing_period,
    )
  end

  def end_of_billing_period
    Time.zone.at(stripe_customer.subscriptions.first.current_period_end)
  end

  def stripe_customer
    @stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id)
  end

  def stripe_customer_id
    Workspace.where(id: @membership.workspace_id).pluck(:stripe_customer_id).first
  end
end
