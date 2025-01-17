class Project::Regular < Project
  set_project_type :regular

  include AASM

  GRAPHQL_TYPE = 'Project'.freeze
  PROJECT_STATUSES = %i(no_status draft planned active on_hold completed cancelled archived)

  with_options inverse_of: :projects do
    belongs_to :owner, class_name: 'TeamMember', foreign_key: :owner_id
    belongs_to :client
    belongs_to :project_group, optional: true
  end

  has_many :possible_collaborators,
           -> { where(status: :active) },
           through: :workspace,
           source: :accounts

  with_options dependent: :destroy, inverse_of: :project do
    with_options through: :tasks do
      has_many :hand_offs, class_name: 'HandOff'

      with_options class_name: 'PurchaseOrder' do
        has_many :purchase_orders, source: :purchase_orders
        has_many :accepted_purchase_orders, source: :accepted_purchase_order
      end
    end

  end

  has_many :notes, as: :annotatable, dependent: :delete_all

  has_one :project_estimate, dependent: :destroy, foreign_key: :project_id
  has_one :quote, through: :project_estimate

  default_scope { where(project_type: :regular) }

  validates :name, :client, :owner, presence: true

  enum status: {
    no_status: 0,
    draft: 1,
    planned: 2,
    active: 3,
    on_hold: 4,
    completed: 5,
    cancelled: 6,
    archived: 7
  }

  aasm column: :status, enum: true do
    state :draft, initial: true
    state :no_status, :planned, :active, :on_hold, :completed, :cancelled, :archived

    event :nullify do
      before do
        self.completed_date = nil
      end

      transitions :from => PROJECT_STATUSES - [:archived], :to => :no_status
    end

    event :prepare do
      before do
        self.completed_date = nil
      end

      transitions :from => PROJECT_STATUSES - [:archived], :to => :draft
    end

    event :plan do
      before do
        self.generate_quote
        self.completed_date = nil
      end

      transitions :from => PROJECT_STATUSES - [:archived], :to => :planned
    end

    event :activate do
      before do
        self.generate_quote
        self.completed_date = nil
      end

      transitions :from => PROJECT_STATUSES - [:archived], :to => :active
    end

    event :suspend do
      before do
        self.generate_quote
        self.completed_date = nil
      end

      transitions :from => PROJECT_STATUSES - [:archived], :to => :on_hold
    end

    event :complete do
      before do
        self.generate_quote
        tasks.except_status(:completed).find_each(&:complete!)
        hand_offs.pending.find_each(&:cancel!)
        self.completed_date = Time.current
      end

      transitions :from => PROJECT_STATUSES - [:no_status, :draft, :archived], :to => :completed
    end

    event :cancel do
      before do
        tasks.find_each(&:reset!)
        hand_offs.pending.find_each(&:cancel!)
        self.completed_date = nil
      end

      transitions :from => PROJECT_STATUSES - [:archived], :to => :cancelled
    end

    event :archive do
      transitions :from => [:active, :completed], :to => :archived
    end
  end

  def graphql_type
    GRAPHQL_TYPE
  end

  def generate_quote
    Converter::Project.generate_quote(self, owner) unless self.quote
  end
end
