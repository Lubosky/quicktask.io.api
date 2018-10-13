class Contractor < ApplicationRecord
  include EnsureUUID, HasMember, HasName, Taggable

  belongs_to :workspace, inverse_of: :contractors, class_name: 'Workspace'

  with_options as: :assignee, class_name: 'HandOff', foreign_key: :assignee_id, inverse_of: :assignee do
    has_many :assignments, -> { accepted }
    has_many :invitations
  end

  has_many :tasks, through: :assignments, source: :task

  has_many :contractor_rates,
           class_name: 'Rate::Contractor',
           dependent: :delete_all,
           foreign_key: :owner_id,
           inverse_of: :owner

  has_one :workspace_currency,
          -> (c) { where(code: c.currency) },
          through: :workspace,
          source: :supported_currencies

  delegate :exchange_rate, to: :workspace_currency

  validates :currency, presence: true, length: { is: 3 }
  validates :email, email: true, allow_blank: true

  def rates
    contractor_rates.
      union(workspace.default_contractor_rates).
      without_duplicates
  end
end
