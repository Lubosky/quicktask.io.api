class ClientSerializer < BaseSerializer
  set_id    :id
  set_type  :client

  attributes :name,
             :email,
             :phone,
             :business_settings,
             :tax_number,
             :tax_rate,
             :currency,
             :workspace_id
end
