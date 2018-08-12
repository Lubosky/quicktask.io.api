class Task < ApplicationRecord
  include BelongsDirectly, EnsureUUID, HasLocation

  TRANSLATION_FIELDS = %w(source_language_id target_language_id task_type_id unit_id)
  INTERPRETING_FIELDS = %w(location source_language_id target_language_id task_type_id unit_id)
  LOCALIZATION_FIELDS = %w(source_language_id task_type_id unit_id)
  OTHER_FIELDS = %w(task_type_id)
  TASK_FIELDS = {
    translation: TRANSLATION_FIELDS,
    interpreting: INTERPRETING_FIELDS,
    localization: LOCALIZATION_FIELDS,
    other: OTHER_FIELDS
  }

  with_options inverse_of: :tasks do
    belongs_to :project
    belongs_to :task_type
    belongs_to :tasklist
    belongs_to :workspace
  end

  belongs_to :owner, class_name: 'WorkspaceUser', inverse_of: :owned_tasks

  with_options optional: true do
    belongs_to :source_language, class_name: 'Language'
    belongs_to :target_language, class_name: 'Language'
    belongs_to :unit
  end

  with_options inverse_of: :task do
    has_many :hand_offs
    has_many :pending_hand_offs, -> { pending }, class_name: 'HandOff'
    has_many :purchase_orders, through: :hand_offs
    has_many :todos

    has_one :assignment, -> { accepted }, class_name: 'HandOff'
    has_one :accepted_purchase_order, class_name: 'PurchaseOrder', through: :assignment, source: :purchase_order
  end

  has_many :potential_assignees,
           ->(task) { where(id: PotentialAssigneesQuery.build_query(task)) },
           through: :workspace,
           source: :contractors

  has_many :invitees,
           as: :assignee,
           foreign_key: :assignee_id,
           source: :assignee,
           source_type: 'Contractor',
           through: :hand_offs

  with_options foreign_key: :assignee_id, source: :assignee, through: :assignment do
    has_one :team_member_assignee, source_type: 'TeamMember'
    has_one :contractor_assignee, source_type: 'Contractor'
  end

  belongs_directly_to :workspace

  jsonb_accessor :task_data,
    equipment_needed: [:boolean, default: false]

  jsonb_accessor :metadata,
    source_language_name: [:string, default: nil],
    source_language_code: [:string, default: nil],
    target_language_name: [:string, default: nil],
    target_language_code: [:string, default: nil],
    task_type_name: [:string, default: nil],
    task_type_classification: [:string, default: nil],
    unit_name: [:string, default: nil]

  acts_as_list scope: :tasklist, top_of_list: 0

  alias :following_task :lower_item
  alias :following_tasks :lower_items
  alias :precedent_task :higher_item
  alias :precedent_tasks :higher_items

  counter_culture :project,
                  column_name: :task_count,
                  touch: true
  counter_culture :project,
                  column_name: proc { |r| r.completed? ? 'completed_task_count' : nil },
                  touch: true
  counter_culture :tasklist,
                  column_name: :task_count,
                  touch: true
  counter_culture :tasklist,
                  column_name: proc { |r| r.completed? ? 'completed_task_count' : nil },
                  touch: true

  default_scope { joins(:task_type).preload(:task_type).order(:tasklist_id, :position) }

  scope :with_status, ->(status) { where(status: status) }
  scope :except_status, ->(status) { where.not(status: status) }

  validates :owner, :project, :tasklist, :task_type, :title, :workspace, presence: true
  validates :location, absence: true, unless: :interpreting_task?
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
    uncompleted: 0,
    completed: 1
  } do
    event :complete do
      transition :uncompleted => :completed
    end

    event :uncomplete do
      transition :completed => :uncompleted
    end

    event :reset do
      before do
        self.completed_unit_count = 0
      end

      transition :completed => :uncompleted
    end
  end

  after_initialize { self.status ||= :uncompleted }
  before_validation { self.title&.strip! }
  before_validation :set_default_attributes
  before_validation :ensure_location_is_nullified, unless: :interpreting_task?
  before_save :update_task_data, if: :association_fields_changed?
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

  def assignee
    assignment&.assignee
  end

  def update_project_completion_ratio
    return unless saved_change_to_completed_unit_count? || saved_change_to_unit_count?

    query = Arel.sql('(coalesce(sum(coalesce(completed_unit_count, 0))/nullif(sum(coalesce(unit_count, 0)),0), 0))')
    completion_ratio = Task.unscope(:order).where(project_id: project_id).
      pluck(query).
      first

    project.update_columns(
      completion_ratio: completion_ratio,
      updated_at: Time.current
    )
  end

  def update_task_data
    self.source_language_name = self&.source_language&.name
    self.source_language_code = self&.source_language&.code
    self.target_language_name = self&.target_language&.name
    self.target_language_code = self&.target_language&.code
    self.task_type_name = self&.task_type&.name
    self.task_type_classification = self&.task_type&.classification
    self.unit_name = self&.unit&.name
  end

  def move_task(position:, tasklist_id: self.tasklist_id)
    self.update(position: position, tasklist_id: tasklist_id)
  end

  def assignable?
    association_fields(precise: true).none? { |f| send(f).blank? }
  end

  private

  def association_fields_changed?
    association_fields.any? { |f| send("#{f}_changed?") }
  end

  def association_fields(precise: false)
    if precise
      attributes.keys & TASK_FIELDS.with_indifferent_access[self.classification]
    else
      attributes.keys & %w(source_language_id target_language_id task_type_id unit_id)
    end
  end

  def set_default_attributes
    self.project = self&.tasklist&.project
    if self.interpreting_task?
      self.equipment_needed ||= false
    else
      self.equipment_needed = nil
    end
  end

  def ensure_location_is_nullified
    self.location = nil
  end

  def validate_start_date_before_due_date
    if due_date && start_date && due_date < start_date
      errors.add(:due_date, :greater_than_start_date)
    end
  end
end
