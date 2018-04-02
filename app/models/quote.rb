class Quote < ApplicationRecord
  include EnsureUUID

  belongs_to :client, inverse_of: :quotes
  belongs_to :owner, class_name: 'WorkspaceUser'
  belongs_to :workspace, inverse_of: :quotes

  has_many :line_items, as: :bookkeepable, autosave: true, dependent: :destroy

  jsonb_accessor :currency_data,
    currency: :string,
    exchange_rate: :decimal,
    workspace_currency: :string

  jsonb_accessor :metadata,
    accepted_at: [:datetime, default: nil],
    cancelled_at: [:datetime, default: nil],
    declined_at: [:datetime, default: nil],
    sent_at: [:datetime, default: nil]

  accepts_nested_attributes_for :line_items,
                                allow_destroy: true,
                                reject_if: ->(o) {
                                  o[:unit_price].blank? || o[:quantity].blank?
                                }

  after_initialize { self.status ||= :draft }
  before_validation :set_default_attributes, on: :create

  delegate :languages, :task_types, :units, to: :workspace, prefix: :applicable

  validates :client,
            :currency,
            :exchange_rate,
            :owner,
            :workspace,
            :workspace_currency,
            presence: true
  validates :discount,
            :surcharge,
            :subtotal,
            :total,
            numericality: { greater_than_or_equal_to: 0 }
  validate :validate_start_date_before_due_date

  enum status: { draft: 0, sent: 1, accepted: 2, declined: 3, expired: 4, cancelled: 5 } do
    event :submit do
      before do
        self.sent_at = DateTime.current
      end

      transition :draft => :sent
    end

    event :accept do
      before do
        self.set_metadata(accepted_at: DateTime.current)
      end

      transition all - [:draft] => :accepted
    end

    event :decline do
      before do
        self.set_metadata(declined_at: DateTime.current)
      end

      transition all - [:draft] => :declined
    end

    event :expire do
      transition all => :expired
    end

    event :cancel do
      before do
        self.set_metadata(cancelled_at: DateTime.current)
      end

      transition all => :cancelled
    end
  end

  def accepted?
    status == 'accepted'
  end

  def cancelled?
    status == 'cancelled'
  end

  def declined?
    status == 'declined'
  end

  def expired?
    status == 'expired'
  end

  def sent?
    status == 'sent'
  end

  def set_metadata(accepted_at: nil, cancelled_at: nil, declined_at: nil)
    self.accepted_at = accepted_at
    self.cancelled_at = cancelled_at
    self.declined_at = declined_at
  end

  def update_totals
    @calculator ||= Calculator::Quote.calculate(self)
  end

  def convert(user)
    Converter::Quote.convert(self, user)
  end

  private

  def set_default_attributes
    self.currency ||= client&.currency
    self.exchange_rate ||= client&.exchange_rate
    self.workspace_currency = workspace&.currency
  end

  def validate_start_date_before_due_date
    if due_date && start_date && due_date < start_date
      errors.add(:due_date, :greater_than_start_date)
    end
  end
end
