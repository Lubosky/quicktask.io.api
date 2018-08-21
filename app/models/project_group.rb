class ProjectGroup < ApplicationRecord
  include EnsureUUID

  with_options inverse_of: :project_groups do
    belongs_to :workspace
    belongs_to :client
  end

  has_many :projects,
           class_name: 'Project::Base',
           dependent: :restrict_with_error,
           inverse_of: :project_group

  validates :name, presence: true

  validates :client, presence: true
  validates :workspace, presence: true
end
