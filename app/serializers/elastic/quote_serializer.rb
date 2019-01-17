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

  attributes :type,
             :subject,
             :identifier,
             :purchase_order_number,
             :status,
             :client_name,
             :owner_name,
             :client_request_identifier,
             :project_name,
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
