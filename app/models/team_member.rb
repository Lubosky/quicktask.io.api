class TeamMember < ApplicationRecord
  include EnsureUUID
  include HasMember

  belongs_to :workspace, inverse_of: :team_members, class_name: 'Workspace'
end
