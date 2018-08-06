class TaskType < ApplicationRecord
  include EnsureUUID

  belongs_to :workspace, inverse_of: :task_types

  has_many :service_tasks, inverse_of: :task_type
  has_many :services, through: :service_tasks
  has_many :tasks, inverse_of: :task_type

  enum classification: {
    translation: 0,
    interpreting: 1,
    localization: 2,
    other: 3
  }

  scope :with_type, ->(classification) { where(classification: classification) }

  validates :name, :classification, presence: true
  validates_uniqueness_of :name, case_sensitive: false, scope: :workspace_id

  def self.build_for(workspace)
    workspace.task_types.build(fixtures)
  end

  def self.create_for(workspace)
    workspace.task_types.create(fixtures)
  end

  def self.fixtures
    YAML.load_file(Rails.root.join('config', 'fixtures', 'task_types.yml'))
  end
end
