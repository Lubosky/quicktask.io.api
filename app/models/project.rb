 class Project < ApplicationRecord
  include EnsureUUID

  belongs_to :workspace, inverse_of: :projects

  with_options dependent: :destroy, inverse_of: :project do
    has_many :tasklists
    has_many :tasks, through: :tasklists
  end

  discriminate Project, on: :project_type

  enum workflow_type: [:none, :default, :custom], _prefix: true

  jsonb_accessor :settings,
    internal: [:boolean, default: false]

  accepts_nested_attributes_for :tasklists,
                                allow_destroy: true,
                                reject_if: ->(o) { o['title'].blank? }

  after_initialize do
    self.status ||= :draft
    self.workflow_type ||= :default
  end

  scope :with_preloaded, -> {
    joins(tasklists: { tasks: [:task_type, :todos] }).
      preload(tasklists: { tasks: [:task_type, :todos] })
  }

  validates :workspace, presence: true

  def self.set_project_type(type)
    after_initialize { self.project_type = type }
  end

  def has_automated_workflow?
    workflow_type.in?(['default', 'custom'])
  end

  def is_internal?
    internal?
  end

  def ordered_tasklist_ids
    ordered_task_map.keys
  end

  def ordered_task_ids
    ordered_task_map
  end
end
