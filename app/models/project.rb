 class Project < ApplicationRecord
  include EnsureUUID

  with_options inverse_of: :projects do
    belongs_to :client
    belongs_to :project_group, optional: true
    belongs_to :workspace
  end

  belongs_to :owner,
             inverse_of: :owned_projects,
             class_name: 'WorkspaceUser',
             foreign_key: :owner_id

  has_many :possible_collaborators,
           -> { where(status: :active) },
           through: :workspace,
           source: :members

  with_options dependent: :destroy, inverse_of: :project do
    has_many :tasklists
    has_many :tasks, through: :tasklists
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
      transition all - [:archived] => :planned
    end

    event :activate do
      transition all - [:archived] => :active
    end

    event :suspend do
      transition all - [:archived] => :on_hold
    end

    event :complete do
      before do
        tasks.with_status([:draft, :no_status, :on_hold, :planned]).
          find_each(&:cancel!)

        tasks.except_status([:archived, :cancelled, :completed]).
          find_each(&:complete!)
      end

      transition all - [:no_status, :draft, :archived] => :completed
    end

    event :cancel do
      before do
        tasks.except_status([:archived, :cancelled]).find_each(&:cancel!)
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

  def generate_quote(user)
    Converter::Project.generate_quote(self, user)
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
