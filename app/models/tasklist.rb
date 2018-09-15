class Tasklist < ApplicationRecord
  include BelongsDirectly, EnsureUUID

  with_options inverse_of: :tasklists do
    belongs_to :owner,
               class_name: 'TeamMember',
               foreign_key: :owner_id,
               optional: true
    belongs_to :project
    belongs_to :workspace
  end

  has_many :tasks, dependent: :destroy, inverse_of: :tasklist

  belongs_directly_to :workspace

  acts_as_list scope: :project, top_of_list: 0

  accepts_nested_attributes_for :tasks, allow_destroy: true

  default_scope { order(:position) }
  scope :for_projects, -> {
    joins(:project).where(projects: { project_type: :regular })
  }
  scope :for_project_templates, -> {
    joins(:project).where(projects: { project_type: :template })
  }

  validates :project, :title, :workspace, presence: true
  validates :owner, presence: true, if: -> { project.project_type == 'regular' }

  delegate :workspace, to: :project

  before_validation { self.title&.strip! }
end
