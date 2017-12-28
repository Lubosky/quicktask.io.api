class ProjectGroup < ApplicationRecord
  include EnsureUUID

  with_options inverse_of: :project_groups do
    belongs_to :workspace
    belongs_to :client
  end

  has_many :projects, inverse_of: :project_group, dependent: :restrict_with_error

  validates :name, presence: true

  validates :client, presence: true
  validates :workspace, presence: true
end