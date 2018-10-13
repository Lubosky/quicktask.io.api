class Client < ApplicationRecord
  include EnsureUUID, Taggable

  belongs_to :workspace, inverse_of: :clients

  with_options dependent: :restrict_with_error, inverse_of: :client do
    has_many :client_requests
    has_many :project_groups
    has_many :projects, class_name: 'Project::Regular'
    has_many :quotes
  end

  with_options dependent: :delete_all do
    has_many :client_contacts, inverse_of: :client
    has_many :client_rates,
             class_name: 'Rate::Client',
             foreign_key: :owner_id,
             inverse_of: :owner
  end

  has_one :workspace_currency,
          -> (c) { where(code: c.currency) },
          through: :workspace,
          source: :supported_currencies

  default_scope { where(internal: false) }

  validates :name, presence: true
  validates :currency, presence: true, length: { is: 3 }

  jsonb_accessor :tax_settings,
    tax_number: :string,
    tax_rate: :float

  delegate :exchange_rate, to: :workspace_currency

  def rates
    client_rates.
      union(workspace.default_client_rates).
      without_duplicates
  end
end
