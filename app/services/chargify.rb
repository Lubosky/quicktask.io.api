class Chargify
  def initialize(stripe_invoice)
    @stripe_invoice = stripe_invoice
  end

  def process
    record_charge
  end

  private

  attr_reader :stripe_invoice

  def record_charge
    return unless workspace.present?
    workspace.charges.create!(charge_attributes)
  end

  def charge_attributes
    {
      stripe_charge_id: stripe_charge_id,
      stripe_invoice_id: stripe_invoice_id,
      amount: amount,
      description: description,
      paid_through_date: paid_through_date,
      source: payment_source
    }
  end

  def amount
    cents_to_decimal(stripe_invoice.total)
  end

  def cents_to_decimal(amount)
    amount / 100.0
  end

  def description
    stripe_plan.name
  end

  def paid_through_date
    Time.at(subscription_period&.end).to_date
  end

  def payment_source
    {
      type: stripe_charge&.source&.object,
      brand: stripe_charge&.source&.brand,
      exp_month: stripe_charge&.source&.exp_month,
      exp_year: stripe_charge&.source&.exp_year,
      last4: stripe_charge&.source&.last4
    }
  end

  def subscription_period
    stripe_subscription&.period
  end

  def stripe_subscription
    stripe_invoice&.lines&.data&.first
  end

  def stripe_plan
    stripe_subscription.plan
  end

  def stripe_charge
    if stripe_charge_id.present?
      Stripe::Charge.retrieve(stripe_charge_id)
    end
  end

  def stripe_charge_id
    stripe_invoice&.charge
  end

  def stripe_invoice_id
    stripe_invoice.id
  end

  def workspace
    @workspace ||= Workspace.find_by(stripe_customer_id: stripe_invoice.customer)
  end
end
