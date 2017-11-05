class MembershipUpcomingInvoiceUpdater
  def initialize(memberships)
    @memberships = memberships
  end

  def process
    @memberships.each do |membership|
      stripe_customer_id = stripe_customer_id_for_membership(membership)

      if stripe_customer_id.present?
        upcoming_invoice = upcoming_invoice_for(stripe_customer_id)
        update_next_payment_information(membership, upcoming_invoice)
      end
    end
  end

  private

  def upcoming_invoice_for(stripe_customer_id)
    Stripe::Invoice.upcoming(customer: stripe_customer_id)
  rescue Stripe::InvalidRequestError => error
    capture_exception(error)
    nil
  end

  def update_next_payment_information(membership, upcoming_invoice)
    if upcoming_invoice
      update_next_payment_information_from_upcoming_invoice(membership, upcoming_invoice)
    else
      clear_next_payment_information(membership)
    end
  end

  def update_next_payment_information_from_upcoming_invoice(membership, upcoming_invoice)
    membership.update!(
      next_payment_amount: upcoming_invoice.total.to_f / 100,
      next_payment_on: Time.zone.at(upcoming_invoice.period_end)
    )
  end

  def clear_next_payment_information(membership)
    membership.update!(
      next_payment_amount: 0,
      next_payment_on: nil
    )
  end

  def stripe_customer_id_for_membership(membership)
    Workspace.where(id: membership.workspace_id).pluck(:stripe_customer_id).first
  end

  def capture_exception(error)
    unless error_is_because_user_has_no_upcoming_invoice?(error)
      Raven.capture_exception(error)
    end
  end

  def error_is_because_user_has_no_upcoming_invoice?(error)
    error.http_status == 404
  end
end
