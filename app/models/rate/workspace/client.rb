class Rate::Workspace::Client < Rate
  set_rate_type :client_default

  belongs_to :owner,
             class_name: '::Workspace',
             foreign_key: :owner_id,
             inverse_of: :default_client_rates
end
