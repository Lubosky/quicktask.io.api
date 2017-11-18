module HasMember
  extend ActiveSupport::Concern

  included do
    has_one :workspace_user, as: :member, inverse_of: :member, dependent: :destroy
    has_one :workspace, through: :workspace_user, as: :member, inverse_of: :member, foreign_key: :workspace_id, class_name: 'Workspace'
  end
end