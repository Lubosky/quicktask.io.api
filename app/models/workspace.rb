class Workspace < ApplicationRecord
  self.table_name = :organizations

  include EnsureUUID

  belongs_to :owner,
             inverse_of: :owned_workspaces,
             class_name: 'User',
             foreign_key: :owner_id

  with_options dependent: :destroy, inverse_of: :workspace do
    has_many :client_contacts, through: :clients
    has_many :client_requests
    has_many :clients
    has_many :contractors
    has_many :default_client_rates,
             -> { where(rate_type: :client_default) },
             class_name: '::Rate::Workspace::Client',
             foreign_key: :owner_id
    has_many :default_contractor_rates,
             -> { where(rate_type: :contractor_default) },
             class_name: '::Rate::Workspace::Contractor',
             foreign_key: :owner_id
    has_many :languages
    has_many :members, class_name: 'WorkspaceUser', foreign_key: :workspace_id
    has_many :charges
    has_many :project_entries, class_name: 'Project::Base'
    has_many :project_groups
    has_many :projects
    has_many :quotes
    has_many :rates, foreign_key: :workspace_id
    has_many :services
    has_many :specializations, foreign_key: :workspace_id
    has_many :supported_currencies, class_name: 'WorkspaceCurrency', foreign_key: :workspace_id
    has_many :task_types
    has_many :team_members
    has_many :units

    has_one :membership
  end

  with_options class_name: 'WorkspaceUser', foreign_key: :workspace_id, inverse_of: :workspace do
    has_many :collaborating_team_members, -> { where(member_type: 'TeamMember') }
    has_many :collaborating_contractors, -> { where(member_type: 'Contractor') }
    has_many :collaborating_clients, -> { where(member_type: 'ClientContact') }
  end

  has_many :roles, class_name: 'Role::Base', dependent: :destroy

  scope :accessible_by, ->(user) {
    joins(:members).where(organization_members: { user_id: user.id }).distinct
  }

  after_initialize :set_default_attributes, on: :create
  after_update :update_exchange_rates, if: :saved_change_to_currency?

  validates :currency, presence: true, length: { is: 3 }
  validates :name, :owner_id, presence: true

  enum status: { pending: 0, active: 1, deactivated: 2 } do
    event :activate do
      transition all - [:active] => :active
    end

    event :deactivate do
      transition all - [:deactivated] => :deactivated
    end
  end

  def subscribed?
    has_membership? && !membership.deactivated?
  end

  def previously_subscribed?
    has_membership? && membership.deactivated?
  end

  def subscribed_at
    membership.try(:created_at)
  end

  def has_membership?
    membership.present?
  end

  def has_credit_card?
    stripe_customer? && stripe_customer.sources.any?
  end

  def credit_card
    if stripe_customer?
      @credit_card ||= stripe_customer.sources.detect do |source|
        source.id == stripe_customer.default_source
      end
    end
  end

  def stripe_customer?
    stripe_customer_id.present?
  end

  def available_languages
    @available_languages = Config::Language.all
  end

  private

  def set_default_attributes
    self.currency ||= :usd
    self.status ||= :pending
  end

  def update_exchange_rates
    ExchangeRateUpdaterJob.perform_async(id, currency)
  end

  def stripe_customer
    if stripe_customer?
      @stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id)
    end
  end
end
