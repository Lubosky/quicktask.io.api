class Rate::Client < Rate
  set_rate_type :client

  belongs_to :owner, class_name: '::Client', foreign_key: :owner_id, inverse_of: :client_rates

  delegate :workspace, to: :owner

  after_create :refresh_rates_count
  after_destroy :refresh_rates_count

  def refresh_rates_count
    return unless owner
    Clients::RatesCountService.new(owner).refresh_cache
  end
end
