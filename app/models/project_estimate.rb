class ProjectEstimate < ApplicationRecord
  belongs_to :project, class_name: 'Project::Regular'
  belongs_to :quote

  validates :project, :quote, presence: true
  validates :quote_id, uniqueness: { scope: :project_id }
end
