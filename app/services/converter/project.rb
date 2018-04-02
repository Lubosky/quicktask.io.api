class Converter::Project
  def self.generate_quote(project, user)
    new(project, user).generate_quote
  end

  def initialize(project, user)
    @project = project
    @user = user
  end

  def generate_quote
    fulfill_conversion
  end

  private

  attr_reader :project, :user

  DEFAULT_COUNT = 1.0
  DEFAULT_EXCHANGE_RATE = 1.0

  QUOTE_ATTRIBUTES = %i(
    client_id
    owner_id
    workspace_id
    start_date
    due_date
  )

  LINE_ITEM_ATTRIBUTES = %i(
    source_language_id
    target_language_id
    task_type_id
    unit_id
  )

  def fulfill_conversion
    ::Quote.transaction do
      quote = build_quote
      quote.tap do |resource|
        resource.save!
        resource.update_totals
      end
    end
  end

  def build_quote
    permitted_attributes = project.slice(QUOTE_ATTRIBUTES).tap do |hash|
      hash[:subject] = compose_subject
      hash[:notes] = compose_notes
      hash[:owner] = user
      hash[:line_items_attributes] = build_line_items
    end

    ::Quote.new(permitted_attributes)
  end

  def compose_subject
    I18n.t(:'quotes.subject', date: Date.current.strftime('%d-%m-%Y'), number: 1)
  end

  def compose_notes; end

  def build_line_items
    line_items = []

    tasks.each do |group, collection|
      unless collection.empty?
        line_item = build_line_item(group, collection)
        line_items.push(line_item) if line_item
      end
    end

    return line_items
  end

  def tasks
    project.
      tasks.
      includes(:source_language, :target_language, :task_type, :unit).
      group_by { |i| [i.source_language, i.target_language, i.task_type, i.unit] }
  end

  def build_line_item(group, collection)
    source_language = group.first
    target_language = group.second
    task_type = group.third
    unit = group.last

    rate_params = {
      source_language: source_language,
      target_language: target_language,
      task_type: task_type,
      unit: unit
    }

    unit_count = unit_count(collection, unit)
    unit_price = fetch_rate(rate_params)

    line_item_params = {
      quantity: unit_count,
      unit_price: unit_price
    }.merge(rate_params)

    return line_item_params
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
    project.client
  end

  def fetch_exchange_rate(currency)
    ExchangeRateService.retrieve(from: currency, to: client_currency)
  end

  def unit_count(collection, unit)
    flat_fee?(unit) ? DEFAULT_COUNT : collection.sum(&:unit_count)
  end

  def flat_fee?(unit)
    unit.unit_type == 'fixed'
  end
end
