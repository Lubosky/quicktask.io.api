class Estimator::Base
  DEFAULT_EXCHANGE_RATE = 1.0

  def self.estimate_price(request)
    new(request).estimate_price
  end

  def initialize(request)
    @request = request
  end

  def estimate_price
    calculate_estimated_cost
  end

  private

  attr_reader :request

  def calculate_estimated_cost
    raise NotImplementedError.new
  end

  def calculate_task_price(params)
    rate = fetch_rate(params)

    return total_task_price(rate)
  end

  def fetch_rate(params)
    client.rates.find_by(params)
  end

  def total_task_price(rate)
    return 0 unless rate

    exchange_rate = conversion_rate(rate.currency)
    price = rate.price * exchange_rate

    if flat_fee?
      return price
    else
      return price * unit_count
    end
  end

  def conversion_rate(currency)
    if convert_currency?(currency)
      fetch_exchange_rate(currency)
    else
      DEFAULT_EXCHANGE_RATE
    end
  end

  def convert_currency?(currency)
    currency != workspace_currency
  end

  def workspace_currency
    request.workspace_currency
  end

  def fetch_exchange_rate(currency)
    ExchangeRateService.retrieve(from: workspace_currency, to: currency)
  end

  def rate_params(service_task:, target_language_id: nil)
    {
      classification: service_task.classification,
      source_language_id: request.source_language_id,
      target_language_id: target_language_id,
      task_type_id: service_task.id,
      unit_id: request.unit_id
    }
  end

  def client
    request.client
  end

  def service_tasks
    request.task_types
  end

  def unit
    request.unit
  end

  def unit_count
    request.unit_count
  end

  def unit_type
    unit.unit_type.to_sym
  end

  def flat_fee?
    unit_type == :fixed
  end
end
