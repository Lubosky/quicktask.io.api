class Elastic::QuoteSerializer < BaseSerializer
  set_id    :id
  set_type  :quote

  attribute :id
  attribute :workspace_id do |o|
    o.workspace_id.to_s
  end

  attribute :client_id do |o|
    o.client_id.to_s
  end

  attribute :owner_id do |o|
    o.owner_id.to_s
  end

  attribute :client_request_id do |o|
    o.client_request_id.to_s
  end

  attribute :project_id do |o|
    o.project_id.to_s
  end

      discount: discount,
      surcharge: surcharge,
      subtotal: subtotal,
      total: total,
      has_client_request: client_request.present?,
      has_project: project.present?,
      currency: currency,
      workspace_currency: workspace_currency,
      exchange_rate: exchange_rate,
      issue_date: issue_date,
      expiry_date: expiry_date,
      start_date: start_date,
      due_date: due_date,
      accepted_at: accepted_at,
      cancelled_at: cancelled_at,
      declined_at: declined_at,
      sent_at: sent_at,
      created_at: created_at,
      updated_at: updated_at,
  attributes :type,
             :subject,
             :identifier,
             :purchase_order_number,
             :status,
             :client,
             :owner,
             :client_request,
             :project,
             :discount,
             :surcharge,
             :subtotal,
             :total,
             :currency,
             :workspace_currency,
             :exchange_rate,
             :issue_date,
             :expiry_date,
             :start_date,
             :due_date,
             :sent_at,
             :accepted_at,
             :cancelled_at,
             :declined_at,
             :created_at,
             :updated_at
end
