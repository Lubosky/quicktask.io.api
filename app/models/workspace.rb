class Workspace < ApplicationRecord
  self.table_name = :organizations

  include EnsureUUID

  belongs_to :owner,
             inverse_of: :owned_workspaces,
             class_name: 'User',
             foreign_key: :owner_id

  has_many :members,
           inverse_of: :workspace,
           class_name: 'WorkspaceUser',
           foreign_key: :workspace_id,
           dependent: :destroy

  has_many :contractors,
           inverse_of: :workspace,
           dependent: :destroy

  has_many :team_members,
           inverse_of: :workspace,
           dependent: :destroy

  has_many :collaborating_team_members,
           -> { where(member_type: 'TeamMember') },
           inverse_of: :workspace,
           class_name: 'WorkspaceUser',
           foreign_key: :workspace_id

  has_many :collaborating_contractors,
           -> { where(member_type: 'Contractor') },
           inverse_of: :workspace,
           class_name: 'WorkspaceUser',
           foreign_key: :workspace_id

  has_many :charges, inverse_of: :workspace, dependent: :destroy
  has_many :roles, class_name: 'Rolify::Base', dependent: :destroy

  has_one :membership, inverse_of: :workspace, dependent: :destroy

  before_validation :generate_unique_slug, on: :create
  after_initialize :set_default_status, on: :create

  validates :slug, :name, :owner_id, presence: true
  validates :slug, length: { minimum: 2, maximum: 18 },
                   uniqueness: { conditions: -> { where(deleted_at: nil) } }

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

  def generate_unique_slug
    self.slug ||= slugify
  end

  private

  def set_default_status
    self.status ||= :pending
  end

  def stripe_customer
    if stripe_customer?
      @stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id)
    end
  end

  def slugify
    SlugGenerator.slugify(self.name)
  end
end
