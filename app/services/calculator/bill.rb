class Calculator::Bill
  def self.calculate(bill)
    new(bill).calculate
  end

  def initialize(bill)
    @bill = bill
  end

  def calculate
    calculate_subtotal
    calculate_discount
    calculate_surcharge
    calculate_total
    persist_totals
  end

  private

  attr_reader :bill

  delegate :line_items, to: :bill

  def calculate_subtotal
    bill.subtotal = totals.first
  end

  def calculate_discount
    bill.discount = totals.second
  end

  def calculate_surcharge
    bill.surcharge = totals.third
  end

  def calculate_total
    bill.total = bill.subtotal - bill.discount + bill.surcharge
  end

  def totals
    @bill_totals ||= line_items.
      pluck(Arel.sql('sum(subtotal), sum(subtotal * discount), sum(subtotal * surcharge)')).
      flatten
  end

  def persist_totals
    bill.update_columns(
      subtotal: bill.subtotal,
      discount: bill.discount,
      surcharge: bill.surcharge,
      total: bill.total,
      updated_at: Time.current
    )
  end
end
