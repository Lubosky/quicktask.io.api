class TeamMember < ApplicationRecord
  include EnsureUUID
  include HasMember
  include HasName

  belongs_to :workspace, inverse_of: :team_members, class_name: 'Workspace'

  has_many :assignments,
           -> { accepted },
           as: :assignee,
           class_name: 'HandOff',
           foreign_key: :assignee_id,
           inverse_of: :assignee

  has_many :delegated_hand_offs,
           class_name: 'HandOff',
           foreign_key: :assigner_id,
           inverse_of: :assigner

  validates :email, email: true, presence: true
  validates_uniqueness_of :email, case_sensitive: false, scope: :workspace_id
end
