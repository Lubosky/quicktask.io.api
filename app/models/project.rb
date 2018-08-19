 class Project < ApplicationRecord
  include EnsureUUID

  with_options inverse_of: :projects do
    belongs_to :owner, class_name: 'TeamMember', foreign_key: :owner_id
    belongs_to :client
    belongs_to :project_group, optional: true
    belongs_to :workspace
  end

  has_many :possible_collaborators,
           -> { where(status: :active) },
           through: :workspace,
           source: :members

  with_options dependent: :destroy, inverse_of: :project do
    has_many :tasklists
    has_many :tasks, through: :tasklists

    with_options through: :tasks do
      has_many :hand_offs, class_name: 'HandOff'

      with_options class_name: 'PurchaseOrder' do
        has_many :purchase_orders, source: :purchase_orders
        has_many :accepted_purchase_orders, source: :accepted_purchase_order
      end
    end
  end

  has_one :project_estimate, dependent: :destroy
  has_one :quote, through: :project_estimate

  jsonb_accessor :settings,
    automated_workflow: [:boolean, default: true],
    internal: [:boolean, default: false]

  accepts_nested_attributes_for :tasklists,
                                allow_destroy: true,
                                reject_if: ->(o) { o['title'].blank? }

  after_initialize { self.status ||= :draft }

  scope :with_task_map, -> { select("projects.*, #{TaskMapQuery.query}") }
  scope :with_preloaded, -> {
    joins(tasklists: { tasks: [:task_type, :todos] }).
      preload(tasklists: { tasks: [:task_type, :todos] })
  }

  validates :client, :name, :owner, :workspace, presence: true

  enum status: {
    no_status: 0,
    draft: 1,
    planned: 2,
    active: 3,
    on_hold: 4,
    completed: 5,
    cancelled: 6,
    archived: 7
  } do
    event :nullify do
      transition all - [:archived] => :no_status
    end

    event :prepare do
      transition all - [:archived] => :draft
    end

    event :plan do
      before do
        self.generate_quote
      end

      transition all - [:archived] => :planned
    end

    event :activate do
      before do
        self.generate_quote
      end

      transition all - [:archived] => :active
    end

    event :suspend do
      before do
        self.generate_quote
      end

      transition all - [:archived] => :on_hold
    end

    event :complete do
      before do
        self.generate_quote
        tasks.find_each(&:complete!)
        hand_offs.pending.find_each(&:cancel!)
      end

      transition all - [:no_status, :draft, :archived] => :completed
    end

    event :cancel do
      before do
        tasks.find_each(&:reset!)
        hand_offs.pending.find_each(&:cancel!)
      end

      transition all - [:archived] => :cancelled
    end

    event :archive do
      transition [:active, :completed] => :archived
    end
  end

  def has_automated_workflow?
    automated_workflow?
  end

  def is_internal?
    internal?
  end

  def generate_quote
    Converter::Project.generate_quote(self, owner) unless self.quote
  end

  def ordered_tasklist_ids
    ordered_task_map.keys
  end

  def ordered_task_ids
    ordered_task_map
  end

  private

  def ordered_task_map
    if respond_to?(:collection_map)
      collection = collection_map
    else
      collection = Project.where(id: id).
        pluck(TaskMapQuery.query).
        first
    end

    collection ? collection.reduce(Hash.new, :merge) : Hash.new
  end
end
