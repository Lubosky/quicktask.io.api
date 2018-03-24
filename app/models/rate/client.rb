class Rate::Client < Rate
  set_rate_type :client

  belongs_to :owner,
             class_name: '::Client',
             foreign_key: :owner_id,
             inverse_of: :client_rates
end
