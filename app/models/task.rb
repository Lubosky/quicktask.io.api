class Task < ApplicationRecord
  include BelongsDirectly, EnsureUUID, HasLocation, Taggable

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
    belongs_to :owner, class_name: 'TeamMember', foreign_key: :owner_id
    belongs_to :project
    belongs_to :task_type
    belongs_to :tasklist
    belongs_to :workspace
  end

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

  with_options class_name: 'TaskDependency', dependent: :destroy do
    has_many :dependent_task_relations, foreign_key: :dependent_on_task_id, inverse_of: :precedent_task
    has_many :precedent_task_relations, foreign_key: :task_id, inverse_of: :dependent_task
  end

  with_options class_name: 'Task' do
    has_many :dependent_tasks, through: :dependent_task_relations do
      def << (dependent_tasks)
        dependent_tasks -= self if dependent_tasks.respond_to?(:to_a)
        super dependent_tasks unless include?(dependent_tasks)
      end
    end

    has_many :precedent_tasks, through: :precedent_task_relations do
      def << (precedent_tasks)
        precedent_tasks -= self if precedent_tasks.respond_to?(:to_a)
        super precedent_tasks unless include?(precedent_tasks)
      end
    end
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

  has_one :project_owner, class_name: 'TeamMember', through: :project, source: :owner

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

  alias :prior_task :higher_item
  alias :next_task :lower_item

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
  scope :with_expiring_hand_offs, -> {
    hand_offs = HandOff.arel_table
    tasks = Task.arel_table

    without_accepted = hand_offs.
      project(hand_offs[:id]).
        where(
          tasks[:id].eq(hand_offs[:task_id]).
          and(hand_offs[:accepted_at].not_eq(nil))
        ).exists.not

    valid_through_query = hand_offs.
      project(hand_offs[:valid_through].maximum).
        where(
          tasks[:id].eq(hand_offs[:task_id]).
          and(hand_offs[:accepted_at].eq(nil)).
          and(hand_offs[:rejected_at].eq(nil)).
          and(hand_offs[:cancelled_at].eq(nil)).
          and(hand_offs[:expired_at].eq(nil))
        )

    unscoped.joins(:pending_hand_offs).
      where(without_accepted).
      where(
        hand_offs[:valid_through].eq(valid_through_query).
        and(hand_offs[:valid_through].lteq(1.hour.from_now))
      )
  }
  scope :with_preloaded, -> {
    joins(:task_type, :todos).preload(:task_type, :todos)
  }

  validates :owner, :project, :tasklist, :task_type, :title, :workspace, presence: true
  validates :location, absence: true, unless: :interpreting_task?
  validate :validate_start_date_before_due_date

  delegate :project, :workspace, to: :tasklist
  delegate :classification, to: :task_type

  enum color: [:no_color, :purple, :blue, :green, :amber, :pink, :red, :orange, :brown, :rainbow]
  enum recurring_type: [:none, :day, :week, :biweekly, :work_day, :month, :quarterly, :half_year, :year], _prefix: true
  enum status: [:uncompleted, :completed] do
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

  after_initialize {
    self.status ||= :uncompleted
    self.recurring_type ||= :none
  }
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

  def query_fields
    {}.tap do |hash|
      hash[:classification] = self.classification
      association_fields(precise: true).
        map(&:to_sym).
        each { |f| hash[f] = send("#{f}") }
    end
  end

  def blocked_by
    case project.workflow_type.to_sym
    when :default then [prior_task].compact
    when :custom then precedent_tasks
    else [] end
  end

  def blocking
    case project.workflow_type.to_sym
    when :default then [next_task].compact
    when :custom then dependent_tasks
    else [] end
  end

  def remove_dependencies
    TaskDependency.for_task(self).delete_all
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
