class Rate::Contractor < Rate
  set_rate_type :contractor

  belongs_to :owner, class_name: '::Contractor', foreign_key: :owner_id, inverse_of: :contractor_rates

  delegate :workspace, to: :owner
end
