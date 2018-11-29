class TeamMember < ApplicationRecord
  include EnsureUUID
  include HasMember
  include HasName

  belongs_to :workspace, inverse_of: :team_members, class_name: 'Workspace'

  with_options inverse_of: :owner, foreign_key: :owner_id do
    has_many :projects, class_name: 'Project::Regular'
    has_many :tasklists
    has_many :tasks
  end

  has_many :assignments,
           -> { accepted },
           as: :assignee,
           class_name: 'HandOff',
           foreign_key: :assignee_id,
           inverse_of: :assignee

  has_many :delegated_hand_offs,
           class_name: 'HandOff',
           foreign_key: :assigner_id,
           inverse_of: :assigner

  has_many :notes, as: :author

  has_one :workspace_currency,
          -> (c) { where(code: c.currency) },
          through: :workspace,
          source: :supported_currencies

  delegate :currency, :default_contractor_rates, to: :workspace
  delegate :exchange_rate, to: :workspace_currency

  validates :email, email: true, presence: true
  validates_uniqueness_of :email, case_sensitive: false, scope: :workspace_id
end
