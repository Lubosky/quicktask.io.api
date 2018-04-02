class Converter::ClientRequest
  def self.convert(request, user)
    new(request, user).convert
  end

  def initialize(request, user)
    @request = request
    @user = user
  end

  def convert
    return request.quote if request.quote
    fulfill_conversion
  end

  private

  attr_reader :request, :user

  COPYABLE_ATTRIBUTES = %i(
    client_id
    workspace_id
    start_date
    due_date
    currency
    workspace_currency
    exchange_rate
  )

  DEFAULT_COUNT = 1.0
  DEFAULT_EXCHANGE_RATE = 1.0


  def fulfill_conversion
    ::Quote.transaction do
      entry = build_quote
      entry.tap do |quote|
        quote.save!
        quote.client_request = request
        quote.update_totals
      end
    end
  end

  def build_quote
    permitted_attributes = request.slice(COPYABLE_ATTRIBUTES).tap do |hash|
      hash[:owner] = user
      hash[:subject] = compose_subject
      hash[:notes] = compose_notes
      hash[:line_items_attributes] = build_line_items
    end

    ::Quote.new(permitted_attributes)
  end

  def build_line_items
    line_items = []

    if language_service_request?
      request.target_language_ids.each do |target_language_id|
        line_item = build_line_item(target_language_id: target_language_id)
        line_items.push(line_item) if line_item
      end
    else
      line_item = build_line_item
      line_items.push(line_item) if line_item
    end

    return line_items
  end

  def build_line_item(target_language_id: nil)
    service_tasks.each do |service_task|
      rate_params = rate_params(
        target_language_id: target_language_id,
        task_type: service_task
      )

      price = fetch_rate(rate_params)

      line_item_params = line_item_params(
        target_language_id: target_language_id,
        task_type: service_task,
        unit_price: price
      )

      return line_item_params
    end
  end

  def line_item_params(target_language_id: nil, task_type:, unit_price:)
    {
      quantity: quantity,
      source_language_id: request.source_language_id,
      target_language_id: target_language_id,
      task_type_id: task_type.id,
      unit_id: request.unit_id,
      unit_price: unit_price
    }
  end

  def rate_params(target_language_id: nil, task_type:)
    {
      classification: task_type.classification,
      source_language_id: request.source_language_id,
      target_language_id: target_language_id,
      task_type_id: task_type.id,
      unit_id: request.unit_id
    }
  end

  def fetch_rate(params)
    rate = client.rates.find_by(params)

    return unit_price(rate)
  end

  def unit_price(rate)
    return 0 unless rate

    exchange_rate = conversion_rate(rate.currency)
    price = rate.price * exchange_rate

    return price
  end

  def conversion_rate(currency)
    if convert_currency?(currency)
      fetch_exchange_rate(currency)
    else
      DEFAULT_EXCHANGE_RATE
    end
  end

  def convert_currency?(currency)
    currency != client_currency
  end

  def client_currency
    client.currency
  end

  def client
    request.client
  end

  def fetch_exchange_rate(currency)
    ExchangeRateService.retrieve(from: currency, to: client_currency)
  end

  def compose_subject
    I18n.t(:'quotes.subject', date: Date.current.strftime('%d-%m-%Y'), number: 1)
  end

  def compose_notes
    return nil unless request.interpreting_request?
    address = I18n.t(:'quotes.interpreting.address', address: request.location.formatted_address)
    equipment_needed = I18n.t(:"quotes.interpreting.equipment_needed.#{request.equipment_needed}")
    interpreter_count = I18n.t(:'quotes.interpreting.interpreter_count', interpreter_count: request.interpreter_count)
    [address, equipment_needed, interpreter_count].join("\r\n")
  end

  def language_service_request?
    request.target_language_ids.any?
  end

  def service_tasks
    request.task_types
  end

  def quantity
    if request.interpreting_request?
      unit_count * request.interpreter_count
    else
      unit_count
    end
  end

  def unit_count
    flat_fee? ? DEFAULT_COUNT : request.unit_count
  end

  def flat_fee?
    request.unit.unit_type == 'fixed'
  end
end
