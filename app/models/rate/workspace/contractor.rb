class Rate::Workspace::Contractor < Rate
  set_rate_type :contractor_default

  belongs_to :owner,
             class_name: '::Workspace',
             foreign_key: :owner_id,
             inverse_of: :default_contractor_rates
end
