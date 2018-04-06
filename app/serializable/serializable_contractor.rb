class SerializableContractor < SerializableBase
  type :contractor

  attribute :first_name
  attribute :last_name
  attribute :business_name
  attribute :email
  attribute :phone

  attribute :business_settings
  attribute :tax_settings
  attribute :currency

  attribute :workspace_id

  has_many :contractor_rates
end
