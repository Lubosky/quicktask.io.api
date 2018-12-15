class Workspace < ApplicationRecord
  self.table_name = :organizations

  include EnsureUUID

  belongs_to :owner,
             inverse_of: :owned_workspaces,
             class_name: 'User',
             foreign_key: :owner_id

  with_options dependent: :destroy, inverse_of: :workspace do
    has_many :charges
    has_many :client_contacts, through: :clients
    has_many :client_requests
    has_many :clients
    has_many :contractors
    with_options foreign_key: :owner_id do
      has_many :default_client_rates,
               -> { default_for_client(:client_default) },
               class_name: '::Rate::Workspace::Client'
      has_many :default_contractor_rates,
               -> { default_for_contractor(:contractor_default) },
               class_name: '::Rate::Workspace::Contractor'
    end
    has_many :hand_offs
    has_many :languages
    has_many :accounts, class_name: 'WorkspaceAccount', foreign_key: :workspace_id
    has_many :project_groups
    has_many :project_templates, class_name: '::Project::Template'
    has_many :projects, class_name: '::Project::Regular'
    has_many :purchase_orders
    has_many :quotes
    has_many :rates, foreign_key: :workspace_id
    has_many :services
    has_many :specializations, foreign_key: :workspace_id
    has_many :supported_currencies, class_name: 'WorkspaceCurrency', foreign_key: :workspace_id
    has_many :taggings
    has_many :tags
    has_many :task_types
    has_many :tasklists
    has_many :tasks
    has_many :team_members
    has_many :todos, through: :tasks
    has_many :units

    has_one :membership
  end

  with_options class_name: 'WorkspaceAccount', foreign_key: :workspace_id, inverse_of: :workspace do
    has_many :collaborating_team_members, -> { where(profile_type: 'TeamMember') }
    has_many :collaborating_contractors, -> { where(profile_type: 'Contractor') }
    has_many :collaborating_clients, -> { where(profile_type: 'ClientContact') }
  end

  has_many :roles, class_name: 'Role::Base', dependent: :destroy

  MAX_HAND_OFF_VALID_PERIOD = 744

  jsonb_accessor :workspace_settings,
    hand_off_valid_period: [:integer, default: nil]

  scope :accessible_by, ->(user) {
    joins(:accounts).where(organization_accounts: { user_id: user.id }).distinct
  }

  before_create { self.hand_off_valid_period ||= 24 }
  after_initialize :set_default_attributes, on: :create
  after_update :update_exchange_rates, if: :saved_change_to_currency?

  validates :currency, presence: true, length: { is: 3 }
  validates :name, :owner_id, presence: true
  validates_numericality_of :hand_off_valid_period,
                            less_than_or_equal_to: MAX_HAND_OFF_VALID_PERIOD,
                            allow_nil: true

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

  def clients_count
    Workspaces::ClientsCountService.new(self).refresh_cache
  end

  def contractors_count
    Workspaces::ContractorsCountService.new(self).refresh_cache
  end

  def projects_count
    Workspaces::ProjectsCountService.new(self).refresh_cache
  end

  def tasks_count
    Workspaces::TasksCountService.new(self).refresh_cache
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
