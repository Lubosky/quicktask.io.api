class Todo < ApplicationRecord
  include BelongsDirectly, EnsureUUID

  with_options inverse_of: :todos do
    belongs_to :task
    belongs_to :workspace
  end

  belongs_to :assignee,
             class_name: 'WorkspaceAccount',
             foreign_key: :assignee_id,
             inverse_of: :assigned_todos,
             optional: true

  belongs_directly_to :workspace

  acts_as_list scope: :task, top_of_list: 0

  default_scope { order(:position) }

  scope :assigned_to, ->(assignee) { where(assignee: assignee) }
  scope :completed, -> { where(completed: true) }

  validates :task, :title, :workspace, presence: true

  delegate :workspace, to: :task

  before_validation { self.title&.strip! }
  with_options on: :create do
    before_validation { self.completed ||= false }
  end
  after_validation :set_completion_date, if: :completed?
  after_validation :reset_completion_date, unless: :completed?

  def complete!
    self.update!(completed: true)
  end

  def uncomplete!
    self.update!(completed: false)
  end

  private

  def set_completion_date
    self.completed_date = DateTime.current if completed_changed?
  end

  def reset_completion_date
    self.completed_date = nil if completed_changed?
  end
end
