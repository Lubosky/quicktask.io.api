class ClientRequest < ApplicationRecord
  include AASM, EnsureUUID

  COMMON_FIELDS = %w(service_id request_type)

  belongs_to :client, inverse_of: :client_requests
  belongs_to :requester, class_name: 'ClientContact'
  belongs_to :service, optional: true
  belongs_to :source_language, class_name: 'Language', optional: true
  belongs_to :unit, optional: true
  belongs_to :workspace, inverse_of: :client_requests

  has_one :proposal
  has_one :quote, through: :proposal

  has_one :specialization_relation, as: :specializable, dependent: :destroy
  has_one :specialization, through: :specialization_relation

  discriminate ClientRequest, on: :request_type

  jsonb_accessor :currency_data,
    currency: :string,
    exchange_rate: :decimal,
    workspace_currency: :string

  after_initialize :set_default_attributes, on: :create
  before_save :calculate_estimated_cost

  delegate :classification, :task_types, to: :service, allow_nil: true

  validates :client,
            :request_type,
            :service,
            :currency,
            :exchange_rate,
            :requester,
            :workspace,
            :workspace_currency,
            presence: true

  validate :validate_request_type
  validate :validate_start_date_before_due_date

  enum status: { draft: 0, pending: 1, estimated: 2, cancelled: 3, withdrawn: 4 }

  aasm column: :status, enum: true do
    state :draft, initial: true
    state :pending, :estimated, :cancelled, :withdrawn

    event :submit do
      transitions :from => :draft, :to => :pending
    end

    event :estimate do
      transitions :from => :pending, :to => :estimated
    end

    event :cancel do
      transitions :from => :pending, :to => :cancelled
    end

    event :withdraw do
      transitions :from => [:draft, :pending], :to => :withdrawn
    end
  end

  def self.set_request_type(type)
    after_initialize { self.request_type = type }
  end

  def translation_request?
    request_type == 'translation'
  end

  def interpreting_request?
    request_type == 'interpreting'
  end

  def localization_request?
    request_type == 'localization'
  end

  def other_request?
    request_type == 'other'
  end

  def convert(user)
    Converter::ClientRequest.convert(self, user)
  end

  def target_languages
    workspace.languages.where(id: target_language_ids)
  end

  def submittable?
    validatable_fields.none? { |f| send(f).blank? }
  end

  private

  def calculate_estimated_cost
    raise NotImplementedError.new
  end

  def validatable_fields
    raise NotImplementedError.new
  end

  def set_default_attributes
    self.currency ||= client&.currency
    self.exchange_rate ||= client&.exchange_rate
    self.workspace_currency ||= workspace&.currency
  end

  def validate_request_type
    unless request_type == classification
      errors.add(:request_type, :invalid)
      throw(:abort)
    end
  end

  def validate_start_date_before_due_date
    if due_date && start_date && due_date < start_date
      errors.add(:due_date, :greater_than_start_date)
      throw(:abort)
    end
  end
end
