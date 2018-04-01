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

  with_options inverse_of: :project do
    has_many :tasklists
    has_many :tasks, through: :tasklists
  end

  jsonb_accessor :settings,
    automated_workflow: [:boolean, default: true],
    internal: [:boolean, default: false]

  accepts_nested_attributes_for :tasklists,
                                allow_destroy: true,
                                reject_if: ->(o) { o['title'].blank? }

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
    event :prepare do
      transition all - [:archived] => :draft
    end

    event :activate do
      transition all - [:archived] => :active
    end

    event :defer do
      transition all - [:archived] => :on_hold
    end

    event :complete do
      before do
        tasks.with_status([:draft, :no_status, :on_hold, :planned]).
          find_each(&:cancel!)

        tasks.expect_status([:archived, :cancelled, :completed]).
          find_each(&:complete!)
      end

      transition all - [:no_status, :draft, :archived] => :completed
    end

    event :cancel do
      before do
        tasks.expect_status([:archived, :cancelled]).find_each(&:cancel!)
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
end
