class PurchaseOrder < ApplicationRecord
  include BelongsDirectly, EnsureUUID

  belongs_to :owner, polymorphic: true

  with_options class_name: 'TeamMember' do
    belongs_to :issuer, foreign_key: :issuer_id
    belongs_to :updater, foreign_key: :updater_id, optional: true
  end

  belongs_to :hand_off, inverse_of: :purchase_order
  belongs_to :workspace, inverse_of: :purchase_orders

  has_many :line_items, as: :bookkeepable, autosave: true, dependent: :destroy

  has_one :task, through: :hand_off
  has_one :project,
           source: :project,
           through: :task

  belongs_directly_to :workspace

  jsonb_accessor :currency_data,
    currency: :string,
    exchange_rate: :decimal,
    workspace_currency: :string

  jsonb_accessor :metadata,
    modified_at: [:datetime, default: nil]

  accepts_nested_attributes_for :line_items,
                                allow_destroy: true,
                                reject_if: ->(o) {
                                  o[:unit_price].blank? || o[:quantity].blank?
                                }

  before_validation :set_default_attributes, on: :create

  delegate :workspace, to: :hand_off

  validates :currency,
            :exchange_rate,
            :hand_off,
            :issuer,
            :owner,
            :workspace,
            :workspace_currency,
            presence: true
  validates :discount,
            :surcharge,
            :subtotal,
            :total,
            numericality: { greater_than_or_equal_to: 0 }

  def update_totals
    @calculator ||= Calculator::Bill.calculate(self)
  end

  private

  def set_default_attributes
    self.currency ||= owner&.currency
    self.exchange_rate ||= owner&.exchange_rate
    self.workspace_currency ||= workspace&.currency
  end
end
