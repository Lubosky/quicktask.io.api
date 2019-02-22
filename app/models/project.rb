 class Project < ApplicationRecord
  include EnsureUUID, Taggable

  belongs_to :workspace, inverse_of: :projects

  with_options dependent: :destroy, inverse_of: :project do
    has_many :tasklists
    has_many :tasks, through: :tasklists
  end

  has_many :task_dependencies, through: :tasks, source: :precedent_task_relations

  discriminate Project, on: :project_type

  enum workflow_type: [:none, :default, :custom], _prefix: true

  jsonb_accessor :settings,
    internal: [:boolean, default: false]

  accepts_nested_attributes_for :tasklists,
                                allow_destroy: true,
                                reject_if: ->(o) { o['title'].blank? }

  after_initialize do
    self.workflow_type ||= :default
  end

  after_save :remove_task_dependencies, if: :workflow_has_changed?
  after_create :refresh_project_cache
  after_destroy :refresh_project_cache

  scope :regular, -> { where(project_type: :regular) }
  scope :with_preloaded, -> {
    joins(tasklists: { tasks: [:task_type, :todos] }).
      preload(tasklists: { tasks: [:task_type, :todos] })
  }

  validates :workspace, presence: true

  def self.set_project_type(type)
    after_initialize { self.project_type = type }
  end

  def refresh_project_cache
    return unless workspace
    Workspaces::ProjectsCountService.new(workspace).refresh_cache
  end

  def has_automated_workflow?
    workflow_type.in?(['default', 'custom'])
  end

  def workflow_has_changed?
    saved_change_to_workflow_type? && workflow_type_before_last_save === 'custom'
  end

  def is_internal?
    internal?
  end

  def remove_task_dependencies
    TaskDependency.where(task_id: task_ids).delete_all
  end
end
