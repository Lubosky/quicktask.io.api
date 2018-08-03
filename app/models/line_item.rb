class LineItem < ApplicationRecord
  include BelongsDirectly, EnsureUUID

  belongs_to :bookkeepable, polymorphic: true

  belongs_to :source_language, class_name: 'Language', optional: true
  belongs_to :target_language, class_name: 'Language', optional: true
  belongs_to :task_type
  belongs_to :unit
  belongs_to :workspace

  belongs_directly_to :workspace

  validates :quantity,
            :task_type,
            :unit,
            :unit_price,
            :workspace,
            presence: true
  validates :quantity,
            :unit_price,
            :discount,
            :surcharge,
            numericality: { greater_than_or_equal_to: 0 }
  validates :source_language, presence: true, if: :language_combination_task?
  validates :target_language, presence: true, unless: :other_task?
  validates_associated :bookkeepable

  delegate :classification, to: :task_type
  delegate :unit_type, to: :unit
  delegate :workspace, to: :bookkeepable

  after_validation :calculate_totals

  acts_as_list scope: :bookkeepable, top_of_list: 0

  def discount=(value)
    discount = Percentage.fractionify(value)
    write_attribute(:discount, discount)
  end

  def surcharge=(value)
    surcharge = Percentage.fractionify(value)
    write_attribute(:surcharge, surcharge)
  end

  def language_combination_task?
    return false unless classification
    classification.to_sym.in?([:translation, :interpreting])
  end

  def other_task?
    return false unless classification
    classification.to_sym == :other
  end

  def calculate_totals
    if unit_price && quantity
      self.subtotal = calculate_subtotal
      self.total = calculate_total
    end
  end

  def calculate_subtotal
    unit_price * quantity
  end

  def calculate_total
    subtotal + (subtotal * surcharge) - (subtotal * discount)
  end

  def rounded_total
    round_to_two_places(total)
  end

  private

  def round_to_two_places(price)
    BigDecimal.new(price.to_s).round(2, BigDecimal::ROUND_HALF_UP)
  end
end
