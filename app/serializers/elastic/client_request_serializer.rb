class Elastic::ClientRequestSerializer < BaseSerializer
  set_id    :id
  set_type  :client_request

  attribute :id
  attribute :workspace_id do |o|
    o.workspace_id.to_s
  end

  attribute :client_id do |o|
    o.client_id.to_s
  end

  attribute :requester_id do |o|
    o.requester_id.to_s
  end

  attribute :service_id do |o|
    o.service_id.to_s
  end

  attribute :quote_id do |o|
    o.quote_id.to_s
  end

  attributes :subject,
             :identifier,
             :status,
             :client,
             :requester,
             :quote,
             :service,
             :unit_count,
             :estimated_cost,
             :currency,
             :workspace_currency,
             :exchange_rate,
             :start_date,
             :due_date,
             :submitted_at,
             :estimated_at,
             :cancelled_at,
             :withdrawn_at,
             :created_at,
             :updated_at
end
