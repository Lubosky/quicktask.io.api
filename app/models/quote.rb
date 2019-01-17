class Quote < ApplicationRecord
  include AASM, EnsureUUID

  searchkick callbacks: :async,
             index_name: -> { "#{Rails.env}-#{self.model_name.plural}" },
             routing: true,
             searchable: [:subject, :identifier, :purchase_order_number, :client_name]

  belongs_to :client, inverse_of: :quotes
  belongs_to :owner, class_name: 'TeamMember'
  belongs_to :workspace, inverse_of: :quotes

  has_many :line_items, as: :bookkeepable, autosave: true, dependent: :destroy

  has_one :proposal
  has_one :client_request, through: :proposal

  has_one :project_estimate
  has_one :project, through: :project_estimate

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

  after_initialize { self.quote_type = :quote }
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

  scope :search_import, -> { includes(:client, :owner, :client_request, :project) }

  enum quote_type: [:quote]
  enum status: { draft: 0, sent: 1, accepted: 2, declined: 3, expired: 4, cancelled: 5 }

  aasm column: :status, enum: true do
    state :draft, initial: true
    state :sent, :accepted, :declined, :expired, :cancelled

    event :submit do
      before do
        self.sent_at = DateTime.current
      end

      transitions :from => :draft, :to => :sent
    end

    event :accept do
      before do
        self.set_metadata(accepted_at: DateTime.current)
      end

      transitions :from => [:sent, :declined, :expired, :cancelled], :to => :accepted
    end

    event :decline do
      before do
        self.set_metadata(declined_at: DateTime.current)
      end

      transitions :from => [:sent, :accepted, :expired, :cancelled], :to => :declined
    end

    event :expire do
      transitions :from => [:draft, :sent, :accepted, :declined, :cancelled], :to => :expired
    end

    event :cancel do
      before do
        self.set_metadata(cancelled_at: DateTime.current)
      end

      transitions :from => [:draft, :sent, :accepted, :declined, :expired], :to => :cancelled
    end
  end

  def set_metadata(accepted_at: nil, cancelled_at: nil, declined_at: nil)
    self.accepted_at = accepted_at
    self.cancelled_at = cancelled_at
    self.declined_at = declined_at
  end

  def update_totals
    @calculator ||= Calculator::Bill.calculate(self)
  end

  def convert(user)
    Converter::Quote.convert(self, user)
  end

  def search_routing
    workspace_id
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

  def search_data
    {
      type: quote_type,
      subject: subject,
      identifier: identifier,
      purchase_order_number: purchase_order_number,
      status: status,
      workspace_id: workspace_id,
      client_id: client&.id,
      client_name: client&.name,
      owner_id: owner_id,
      owner_name: owner&.name,
      client_request_id: client_request&.id,
      client_request_identifier: client_request&.subject,
      project_id: project&.id,
      project_name: project&.name,
      discount: discount,
      surcharge: surcharge,
      subtotal: subtotal,
      total: total,
      has_client_request: client_request.present?,
      has_project: project.present?,
      currency: currency,
      workspace_currency: workspace_currency,
      exchange_rate: exchange_rate,
      issue_date: issue_date,
      expiry_date: expiry_date,
      start_date: start_date,
      due_date: due_date,
      accepted_at: accepted_at,
      cancelled_at: cancelled_at,
      declined_at: declined_at,
      sent_at: sent_at,
      created_at: created_at,
      updated_at: updated_at,
    }
  end
end
