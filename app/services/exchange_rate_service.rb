class ExchangeRateService
  DEFAULT_RATE = 1.0

  def self.retrieve(from:, to:)
    new(from, to).retrieve
  end

  def initialize(from, to)
    @currency_from = from
    @currency_to = to
  end

  def retrieve
    Money.default_bank.get_rate(@currency_from, @currency_to)
  rescue
    DEFAULT_RATE
  end
end
