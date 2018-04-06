class Task < ApplicationRecord
  include BelongsDirectly, EnsureUUID, HasLocation

  with_options inverse_of: :tasks do
    belongs_to :project
    belongs_to :tasklist
    belongs_to :workspace
  end

  belongs_to :owner, class_name: 'WorkspaceUser', inverse_of: :owned_tasks

  with_options optional: true do
    belongs_to :source_language, class_name: 'Language'
    belongs_to :target_language, class_name: 'Language'
    belongs_to :task_type
    belongs_to :unit
  end

  has_many :todos, inverse_of: :task

  belongs_directly_to :workspace

  acts_as_list scope: :tasklist
  counter_culture :project,
                  column_name: proc { |r| !r.cancelled? ? 'task_count' : nil },
                  touch: true
  counter_culture :project,
                  column_name: proc { |r| r.completed? ? 'completed_task_count' : nil },
                  touch: true
  counter_culture :tasklist,
                  column_name: proc { |r| !r.cancelled? ? 'task_count' : nil },
                  touch: true
  counter_culture :tasklist,
                  column_name: proc { |r| r.completed? ? 'completed_task_count' : nil },
                  touch: true

  default_scope { includes(:task_type) }
  scope :with_status, ->(status) { where(status: status) }
  scope :except_status, ->(status) { where.not(status: status) }

  validates :owner, :project, :tasklist, :title, :workspace, presence: true
  validates :location, absence: true, unless: :interpreting_task?
  validates :task_type, :unit, presence: true, if: :active?
  validate :validate_start_date_before_due_date

  delegate :project, :workspace, to: :tasklist
  delegate :classification, to: :task_type

  enum color: {
    no_color: 0,
    purple: 1,
    blue: 2,
    green: 3,
    amber: 4,
    pink: 5,
    red: 6,
    orange: 7,
    brown: 8,
    rainbow: 9
  }

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
      before do
        self.completed_unit_count = 0
      end

      transition all - [:archived] => :draft
    end

    event :activate do
      after do
        self.project.activate
      end

      transition all - [:archived] => :active, if: -> { !!task_type && !!unit }
    end

    event :suspend do
      transition all - [:archived] => :on_hold
    end

    event :complete do
      transition all - [:no_status, :draft, :archived] => :completed
    end

    event :cancel do
      before do
        self.completed_unit_count = 0
      end

      transition all - [:archived] => :cancelled
    end

    event :archive do
      transition [:active, :completed] => :archived
    end
  end

  after_initialize { self.status ||= :draft }
  before_validation { self.title&.strip! }
  before_validation { self.project = self.tasklist.project }
  before_validation :ensure_location_is_nullified, unless: :interpreting_task?
  after_commit :update_project_completion_ratio, on: :update

  def translation_task?
    classification == 'translation'
  end

  def interpreting_task?
    classification == 'interpreting'
  end

  def localization_task?
    classification == 'localization'
  end

  def other_task?
    classification == 'other'
  end

  def update_project_completion_ratio
    return unless saved_change_to_completed_unit_count? || saved_change_to_unit_count?

    query = Arel.sql('(coalesce(sum(coalesce(completed_unit_count, 0))/nullif(sum(coalesce(unit_count, 0)),0), 0))')
    completion_ratio = Task.where(project_id: project_id).
      pluck(query).
      first

    project.update_columns(
      completion_ratio: completion_ratio,
      updated_at: Time.current
    )
  end

  private

  def ensure_location_is_nullified
    self.location = nil
  end

  def validate_start_date_before_due_date
    if due_date && start_date && due_date < start_date
      errors.add(:due_date, :greater_than_start_date)
    end
  end
end
