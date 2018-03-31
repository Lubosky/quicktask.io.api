class Calculator::Quote
  def self.calculate(quote)
    new(quote).calculate
  end

  def initialize(quote)
    @quote = quote
  end

  def calculate
    calculate_subtotal
    calculate_discount
    calculate_surcharge
    calculate_total
    persist_totals
  end

  private

  attr_reader :quote

  delegate :line_items, to: :quote

  def calculate_subtotal
    quote.subtotal = totals.first
  end

  def calculate_discount
    quote.discount = totals.second
  end

  def calculate_surcharge
    quote.surcharge = totals.third
  end

  def calculate_total
    quote.total = quote.subtotal - quote.discount + quote.surcharge
  end

  def totals
    @quote_totals ||= line_items.
      pluck(Arel.sql('sum(subtotal), sum(subtotal * discount), sum(subtotal * surcharge)')).
      flatten
  end

  def persist_totals
    quote.update_columns(
      subtotal: quote.subtotal,
      discount: quote.discount,
      surcharge: quote.surcharge,
      total: quote.total,
      updated_at: Time.current
    )
  end
end
