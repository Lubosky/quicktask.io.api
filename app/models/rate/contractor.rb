class Rate::Contractor < Rate
  set_rate_type :contractor

  belongs_to :owner, class_name: '::Contractor', foreign_key: :owner_id, inverse_of: :contractor_rates

  delegate :workspace, to: :owner

  after_create :refresh_rates_count
  after_destroy :refresh_rates_count

  def refresh_rates_count
    return unless owner
    Contractors::RatesCountService.new(owner).refresh_cache
  end
end
