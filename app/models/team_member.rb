class TeamMember < ApplicationRecord
  include EnsureUUID
  include HasMember
  include HasName

  belongs_to :workspace, inverse_of: :team_members, class_name: 'Workspace'

  validates :email, email: true, presence: true
  validates_uniqueness_of :email, case_sensitive: false, scope: :workspace_id
end
