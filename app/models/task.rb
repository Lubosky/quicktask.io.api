class Task < ApplicationRecord
  include AASM, BelongsDirectly, EnsureUUID, HasLocation, SQL::Pattern, Taggable

  TRANSLATION_FIELDS = %w(source_language_id target_language_id task_type_id unit_id)
  INTERPRETING_FIELDS = %w(location source_language_id target_language_id task_type_id unit_id)
  LOCALIZATION_FIELDS = %w(target_language_id task_type_id unit_id)
  OTHER_FIELDS = %w(task_type_id)
  TASK_FIELDS = {
    translation: TRANSLATION_FIELDS,
    interpreting: INTERPRETING_FIELDS,
    localization: LOCALIZATION_FIELDS,
    other: OTHER_FIELDS
  }

  searchkick callbacks: :async,
             index_name: -> { "#{Rails.env}-#{self.model_name.plural}" },
             routing: true,
             searchable: [:title, :description, :project_name, :tasklist_title, :source_language, :target_language, :task_type],
             text_start: [:title],
             word_middle: [:description]

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

  has_many :notes, as: :annotatable, dependent: :delete_all

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

  default_scope { order(:tasklist_id, :position) }

  scope :preload_associations, -> { preload(:task_type, :todos) }

  scope :assigned, -> { where('EXISTS (SELECT TRUE FROM hand_offs WHERE task_id = tasks.id AND accepted_at IS NOT NULL)') }
  scope :unassigned, -> { where('NOT EXISTS (SELECT TRUE FROM hand_offs WHERE task_id = tasks.id AND accepted_at IS NOT NULL)') }
  scope :assigned_to, ->(a) {
    hand_offs = HandOff.arel_table

    query = arel_table.project('true').where(hand_offs[:assignee_id].eq(a.id)).exists
    where(query.to_sql)
  }

  scope :created_by, ->(o) {
    query = arel_table.project('true').where(arel_table[:owner_id].eq(o.id)).exists
    where(query.to_sql)
  }

  scope :created_by_or_assigned_to, ->(u) {
    hand_offs = HandOff.arel_table
    team_members = TeamMember.arel_table

    assignee_query = hand_offs.
      project('true').
      where(hand_offs[:assignee_id].eq(u.id).and(hand_offs[:assignee_type].eq('TeamMember'))).exists
    owner_query = arel_table.project('true').where(arel_table[:owner_id].eq(u.id)).exists

    where(assignee_query.or(owner_query).to_sql)
  }

  scope :by_project, ->(ids) { where(project_id: ids) }
  scope :references_project, -> { references(:project) }
  scope :completed_late, -> { where(arel_table[:completed_date].gt(arel_table[:due_date])) }

  scope :with_due_date, -> { where.not(due_date: nil) }
  scope :without_due_date, -> { where(due_date: nil) }
  scope :due_before, ->(date) { where(arel_table[:due_date].lteq(date)) }
  scope :due_between, ->(from_date, to_date) {
    where(arel_table[:due_date].gteq(from_date).and(arel_table[:due_date].lteq(to_date)))
  }
  scope :due_tomorrow, -> { where(arel_table[:due_date].eq(Date.tomorrow)) }

  scope :grouped_by_due_date, -> {
    select(Arel.sql("date_trunc('day', due_date), count(1)")).group(1)
  }

  scope :order_due_date_asc, -> { reorder(Arel.sql('tasks.due_date IS NULL, tasks.due_date ASC')) }
  scope :order_due_date_desc, -> { reorder(Arel.sql('tasks.due_date IS NULL, tasks.due_date DESC')) }
  scope :order_closest_future_date, -> {
    reorder(Arel.sql(
      'CASE WHEN tasks.due_date >= now() THEN 0 ELSE 1 END ASC, ABS(extract(epoch from (now() - tasks.due_date))) ASC'
    ))
  }

  scope :with_overdue_count, -> {
    completed_query = arel_table[:completed_date].eq(nil)
    due_query = arel_table[:due_date].not_eq(nil)
    overdue_query = arel_table[:due_date].lteq(Time.current)
    not_deleted_query = arel_table[:deleted_at].eq(nil)

    overdue_count_query = arel_table.
      project(arel_table[:id].count.as('overdue_tasks_count')).
        where(completed_query.
          and(due_query).
          and(overdue_query).
          and(not_deleted_query)
        ).to_sql

    where(completed_query.
          and(due_query).
          and(overdue_query).
          and(not_deleted_query)).pluck(arel_table[:id].count.as('overdue_tasks_count').to_sql)
  }

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

  scope :for_project, -> { joins(:project).where(projects: { project_type: :regular }) }
  scope :search_import, -> {
    includes(
      :owner, :task_type, :tasklist, :source_language, :target_language,
      :unit, :task_type, assignment: :assignee
    )
  }

  validates :owner, :project, :tasklist, :task_type, :title, :workspace, presence: true
  validates :location, absence: true, unless: :interpreting_task?
  validate :validate_start_date_before_due_date

  delegate :project, :workspace, to: :tasklist
  delegate :classification, to: :task_type

  enum color: [
    :no_color,
    :red,
    :orange,
    :yellow_orange,
    :yellow,
    :yellow_green,
    :green,
    :blue_green,
    :aqua,
    :blue,
    :indigo,
    :purple,
    :magenta,
    :hot_pink,
    :pink,
    :cool_gray
  ]
  enum recurring_type: [:none, :day, :week, :biweekly, :work_day, :month, :quarterly, :half_year, :year], _prefix: true
  enum status: { uncompleted: 0, completed: 1 }

  aasm column: :status, enum: true do
    state :uncompleted, initial: true
    state :completed

    event :complete do
      before do
        self.completed_date = Time.current
        self.completed_unit_count = self.unit_count if self.unit_count
      end

      transitions :from => :uncompleted, :to => :completed
    end

    event :uncomplete do
      before do
        self.completed_date = nil
      end

      transitions :from => :completed, :to => :uncompleted
    end

    event :reset do
      before do
        self.completed_date = nil
        self.completed_unit_count = 0
      end

      transitions :from => [:completed, :uncompleted], :to => :uncompleted
    end
  end

  after_initialize { self.recurring_type ||= :none }
  before_validation { self.title&.strip! }
  before_validation :set_default_attributes
  before_validation :ensure_location_is_nullified, unless: :interpreting_task?
  before_save :update_task_data, if: :association_fields_changed?
  after_commit :update_project_completion_ratio, on: :update
  after_create :refresh_task_cache
  after_destroy :refresh_task_cache

  def self.full_search(query)
    fuzzy_search(query, [:title, :description])
  end

  def self.sort_by_attribute(method)
    case method.to_s
    when 'closest_future_date' then order_closest_future_date
    when 'due_date'      then order_due_date_asc
    when 'due_date_asc'  then order_due_date_asc
    when 'due_date_desc' then order_due_date_desc
    else
      super
    end
  end

  def refresh_task_cache
    return unless workspace
    Workspaces::TasksCountService.new(workspace).refresh_cache
  end

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

  def completed_status
    return nil unless completed_date.present? && due_date.present?
    completed_late? ? :late : :on_time
  end

  def completed_late?
    completed_date > due_date
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

  def search_routing
    workspace_id
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

  public

  def search_data
    {
      title: title,
      description: description,
      color: color,
      status: status,
      completed_status: completed_status,
      workspace_id: workspace_id,
      owner_id: owner_id,
      owner_name: owner&.name,
      assignee_id: assignee&.id,
      assignee_name: assignee&.name,
      project_id: project_id,
      project_name: project&.name,
      tasklist_id: tasklist_id,
      tasklist_title: tasklist&.title,
      source_language_id: source_language_id,
      source_language: source_language&.name,
      target_language_id: target_language_id,
      target_language: target_language&.name,
      task_type_id: task_type_id,
      task_type: task_type&.name,
      unit_id: unit_id,
      unit: unit&.name,
      classification: classification,
      internal: other_task?,
      start_date: start_date,
      due_date: due_date,
      completed_date: completed_date,
      created_at: created_at,
      updated_at: updated_at,
    }
  end
end
