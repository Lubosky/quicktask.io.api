class Project::Template < Project
  set_project_type :template

  BLANK_NAME = ''.freeze

  with_options optional: true do
    belongs_to :owner, class_name: 'TeamMember', foreign_key: :owner_id
    belongs_to :client
  end

  jsonb_accessor :metadata,
    template_name: [:string, default: nil],
    template_description: [:string, default: nil],
    system_template: [:boolean, default: false],
    workflow_type: [:integer, default: nil]

  default_scope { where(project_type: :template) }
  scope :with_task_map, -> { select("projects.*, #{TaskMapQuery.query}") }

  enum status: [:no_status, :draft]
  enum workflow_type: [:kanban, :team, :weekday]

  before_validation { self.name ||= BLANK_NAME }
  before_destroy :check_deletable

  validates :name, presence: true, allow_blank: true
  with_options unless: :system_template do
    validates :template_name, :template_description, presence: true
  end

  private

  def ordered_task_map
    if respond_to?(:collection_map)
      collection = collection_map
    else
      collection = ::Project::Template.where(id: id).
        pluck(TaskMapQuery.query).
        first
    end

    collection ? collection.reduce(Hash.new, :merge) : Hash.new
  end

  def check_deletable
    if self.system_template?
      errors.add(:base, :cannot_be_deleted)
      throw(:abort)
    end
  end
end
