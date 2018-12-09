class ContractorSerializer < BaseSerializer
  set_id    :id
  set_type  :contractor

  attributes :first_name,
             :last_name,
             :business_name,
             :email,
             :phone,
             :business_settings,
             :tax_settings,
             :currency,
             :workspace_id
end
