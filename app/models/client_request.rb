class ClientRequest < ApplicationRecord
  include EnsureUUID

  belongs_to :client, inverse_of: :client_requests
  belongs_to :owner, class_name: 'WorkspaceUser'
  belongs_to :service
  belongs_to :source_language, class_name: 'Language', optional: true
  belongs_to :unit
  belongs_to :workspace, inverse_of: :client_requests

  has_one :specialization_relation, as: :specializable, dependent: :destroy
  has_one :specialization, through: :specialization_relation

  discriminate ClientRequest, on: :request_type

  jsonb_accessor :currency_data,
    currency: :string,
    exchange_rate: :decimal,
    workspace_currency: :string

  after_initialize :set_default_attributes, on: :create

  delegate :classification, to: :service

  validates :client,
            :currency,
            :exchange_rate,
            :owner,
            :request_type,
            :service,
            :unit,
            :workspace,
            :workspace_currency,
            presence: true

  validate :validate_request_type

  enum status: { draft: 0, pending: 1, estimated: 2, cancelled: 3, withdrawn: 4 } do
    event :submit do
      transition :draft => :pending
    end

    event :estimate do
      transition :pending => :estimated
    end

    event :cancel do
      transition :pending => :cancelled
    end

    event :withdraw do
      transition [:draft, :pending] => :withdrawn
    end
  end

  def self.set_request_type(type)
    after_initialize { self.request_type = type }
  end

  def target_languages
    workspace.languages.where(id: target_language_ids)
  end

  private

  def set_default_attributes
    self.status ||= :draft
    self.currency ||= client.currency
    self.exchange_rate ||= client.exchange_rate
    self.workspace_currency ||= workspace.currency
  end

  def validate_request_type
    errors.add(:request_type, :invalid) unless request_type == classification
  end
end
