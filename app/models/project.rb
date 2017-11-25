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

  jsonb_accessor :settings,
    automated_workflow: [:boolean, default: true],
    internal: [:boolean, default: false]

  validates :client, presence: true
  validates :owner, presence: true
  validates :workspace, presence: true

  validates :name, presence: true

  enum status: { no_status: 0, planned: 1, active: 2, on_hold: 3, completed: 4, cancelled: 5, archived: 6 }

  def has_automated_workflow?
    automated_workflow?
  end

  def is_internal?
    internal?
  end
end
