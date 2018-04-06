class SerializableClient < SerializableBase
  type :client

  attribute :name
  attribute :email
  attribute :phone

  attribute :business_settings
  attribute :tax_number
  attribute :tax_rate
  attribute :currency

  attribute :workspace_id
end
