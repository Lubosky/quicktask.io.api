module HasMember
  extend ActiveSupport::Concern

  included do
    has_one :workspace_user, as: :member, inverse_of: :member, dependent: :destroy
    has_one :workspace,
            through: :workspace_user,
            as: :member,
            inverse_of: :member,
            class_name: 'Workspace',
            foreign_key: :workspace_id
  end
end
