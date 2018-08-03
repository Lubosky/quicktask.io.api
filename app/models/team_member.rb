class TeamMember < ApplicationRecord
  include EnsureUUID
  include HasMember
  include HasName

  belongs_to :workspace, inverse_of: :team_members, class_name: 'Workspace'

  validates :email, email: true, presence: true, uniqueness: true
end
