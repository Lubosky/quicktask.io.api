class PurchaseOrderGenerator
  def self.generate(hand_off)
    new(hand_off).generate
  end

  def initialize(hand_off)
    @hand_off = hand_off
    @line_items = []
  end

  def generate
    return hand_off.purchase_order if hand_off.purchase_order
    fulfill
  end

  private

  attr_reader :hand_off

  DEFAULT_COUNT = 1.0
  DEFAULT_EXCHANGE_RATE = 1.0

  def fulfill
    ::PurchaseOrder.transaction do
      entry = build_purchase_order
      entry.tap do |purchase_order|
        purchase_order.save!
        purchase_order.update_totals
      end
    end
  end

  def build_purchase_order
    permitted_attributes = hand_off.slice(:workspace_id).tap do |hash|
      hash[:owner] = owner
      hash[:issuer] = hand_off.assigner
      hash[:issue_date] = hand_off.created_at
      hash[:subject] = compose_subject
      hash[:notes] = compose_notes
      hash[:line_items_attributes] = build_line_items
    end

    hand_off.build_purchase_order(permitted_attributes)
  end

  def build_line_items
    @line_items.push(line_item_params)
  end

  def line_item_params
    {
      quantity: quantity,
      source_language_id: task.source_language_id,
      target_language_id: task.target_language_id,
      task_type_id: task&.task_type&.id,
      unit_id: task.unit_id,
      unit_price: fetch_rate
    }
  end

  def fetch_rate
    return 0 if task.other_task?
    rate = owner&.rates&.rate_for(task)
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
    currency != owner_currency
  end

  def owner_currency
    owner&.currency
  end

  def owner
    hand_off&.assignee
  end

  def task
    hand_off&.task
  end

  def fetch_exchange_rate(currency)
    ExchangeRateService.retrieve(from: currency, to: owner_currency)
  end

  def compose_subject
    I18n.t(:'purchase_orders.subject', date: Date.current.strftime('%d-%m-%Y'), number: 1)
  end

  def compose_notes
    return nil unless task.interpreting_task?
    address = I18n.t(:'purchase_orders.interpreting.address', address: task&.location&.formatted_address)
    equipment_needed = I18n.t(:"purchase_orders.interpreting.equipment_needed.#{task&.equipment_needed}")
    [address].join("\r\n")
  end

  def quantity
    flat_fee? ? DEFAULT_COUNT : task.unit_count
  end

  def flat_fee?
    task&.unit&.unit_type == 'fixed'
  end
end
